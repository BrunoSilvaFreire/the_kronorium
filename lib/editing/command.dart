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
    var recreated = <(int, EasterEggStep)>[];
    for (var entry in snapshot) {
      var step = EasterEggStep.fromMap(entry.serialized, []);
      recreated.add((
        easterEgg.addStep(step),
        step,
      ));
    }
    // Rebuild dependencies
    for (var (i, step) in recreated) {
      step.dependencies = EasterEgg.extractDependencies(
        snapshot[i].serialized,
        easterEgg.steps,
      );
    }
    _toDelete = recreated.map(
      (e) {
        var (i, _) = e;
        return i;
      },
    ).toSet();
  }

  @override
  Label getLabel() => Label(
        MdiIcons.delete,
        'Delete steps ${_toDelete.join(", ")}',
      );
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

  @override
  Label getLabel() {
    return Label(
      MdiIcons.tooltipPlus,
      "Create step ${_step.name} (${clipString(_step.summary, 32)})",
    );
  }
}
