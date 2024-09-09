import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/editing/commands/add_array_element_command.dart';
import 'package:the_kronorium/editing/commands/add_dependency_command.dart';
import 'package:the_kronorium/editing/commands/commander.dart';
import 'package:the_kronorium/editing/commands/set_array_element_command.dart';
import 'package:the_kronorium/editing/commands/set_step_property_command.dart';
import 'package:the_kronorium/editing/widgets/array_editor.dart';
import 'package:the_kronorium/editing/widgets/edit_step_gallery_field.dart';
import 'package:the_kronorium/editing/widgets/edit_step_note_field.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/widgets/container_card.dart';
import 'package:the_kronorium/widgets/select_icon_field.dart';
import 'package:the_kronorium/widgets/select_step_field.dart';

class EditStepCard extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;
  final EasterEggStep step;
  final Commander commander;

  const EditStepCard({
    super.key,
    required this.easterEgg,
    required this.step,
    required this.commander,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _EditStepCardState();
  }
}

class _EditStepCardState extends ConsumerState<EditStepCard> {
  late final TextEditingController _summaryController = TextEditingController(
    text: widget.step.summary,
  );
  late final TextEditingController _iconSearchController =
      TextEditingController(
    text: widget.step.iconName,
  );
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _summaryController.dispose();
    _iconSearchController.dispose();
    _noteController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    var step = widget.step;
    var icon = step.tryFindIcon();
    if (icon != null) {
      leading = Icon(
        icon,
      );
    }
    var easterEgg = widget.easterEgg;
    return ListenableBuilder(
      listenable: step,
      builder: (context, _) {
        return ContainerCard.leftSideContainer(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              leading: IconPicker(
                width: 128,
                initialIcon: step.iconName,
                label: "Icon",
                onPicked: (icon) {
                  widget.commander.addCommand(
                    SetPropertyCommand(
                      value: icon,
                      objectName: step.name,
                      propertyName: "icon",
                      setter: (value) => step.iconName = value,
                      getter: () => step.iconName,
                    ),
                    easterEgg,
                  );
                },
                maxNumIcons: 15,
              ),
              title: Text("Step ${step.name}"),
            ),
            TextField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: "Summary",
              ),
              onSubmitted: (value) {
                widget.commander.addCommand(
                  SetPropertyCommand(
                    value: value,
                    objectName: step.name,
                    propertyName: "summary",
                    setter: (value) => step.summary = value,
                    getter: () => step.summary,
                  ),
                  easterEgg,
                );
              },
            ),
            const Divider(),
            Text("Dependencies (${step.dependencies.length})"),
            EasterEggStepPicker(
              hintText: "Start typing to add a dependency",
              label: const Text("Add dependency"),
              easterEgg: easterEgg,
              onPicked: (value, index) {
                widget.commander.addCommand(
                  AddDependenciesCommand(step, [index]),
                  easterEgg,
                );
                easterEgg.invalidateCache();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (int dependencyIndex in step.dependencies)
                    ActionChip(
                      tooltip: "Click to remove dependency",
                      label: Text(easterEgg.steps[dependencyIndex].name),
                      onPressed: () {
                        widget.commander.addCommand(
                          RemoveDependenciesCommand(step, [dependencyIndex]),
                          easterEgg,
                        );
                        easterEgg.invalidateCache();
                      },
                    )
                ],
              ),
            ),
            const Divider(),
            ArrayEditor(
              array: step.notes,
              propertyName: "Notes",
              commander: widget.commander,
              easterEgg: easterEgg,
              object: step,
              itemCreator: () => "",
              itemBuilder: (index, input, modificationCallback) => EditStepNoteField(
                labelText: "Note #${index + 1}",
                initialValue: input,
                onSubmitted: modificationCallback,
              ),
            )
            // Text("Notes (${step.notes.length})"),
            // TextField(
            //   decoration: const InputDecoration(
            //     hintText: "Start typing to add a new note.",
            //   ),
            //   controller: _noteController,
            //   onSubmitted: (value) {
            //     widget.commander.addCommand(
            //       AddArrayElementCommand(
            //         array: step.notes,
            //         element: value,
            //         objectName: step.name,
            //         propertyName: "notes",
            //         onModified: step.notifyListeners,
            //       ),
            //       easterEgg,
            //     );
            //     _noteController.clear();
            //   },
            // ),
            // for (var (index, note) in step.notes.indexed)
            //   EditStepNoteField(
            //     labelText: "Note #${index + 1}",
            //     initialValue: note,
            //     onSubmitted: (value) {
            //       widget.commander.addCommand(
            //         SetArrayElementCommand(
            //           array: step.notes,
            //           value: value,
            //           index: index,
            //           objectName: step.name,
            //           propertyName: "notes",
            //           onModified: step.notifyListeners,
            //         ),
            //         easterEgg,
            //       );
            //     },
            //   ),
            ,
            const Divider(),
            ArrayEditor<EasterEggGalleryEntry>(
              array: step.gallery,
              propertyName: "Gallery",
              commander: widget.commander,
              easterEgg: easterEgg,
              object: step,
              itemCreator: () {
                return EasterEggGalleryEntry(
                  image: Uri.base,
                  notes: [],
                );
              },
              itemBuilder: (index, input, onChanged) {
                return EditStepGalleryField(
                  entry: input,
                  labelText: "Gallery Entry #$index",
                  onChanged: onChanged,
                );
              },
            ),
            const Divider(),
            DropdownMenu<EasterEggStepKind>(
              initialSelection: step.kind,
              label: const Text("Kind"),
              onSelected: (value) {
                if (value != null) {
                  widget.commander.addCommand(
                    SetPropertyCommand(
                      value: value,
                      objectName: step.name,
                      propertyName: "kind",
                      setter: (value) => step.kind = value,
                      getter: () => step.kind,
                    ),
                    easterEgg,
                  );
                }
              },
              dropdownMenuEntries: [
                for (var kind in EasterEggStepKind.values)
                  DropdownMenuEntry(value: kind, label: kind.name)
              ],
            )
          ],
        );
      },
    );
  }
}
