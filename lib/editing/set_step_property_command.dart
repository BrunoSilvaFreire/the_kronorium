import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class SetPropertyCommand<T> extends SnapshotCommand<T> {
  T value;
  String objectName;
  String propertyName;
  void Function(T value) setter;
  T Function() getter;

  SetPropertyCommand({
    required this.value,
    required this.objectName,
    required this.propertyName,
    required this.setter,
    required this.getter,
  });

  @override
  T applyWithSnapshot(EasterEgg easterEgg) {
    T oldValue = getter();
    setter(value);
    return oldValue;
  }

  @override
  Label getLabel() {
    return Label(
      MdiIcons.pencil,
      "Change $propertyName of $objectName to $value",
    );
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, T snapshot) {
    setter(snapshot);
  }
}
