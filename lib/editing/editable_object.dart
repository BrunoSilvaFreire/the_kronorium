import 'package:flutter/material.dart';

abstract class EditableObject with ChangeNotifier {
  String name;

  EditableObject({required this.name});

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
