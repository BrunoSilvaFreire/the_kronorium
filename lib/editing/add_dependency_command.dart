import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/editing/command.dart';
import 'package:the_kronorium/label.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class AddDependenciesCommand extends SnapshotCommand<List<String>> {
  final EasterEggStep step;
  List<int> dependenciesToAdd;

  AddDependenciesCommand(this.step, this.dependenciesToAdd);

  @override
  List<String> applyWithSnapshot(EasterEgg easterEgg) {
    var steps = dependenciesToAdd.map(
          (e) => easterEgg.steps[e],
    );
    for (var value in dependenciesToAdd) {
      step.addDependency(value);
    }
    easterEgg.invalidateCache();
    return steps
        .map(
          (e) => e.name,
    )
        .toList();
  }

  @override
  Label getLabel() {
    return Label(MdiIcons.graph,
        "Add ${dependenciesToAdd.length} dependencies to ${step.name}");
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, List<String> stepNames) {
    dependenciesToAdd = stepNames.map(
          (e) =>
          easterEgg.steps.indexWhere(
                (element) => element.name == e,
          ),
    ).toList();
    for (var value in dependenciesToAdd) {
      step.removeDependency(value);
    }
    easterEgg.invalidateCache();
  }
}

class RemoveDependenciesCommand extends SnapshotCommand<List<String>> {
  final EasterEggStep step;
  List<int> dependenciesToRemove;

  RemoveDependenciesCommand(this.step, this.dependenciesToRemove);

  @override
  List<String> applyWithSnapshot(EasterEgg easterEgg) {
    var steps = dependenciesToRemove.map(
          (e) => easterEgg.steps[e],
    );
    for (var value in dependenciesToRemove) {
      step.removeDependency(value);
    }
    easterEgg.invalidateCache();
    return steps
        .map(
          (e) => e.name,
    )
        .toList();
  }

  @override
  Label getLabel() {
    return Label(MdiIcons.graphOutline,
        "Remove ${dependenciesToRemove.length} dependencies from ${step.name}");
  }

  @override
  void undoWithSnapshot(EasterEgg easterEgg, List<String> stepNames) {
    dependenciesToRemove = stepNames.map(
          (e) =>
          easterEgg.steps.indexWhere(
                (element) => element.name == e,
          ),
    ).toList();
    for (var value in dependenciesToRemove) {
      step.addDependency(value);
    }
    easterEgg.invalidateCache();
  }
}