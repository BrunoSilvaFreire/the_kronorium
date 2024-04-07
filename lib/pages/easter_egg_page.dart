import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/pages/graph_page.dart';
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
    return GraphPage(
      easterEgg: widget.easterEgg,
      selectedProvider: _selected,
      actions: [
        TextButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return EditEasterEggPage(
                    easterEgg: widget.easterEgg.copy(),
                  );
                },
              ),
            );
          },
          icon: Icon(MdiIcons.fileDocumentEdit),
          label: const Text("Edit a copy"),
        )
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
                          (ref) => widget.easterEgg.steps[sel],
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
}
