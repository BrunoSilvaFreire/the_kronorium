import 'dart:ui';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class SetArrayElementCommand<T> extends SnapshotCommand<T> {
  List<T> array;
  int index;
  T value;
  String objectName;
  String propertyName;
  final VoidCallback onModified;

  SetArrayElementCommand({
    required this.onModified,
    required this.array,
    required this.index,
    required this.value,
    required this.objectName,
    required this.propertyName,
  });

  @override
  T applyWithSnapshot(EasterEgg easterEgg) {
    // Check if index is within the bounds of the array
    if (index < 0 || index >= array.length) {
      throw IndexError(index, array, "Invalid array index", null, array.length);
    }

    T oldValue = array[index];
    array[index] = value;
    onModified();
    return oldValue;
  }

  @override
  Label getLabel() {
    return Label(
      MdiIcons.pencil,
      "Change element at index $index of $propertyName in $objectName to $value",
    );
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, T snapshot) {
    // Check if index is within the bounds of the array
    if (index < 0 || index >= array.length) {
      throw IndexError(index, array, "Invalid array index", null, array.length);
    }

    // Undo the modification
    array[index] = snapshot;
    onModified();
  }
}
