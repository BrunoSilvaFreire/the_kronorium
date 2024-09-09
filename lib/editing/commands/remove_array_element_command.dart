import 'dart:ui';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class RemoveArrayElementCommand<T> extends SnapshotCommand<T> {
  List<T> array;
  final int index;
  final String objectName;
  final String propertyName;
  final VoidCallback onModified;

  RemoveArrayElementCommand({
    required this.array,
    required this.index,
    required this.objectName,
    required this.propertyName,
    required this.onModified,
  });

  @override
  T applyWithSnapshot(EasterEgg easterEgg) {
    // Check if index is within the bounds of the array
    if (index < 0 || index >= array.length) {
      throw IndexError(index, array, "Invalid array index", null, array.length);
    }

    // Take a snapshot of the element to be removed
    T removedElement = array[index];

    // Remove the element at the specified index
    array.removeAt(index);
    onModified();

    return removedElement;
  }

  @override
  Label getLabel() {
    return Label(
      MdiIcons.minus,
      "Remove element at index $index from $propertyName in $objectName",
    );
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, T snapshot) {
    // Reinsert the removed element at the original index
    array.insert(index, snapshot);
    onModified();
  }
}
