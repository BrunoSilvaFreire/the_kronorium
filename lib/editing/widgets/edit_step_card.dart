import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/editing/add_dependency_command.dart';
import 'package:the_kronorium/editing/commander.dart';
import 'package:the_kronorium/editing/set_step_property_command.dart';
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
  late final TextEditingController _summaryController = TextEditingController()
    ..text = widget.step.summary;
  late final TextEditingController _iconSearchController =
      TextEditingController()..text = widget.step.iconName ?? "";

  @override
  void dispose() {
    super.dispose();
    _summaryController.dispose();
    _iconSearchController.dispose();
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
    return ContainerCard.leftSideContainer(
      children: [
        ListTile(
          leading: leading,
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
              widget.easterEgg,
            );
          },
        ),
        IconPicker(
          initialIcon: step.iconName,
          onPicked: (icon) {
            widget.commander.addCommand(
              SetPropertyCommand(
                value: icon,
                objectName: step.name,
                propertyName: "icon",
                setter: (value) => step.iconName = value,
                getter: () => step.iconName,
              ),
              widget.easterEgg,
            );
          },
          maxNumIcons: 15,
        ),
        const Divider(),
        Text("Dependencies (${step.dependencies.length})"),
        EasterEggStepPicker(
          hintText: "Start typing to add a dependency",
          label: const Text("Add dependency"),
          easterEgg: widget.easterEgg,
          onPicked: (value, index) {
            widget.commander.addCommand(
              AddDependenciesCommand(step, [index]),
              widget.easterEgg,
            );
            widget.easterEgg.invalidateCache();
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
                  label: Text(widget.easterEgg.steps[dependencyIndex].name),
                  onPressed: () {
                    widget.commander.addCommand(
                      RemoveDependenciesCommand(step, [dependencyIndex]),
                      widget.easterEgg,
                    );
                    widget.easterEgg.invalidateCache();
                  },
                )
            ],
          ),
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
                widget.easterEgg,
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
  }
}
