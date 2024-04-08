import 'dart:collection';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/editing/commander.dart';
import 'package:the_kronorium/pages/graph_page.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/widgets/create_step_dialog.dart';
import 'package:the_kronorium/widgets/editor.dart';

class EditEasterEggPage extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;

  const EditEasterEggPage({
    super.key,
    required this.easterEgg,
  });

  @override
  ConsumerState<EditEasterEggPage> createState() => _EditEasterEggPageState();
}

class _EditEasterEggPageState extends ConsumerState<EditEasterEggPage> {
  late final _selected = StateProvider<Set<int>>(
    (ref) => {},
  );
  late final _commander = Commander();

  void doCommand(Command command) {
    setState(() {
      _commander.addCommand(command, widget.easterEgg);
    });
  }

  void undoCommand() {
    setState(() {
      _commander.undoCurrentlyPointedCommand(widget.easterEgg);
    });
  }

  void redoCommand() {
    setState(() {
      _commander.redoOneCommand(widget.easterEgg);
    });
  }

  @override
  Widget build(BuildContext context) {
    const leftContainerWidth = 256.0;
    const rightContainerWidth = 512.0;
    const marginSpacing = 32.0;
    var selected = ref.watch(_selected);
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
        var deleteAllLabel = selected.isEmpty
            ? const Text("Delete selected")
            : Text("Delete selected (${selected.length})");
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
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            onPressed: () {
                              showModal(
                                  context: context,
                                  builder: (context) {
                                    return CreateStepDialog(
                                      onCreated: (EasterEggStep step) {
                                        setState(() {
                                          widget.easterEgg.addStep(step);
                                        });
                                      },
                                    );
                                  });
                            },
                            icon: Icon(MdiIcons.plusCircle),
                            label: const Text("Add Step"),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: ElevatedButton.icon(
                              onPressed: selected.isEmpty
                                  ? null
                                  : () {
                                      ref.read(_selected.notifier).state =
                                          Set.identity();
                                      doCommand(DeleteStepsCommand(selected));
                                    },
                              icon: Icon(MdiIcons.delete),
                              label: deleteAllLabel,
                            ),
                          ),
                          OverflowBar(
                            children: [
                              Tooltip(
                                message: "Do a Richtofen",
                                child: IconButton.filled(
                                  onPressed: () {
                                    ref.read(_selected.notifier).state =
                                        Set.identity();
                                    doCommand(
                                      DeleteStepsCommand(
                                        List.generate(
                                          widget.easterEgg.steps.length,
                                          (index) => index,
                                        ).toSet(),
                                      ),
                                    );
                                  },
                                  icon: Icon(MdiIcons.nuke),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            leading: Icon(
                              MdiIcons.counter,
                            ),
                            title:
                                Text("Steps: ${widget.easterEgg.steps.length}"),
                          ),
                          TextButton.icon(
                            onPressed: () {},
                            icon: Icon(MdiIcons.contentCopy),
                            label: const Text("Copy JSON"),
                          ),
                          const Divider(),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton.filled(
                                  onPressed: _commander.canUndoCommand()
                                      ? () {
                                          undoCommand();
                                        }
                                      : null,
                                  icon: Icon(MdiIcons.undo),
                                ),
                                IconButton.filled(
                                  onPressed: _commander.canRedoCommand()
                                      ? () {
                                          redoCommand();
                                        }
                                      : null,
                                  icon: Icon(MdiIcons.redo),
                                ),
                              ],
                            ),
                          ),
                          for (var (index, command)
                              in _commander.commands.indexed)
                            ListTile(
                              selected: index == _commander.index,
                              subtitle: Text(
                                "#$index: $command",
                              ),
                              onTap: () {},
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
              width: 512,
              child: ListView(
                children: [
                  for (var sel in selected)
                    ContainerCard(
                      child: Editor(
                        selected: Provider(
                          (ref) {
                            return widget.easterEgg.steps[sel];
                          },
                        ),
                        onDelete: (EasterEggStep step) {},
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
