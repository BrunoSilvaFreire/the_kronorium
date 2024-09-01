import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/pages/graph_page.dart';
import 'package:the_kronorium/providers/local_easter_eggs.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/widgets/inspector.dart';

class EasterEggPage extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;

  const EasterEggPage(
    this.easterEgg, {
    super.key,
  });

  @override
  ConsumerState<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends ConsumerState<EasterEggPage> {
  late final _selected = StateProvider<Set<int>>(
    (ref) => <int>{},
  );

  @override
  Widget build(BuildContext context) {
    var easterEgg = widget.easterEgg;

    return GraphPage(
      easterEgg: easterEgg,
      selectedProvider: _selected,
      actions: [
        if (easterEgg.editable)
          TextButton.icon(
            icon: Icon(MdiIcons.fileEdit),
            label: const Text("Edit"),
            onPressed: () async {
              EditEasterEggPage.openForEdit(context, easterEgg);
            },
          ),
        TextButton.icon(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  EasterEgg copy = createEasterEggCopy(easterEgg);
                  return EditEasterEggPage(
                    easterEgg: copy,
                  );
                },
              ),
            );
          },
          icon: Icon(MdiIcons.contentCopy),
          label: const Text("Edit a copy"),
        ),
      ],
      builder: (context, map) {
        var selected = ref.watch(_selected);
        return Stack(
          children: [
            Positioned.fill(
              child: map,
            ),
            Positioned(
              top: 0,
              bottom: 0,
              width: 512,
              right: 0,
              child: ListView(
                children: [
                  for (var sel in selected)
                    ContainerCard(
                      child: Inspector(
                        selected: Provider(
                          (ref) => easterEgg.steps[sel],
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  EasterEgg createEasterEggCopy(EasterEgg easterEgg) {
    var existingEasterEggs = ref
        .read(
          localEasterEggRegistryProvider,
        )
        .requireValue;
    String newName = "${easterEgg.name} copy";
    int iteration = 1;
    while (existingEasterEggs.any((e) => e.name == newName)) {
      newName = "${easterEgg.name} copy (${iteration++})";
    }
    var copy = easterEgg.copy(newName);
    ref.read(localEasterEggRegistryProvider.notifier).saveEasterEgg(easterEgg);
    return copy;
  }
}
