import 'dart:collection';

import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/editing/command.dart';

class Commander {
  int? _commandPointer;
  final _commandQueue = Queue<Command>();

  Iterable<Command> get commands => _commandQueue;

  int? get index => _commandPointer;

  void addCommand(Command command, EasterEgg easterEgg) {
    command.apply(easterEgg);
    _commandPointer = _commandQueue.length;
    _commandQueue.add(command);
  }

  void undoCurrentlyPointedCommand(EasterEgg easterEgg) {
    var ptr = _commandPointer;
    if (ptr == null) {
      return;
    }
    _commandQueue.elementAt(ptr).undo(easterEgg);
    _commandPointer = ptr - 1;
  }

  bool canUndoCommand() {
    if (_commandQueue.isEmpty) {
      return false;
    }
    var ptr = _commandPointer;
    if (ptr == null) {
      return false;
    }

    return ptr >= 0 && ptr < _commandQueue.length;
  }

  bool canRedoCommand() {
    if (_commandQueue.isEmpty) {
      return false;
    }
    var ptr = _commandPointer;
    if (ptr == null) {
      return false;
    }
    return ptr < _commandQueue.length - 1;
  }

  void redoOneCommand(EasterEgg easterEgg) {
    var ptr = _commandPointer;
    if (ptr == null) {
      return;
    }
    _commandQueue.elementAt(ptr + 1).apply(easterEgg);
    _commandPointer = ptr + 1;
  }

  void goTo(int index, EasterEgg easterEgg) {
    var ptr = _commandPointer;
    if (ptr == null) {
      return;
    }
    if (index > ptr) {
      // Go Forward
      for (int i = ptr; i != index; i++) {
        _commandQueue.elementAt(_commandQueue.length-index).apply(easterEgg);
      }
    }
    if (index < ptr) {
      // Go Backward
      for (int i = ptr; i != index; i--) {
        _commandQueue.elementAt(_commandQueue.length-index).undo(easterEgg);
      }
      _commandPointer = index;
    }
  }
}
