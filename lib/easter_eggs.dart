import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/serialization.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'easter_eggs.g.dart';

@riverpod
class EasterEggRegistry extends _$EasterEggRegistry {
  @override
  Future<List<EasterEgg>> build() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final easterEggs = manifestMap.keys
        .where((String key) => key.contains('easter_eggs/'))
        .where((String key) => key.contains('.json'))
        .toList();

    var loaded = await Future.wait(
      easterEggs.map((e) => rootBundle.loadString(e, cache: false)),
    );

    return loaded.map((e) => EasterEgg.fromMap(json.decode(e))).toList();
  }
}

enum StepEdgeKind {
  dependency,
  dependant,
}

typedef EasterEggStepGraph = AdjacencyList<EasterEggStep, StepEdgeKind>;

class EasterEgg {
  final String name;
  final String map;
  final String thumbnailURL;
  final List<EasterEggStep> steps;
  EasterEggStepGraph? _cachedGraph;

  EasterEgg({
    required this.name,
    required this.map,
    required this.thumbnailURL,
    required this.steps,
  });

  EasterEggStepGraph asGraph() {
    var graph = _cachedGraph;
    if (graph != null) {
      return graph;
    }

    _cachedGraph = graph = EasterEggStepGraph();
    var indexCache = <EasterEggStep, int>{};
    for (var step in steps) {
      indexCache[step] = graph.push(step);
    }
    for (var step in steps) {
      if (step.dependencies.isEmpty) {
        continue;
      }
      var from = indexCache[step]!;
      for (var dependency in step.dependencies) {
        var to = indexCache[steps[dependency]]!;
        graph.connect(from, to, StepEdgeKind.dependency);
        graph.connect(to, from, StepEdgeKind.dependant);
      }
    }
    return graph;
  }

  factory EasterEgg.fromMap(Map<String, dynamic> map) {
    var serializedSteps = map.requireList<Map<String, dynamic>>("steps");

    var steps = serializedSteps.map((serialized) {
      List<int> dependencies =
          _extractDependencies(serialized, serializedSteps);
      return EasterEggStep.fromMap(serialized, dependencies);
    }).toList();

    return EasterEgg(
      name: map.require<String>("name"),
      map: map.require<String>("map"),
      thumbnailURL: map.require<String>("thumbnail"),
      steps: steps,
    );
  }

  static List<int> _extractDependencies(
    Map<String, dynamic> serializedStep,
    List<Map<String, dynamic>> allSteps,
  ) {
    var dependencyNames = serializedStep.optionalList<String>("dependencies");
    if (dependencyNames == null) {
      return List<int>.empty();
    }

    return dependencyNames
        .map((stepName) => _findIndexOfStep(allSteps, stepName))
        .toList();
  }

  static int _findIndexOfStep(
    List<Map<String, dynamic>> allSteps,
    String stepName,
  ) {
    return allSteps
        .indexWhere((element) => element.require<String>("name") == stepName);
  }
}

enum ZombiesEdition { all, blackOps1, blackOps3 }

enum EasterEggStepKind { requirement, suggestion }

class EasterEggStep {
  final String name;
  final String summary;
  final String? iconName;
  final List<int> dependencies;
  final List<String> notes;
  final List<ZombiesEdition> validIn;
  final EasterEggStepKind kind;

  EasterEggStep({
    required this.name,
    required this.summary,
    required this.iconName,
    required this.dependencies,
    required this.notes,
    required this.validIn,
    required this.kind,
  });

  factory EasterEggStep.fromMap(
    Map<String, dynamic> map,
    List<int> dependencies,
  ) {
    List<ZombiesEdition> validIn;
    var editionLimits = map.optionalList<String>("validIn");
    if (editionLimits != null) {
      validIn = editionLimits
          .map((e) => enumByName(e, ZombiesEdition.values))
          .nonNulls
          .toList();
    } else {
      validIn = List.empty();
    }

    var kind = map.optionalOrDefault(
      "kind",
      (name) => enumByName(name, EasterEggStepKind.values),
      EasterEggStepKind.requirement,
    );

    return EasterEggStep(
      name: map.require("name"),
      summary: map.require("summary"),
      iconName: map.optional("icon"),
      notes: map.optionalList("notes") ?? [],
      validIn: validIn,
      dependencies: dependencies,
      kind: kind,
    );
  }
}
