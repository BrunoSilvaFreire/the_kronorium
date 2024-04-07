import 'package:the_kronorium/easter_eggs.dart';

abstract class Command {
  void apply(EasterEgg easterEgg);

  void undo(EasterEgg easterEgg);
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

class DeletionCache {
  final Map<String, dynamic> serialized;
  final List<String> dependants;

  DeletionCache({
    required this.serialized,
    required this.dependants,
  });
}

class DeleteStepsCommand extends SnapshotCommand<List<DeletionCache>> {
  Set<int> _toDelete;

  DeleteStepsCommand(this._toDelete);

  @override
  List<DeletionCache> applyWithSnapshot(EasterEgg easterEgg) {
    var steps = _toDelete
        .map(
          (i) => easterEgg.steps[i].toMap(easterEgg),
        )
        .toList();
    easterEgg.removeAll(_toDelete);
    return steps
        .map((e) => DeletionCache(serialized: e, dependants: []))
        .toList();
  }

  @override
  void undoWithSnapshot(
    EasterEgg easterEgg,
    List<DeletionCache> snapshot,
  ) {
    var newIndices = <int>{};
    for (var entry in snapshot) {
      var dependencies = EasterEgg.extractDependencies(
        entry.serialized,
        easterEgg.steps,
      );
      var step = EasterEggStep.fromMap(entry.serialized, dependencies);
      newIndices.add(easterEgg.addStep(step));
    }
    _toDelete = newIndices;
  }

  @override
  String toString() {
    return 'Delete steps ${_toDelete.join(", ")}';
  }
}

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
}
