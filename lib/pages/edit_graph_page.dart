import 'dart:collection';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/editing/commander.dart';
import 'package:the_kronorium/editing/editing_fields.dart';
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

  static void openForEdit(
    BuildContext context,
    EasterEgg easterEgg, {
    bool asReplacement = false,
  }) {
    var page = MaterialPageRoute(
      builder: (context) {
        return EditEasterEggPage(
          easterEgg: easterEgg,
        );
      },
    );
    var navigator = Navigator.of(context);
    if (asReplacement) {
      navigator.pushReplacement(page);
    } else {
      navigator.push(page);
    }
  }
}

class _EditEasterEggPageState extends ConsumerState<EditEasterEggPage> {
  late final _selected = StateProvider<Set<int>>(
    (ref) => {},
  );
  late final _commander = Commander();
  late final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

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
    const leftContainerWidth = 352.0;
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
                  ContainerCard.leftSideContainer(
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
                                    doCommand(CreateStepCommand(step));
                                  },
                                );
                              });
                        },
                        icon: Icon(MdiIcons.plusCircle),
                        label: const Text("Add Step"),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: _buildButtonBar(selected),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          var content = jsonEncode(widget.easterEgg.toMap());
                          await Clipboard.setData(ClipboardData(text: content));
                        },
                        icon: Icon(MdiIcons.contentCopy),
                        label: const Text("Copy JSON"),
                      ),
                      const Divider(),
                      ListTile(
                        leading: Icon(MdiIcons.counter),
                        title: Text("Steps: ${widget.easterEgg.steps.length}"),
                      ),
                      EasterEggFieldsEditor(
                        formKey: _key,
                        name: StateProvider((ref) => widget.easterEgg.name),
                        map: StateProvider((ref) => widget.easterEgg.map),
                        thumbnail: StateProvider(
                            (ref) => widget.easterEgg.thumbnailURL),
                        primaryEdition: StateProvider(
                          (ref) => widget.easterEgg.primaryEdition,
                        ),
                      ),
                      const Divider(),
                      for (var (index, command) in _commander.commands.indexed)
                        ListTile(
                          selected: index == _commander.index,
                          leading: Icon(command.getLabel().icon),
                          title: Text(command.getLabel().label),
                          onTap: index == _commander.index
                              ? null
                              : () {
                                  setState(() {
                                    _commander.goTo(index, widget.easterEgg);
                                  });
                                },
                        )
                    ],
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

  OverflowBar _buildButtonBar(Set<int> selected) {
    var deleteAllLabel = selected.isEmpty
        ? "Delete selected"
        : "Delete selected (${selected.length})";
    return OverflowBar(
      alignment: MainAxisAlignment.spaceEvenly,
      spacing: 8,
      children: [
        Tooltip(
          message: "Undo",
          child: IconButton.filled(
            onPressed: _commander.canUndoCommand()
                ? () {
                    undoCommand();
                  }
                : null,
            icon: Icon(MdiIcons.undo),
          ),
        ),
        Tooltip(
          message: "Redo",
          child: IconButton.filled(
            onPressed: _commander.canRedoCommand()
                ? () {
                    redoCommand();
                  }
                : null,
            icon: Icon(MdiIcons.redo),
          ),
        ),
        Tooltip(
          message: deleteAllLabel,
          child: IconButton.filled(
            onPressed: selected.isEmpty
                ? null
                : () {
                    ref.read(_selected.notifier).state = Set.identity();
                    doCommand(DeleteStepsCommand(selected));
                  },
            icon: Icon(MdiIcons.delete),
          ),
        ),
        Tooltip(
          message: "Do a Richtofen",
          child: IconButton.filled(
            onPressed: () {
              ref.read(_selected.notifier).state = Set.identity();
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
    );
  }
}
