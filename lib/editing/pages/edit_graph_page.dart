import 'dart:collection';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/create_step_command.dart';
import 'package:the_kronorium/editing/delete_steps_command.dart';
import 'package:the_kronorium/editing/widgets/edit_step_card.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/editing/commander.dart';
import 'package:the_kronorium/editing/editing_fields.dart';
import 'package:the_kronorium/pages/graph_page.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/editing/widgets/create_step_dialog.dart';
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

  static List<(String, Color)> colorSuggestions = [
    ("Red Accent", Colors.redAccent),
    ("Pink Accent", Colors.pinkAccent),
    ("Purple Accent", Colors.purpleAccent),
    ("Deep Purple Accent", Colors.deepPurpleAccent),
    ("Indigo Accent", Colors.indigoAccent),
    ("Blue Accent", Colors.blueAccent),
    ("Light Blue Accent", Colors.lightBlueAccent),
    ("Cyan Accent", Colors.cyanAccent),
    ("Teal Accent", Colors.tealAccent),
    ("Green Accent", Colors.greenAccent),
    ("Light Green Accent", Colors.lightGreenAccent),
    ("Lime Accent", Colors.limeAccent),
    ("Yellow Accent", Colors.yellowAccent),
    ("Amber Accent", Colors.amberAccent),
    ("Orange Accent", Colors.orangeAccent),
    ("Deep Orange Accent", Colors.deepOrangeAccent),
    ("Red", Colors.red),
    ("Pink", Colors.pink),
    ("Purple", Colors.purple),
    ("Deep Purple", Colors.deepPurple),
    ("Indigo", Colors.indigo),
    ("Blue", Colors.blue),
    ("Light Blue", Colors.lightBlue),
    ("Cyan", Colors.cyan),
    ("Teal", Colors.teal),
    ("Green", Colors.green),
    ("Light Green", Colors.lightGreen),
    ("Lime", Colors.lime),
    ("Yellow", Colors.yellow),
    ("Amber", Colors.amber),
    ("Orange", Colors.orange),
    ("Deep Orange", Colors.deepOrange),
    ("Brown", Colors.brown),
    ("Blue Grey", Colors.blueGrey),
  ];

  late final _nameProvider = StateProvider(
    (ref) => widget.easterEgg.name,
  );
  late final _mapProvider = StateProvider(
    (ref) => widget.easterEgg.map,
  );
  late final _thumbnailProvider = StateProvider(
    (ref) => widget.easterEgg.thumbnailURL,
  );
  late final _editionProvider = StateProvider(
    (ref) => widget.easterEgg.primaryEdition,
  );

  @override
  Widget build(BuildContext context) {
    const leftContainerWidth = 352.0;
    const rightContainerWidth = 512.0;
    const marginSpacing = 32.0;

    var selected = ref.watch(_selected);
    widget.easterEgg.name = ref.watch(_nameProvider);
    widget.easterEgg.map = ref.watch(_mapProvider);
    widget.easterEgg.thumbnailURL = ref.watch(_thumbnailProvider);
    widget.easterEgg.primaryEdition = ref.watch(_editionProvider);

    return ListenableBuilder(
        listenable: Listenable.merge(widget.easterEgg.steps),
        builder: (context, child) {
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
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        ContainerCard.leftSideContainer(
                          children: [
                            FloatingActionButton.extended(
                              elevation: 0,
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              onPressed: () {
                                _onCreateStepClicked(context);
                              },
                              icon: Icon(MdiIcons.plusCircle),
                              label: const Text("Add Step"),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildButtonBar(selected),
                            ),
                            TextButton.icon(
                              onPressed: _copyGuideJSONToClipboard,
                              icon: Icon(MdiIcons.contentCopy),
                              label: const Text("Copy JSON"),
                            ),
                            const Divider(),
                            ListTile(
                              leading: Icon(MdiIcons.counter),
                              title: Text(
                                  "Steps: ${widget.easterEgg.steps.length}"),
                            ),
                            EasterEggFieldsEditor(
                              formKey: _key,
                              name: _nameProvider,
                              map: _mapProvider,
                              thumbnail: _thumbnailProvider,
                              primaryEdition: _editionProvider,
                              allowChangeName: false,
                            ),
                            const Divider(),
                            DropdownMenu(
                              // We need to find the actual color in the list in order
                              // for flutter to pick up the correct label
                              initialSelection: findExistingSuggestionForColor(
                                widget.easterEgg.color,
                              ),
                              hintText: "Easter Egg Color Theme",
                              leadingIcon: CircleAvatar(
                                backgroundColor: widget.easterEgg.color,
                              ),
                              onSelected: (value) {
                                if (value != null) {
                                  setState(() {
                                    widget.easterEgg.color = value;
                                  });
                                }
                              },
                              dropdownMenuEntries: [
                                for (var (name, accent) in colorSuggestions)
                                  DropdownMenuEntry(
                                    leadingIcon: CircleAvatar(
                                      backgroundColor: accent,
                                    ),
                                    value: accent,
                                    label: name,
                                  )
                              ],
                            ),
                            const Divider(),
                            for (var (index, command)
                                in _commander.commands.indexed)
                              ListTile(
                                selected: index == _commander.index,
                                leading: Icon(command.getLabel().icon),
                                title: Text(command.getLabel().label),
                                onTap: index == _commander.index
                                    ? null
                                    : () {
                                        setState(() {
                                          _commander.goTo(
                                              index, widget.easterEgg);
                                        });
                                      },
                              )
                          ],
                        ),
                        for (var stepIndex in selected)
                          EditStepCard(
                            easterEgg: widget.easterEgg,
                            step: widget.easterEgg.steps[stepIndex],
                            commander: _commander,
                          )
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
        });
  }

  void _copyGuideJSONToClipboard() async {
    var content = jsonEncode(widget.easterEgg.toMap());
    await Clipboard.setData(ClipboardData(text: content));
  }

  void _onCreateStepClicked(BuildContext context) {
    showModal(
        context: context,
        builder: (context) {
          return CreateStepDialog(
            onCreated: (EasterEggStep step) {
              doCommand(CreateStepCommand(step));
            },
          );
        });
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

  Color? findExistingSuggestionForColor(Color color) {
    for (var (_, existing) in colorSuggestions) {
      if (existing.value == color.value) {
        return existing;
      }
    }
    return null;
  }
}
