import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class DeletionSnapshot {
  final Map<String, dynamic> serialized;
  final List<String> dependants;

  DeletionSnapshot({
    required this.serialized,
    required this.dependants,
  });
}

class DeleteStepsCommand extends SnapshotCommand<List<DeletionSnapshot>> {
  Set<int> _toDelete;

  DeleteStepsCommand(this._toDelete);

  @override
  List<DeletionSnapshot> applyWithSnapshot(EasterEgg easterEgg) {
    var steps = _toDelete
        .map(
          (i) => easterEgg.steps[i].toMap(easterEgg),
        )
        .toList();
    easterEgg.removeAll(_toDelete);
    return steps
        .map((e) => DeletionSnapshot(serialized: e, dependants: []))
        .toList();
  }

  @override
  void undoWithSnapshot(
    EasterEgg easterEgg,
    List<DeletionSnapshot> snapshot,
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
