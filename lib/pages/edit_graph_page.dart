import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/graph_page.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/widgets/editor.dart';

class EditEasterEggPage extends StatefulWidget {
  final EasterEgg easterEgg;

  const EditEasterEggPage({
    super.key,
    required this.easterEgg,
  });

  @override
  State<EditEasterEggPage> createState() => _EditEasterEggPageState();
}

class _EditEasterEggPageState extends State<EditEasterEggPage> {
  late final _selected = StateProvider<int?>(
    (ref) => null,
  );

  @override
  Widget build(BuildContext context) {
    const leftContainerWidth = 256.0;
    const rightContainerWidth = 512.0;
    const marginSpacing = 32.0;
    return GraphPage(
      easterEgg: widget.easterEgg,
      selectedProvider: _selected,
      mapMargin: const EdgeInsets.only(
        left: leftContainerWidth + marginSpacing,
        top: marginSpacing,
        bottom: marginSpacing,
        right: rightContainerWidth + marginSpacing,
      ),
      builder: (context, map) {
        var theme = Theme.of(context);
        return Stack(
          children: [
            Positioned.fill(
              child: map,
            ),
            Positioned(
              top: 8,
              bottom: 8,
              left: 0,
              width: leftContainerWidth,
              child: Column(
                children: [
                  ContainerCard(
                    elevation: 12,
                    margin: const EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                      right: 16,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FloatingActionButton.extended(
                            elevation: 0,
                            backgroundColor:
                                theme.colorScheme.onPrimaryContainer,
                            foregroundColor: theme.colorScheme.onPrimary,
                            onPressed: () {},
                            icon: Icon(MdiIcons.plusCircle),
                            label: const Text("Add Step"),
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              MdiIcons.counter,
                            ),
                            title:
                                Text("Steps: ${widget.easterEgg.steps.length}"),
                          ),
                          const Divider(),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(MdiIcons.contentCopy),
                            label: const Text("Copy JSON"),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(MdiIcons.fileDownload),
                            label: const Text("Save to file"),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: ContainerCard(
                child: Editor(
                  selected: Provider(
                    (ref) {
                      var selected = ref.watch(_selected);
                      if (selected == null) {
                        return null;
                      }
                      return widget.easterEgg.steps[selected];
                    },
                  ),
                  onDelete: (EasterEggStep step) {
                    setState(() {
                      widget.easterEgg.remove(step);
                    });
                  },
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
