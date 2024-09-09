import 'dart:ui';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/commands/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class AddArrayElementCommand<T> extends SnapshotCommand<int> {
  List<T> array;
  T element;
  final String objectName;
  final String propertyName;
  final VoidCallback onModified;

  AddArrayElementCommand({
    required this.array,
    required this.element,
    required this.objectName,
    required this.propertyName,
    required this.onModified,
  });

  @override
  int applyWithSnapshot(EasterEgg easterEgg) {
    // Add the element at the specified index
    var index = array.length;
    array.add(element);
    onModified();
    return index;
  }

  @override
  Label getLabel() {
    return Label(
      MdiIcons.plus,
      "Add element $element to $propertyName in $objectName",
    );
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, int snapshot) {
    // Remove the element at the specified index
    array.removeAt(snapshot);
    onModified();
  }
}
