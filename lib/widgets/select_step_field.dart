import 'package:flutter/material.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class EasterEggStepPicker extends StatefulWidget {
  final EasterEgg easterEgg;
  final String? hintText;
  final Widget? label;
  final void Function(EasterEggStep step, int index) onPicked;

  const EasterEggStepPicker({
    super.key,
    required this.easterEgg,
    required this.onPicked,
    required this.hintText,
    required this.label,
  });

  @override
  State<EasterEggStepPicker> createState() => _EasterEggStepPickerState();
}

class _EasterEggStepPickerState extends State<EasterEggStepPicker> {
  final TextEditingController _dependencySelectionController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _dependencySelectionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu(
      hintText: widget.hintText,
      controller: _dependencySelectionController,
      label: widget.label,
      onSelected: (value) {
        if (value != null) {
          widget.onPicked(
            widget.easterEgg.steps[value],
            value,
          );
          _dependencySelectionController.clear();
        }
      },
      dropdownMenuEntries: [
        for (var (index, step) in widget.easterEgg.steps.indexed)
          if (!(step.dependencies.contains(index)))
            _buildDependencyDropdown(index, step)
      ],
    );
  }

  DropdownMenuEntry<int> _buildDependencyDropdown(
      int index, EasterEggStep step) {
    var icon = step.tryFindIcon();
    return DropdownMenuEntry(
      value: index,
      label: step.name,
      leadingIcon: icon == null ? null : Icon(icon),
    );
  }
}
