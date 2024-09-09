import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/utils.dart';

abstract class Command {
  void apply(EasterEgg easterEgg);

  void undo(EasterEgg easterEgg);

  Label getLabel();
}

abstract class SnapshotCommand<T> extends Command {
  T? _snapshot;

  @override
  void apply(EasterEgg easterEgg) {
    _snapshot = applyWithSnapshot(easterEgg);
  }

  @override
  void undo(EasterEgg easterEgg) {
    undoWithSnapshot(easterEgg, _snapshot as T);
  }

  T applyWithSnapshot(EasterEgg easterEgg);

  void undoWithSnapshot(EasterEgg easterEgg, T snapshot);
}