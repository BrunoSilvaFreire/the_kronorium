
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/utils.dart';

class CreateStepCommand extends SnapshotCommand<int> {
  final EasterEggStep _step;

  CreateStepCommand(this._step);

  @override
  int applyWithSnapshot(EasterEgg easterEgg) {
    return easterEgg.addStep(_step);
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, int snapshot) {
    easterEgg.removeByIndex(snapshot);
  }

  @override
  Label getLabel() {
    return Label(
      MdiIcons.tooltipPlus,
      "Create step ${_step.name} (${clipString(_step.summary, 32)})",
    );
  }
}
