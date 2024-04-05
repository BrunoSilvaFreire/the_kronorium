import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/serialization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:the_kronorium/utils.dart';

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
  final Color color;
  EasterEggStepGraph? _cachedGraph;

  EasterEgg({
    required this.name,
    required this.map,
    required this.thumbnailURL,
    required this.steps,
    required this.color,
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
      color: map.optionalOrDefault<Color>(
        "color",
        parseColor,
        Colors.red,
      ),
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
    var indexWhere = allSteps
        .indexWhere((element) => element.require<String>("name") == stepName);
    if (indexWhere == -1) {
      throw Exception("Unable to find step named $stepName");
    }
    return indexWhere;
  }

  EasterEgg copy() {
    return EasterEgg(
      name: name,
      map: map,
      thumbnailURL: thumbnailURL,
      steps: steps.map((e) => e.copy()).toList(),
      color: color,
    );
  }

  void remove(EasterEggStep step) {
    var index = steps.indexWhere(
      (element) => element.name == step.name,
    );
    steps.removeAt(index);
    for (var (i, step) in steps.indexed) {
      var patchedDependencies = <int>[];
      for (var dependency in step.dependencies) {
        if (dependency == index) {
          continue;
        }
        if (dependency > index) {
          patchedDependencies.add(dependency - 1);
        } else {
          patchedDependencies.add(dependency);
        }
      }
      step.dependencies = patchedDependencies;
    }
    _cachedGraph = null;
  }
}

enum ZombiesEdition { all, blackOps1, blackOps3 }

enum EasterEggStepKind { requirement, suggestion }

class EasterEggGalleryEntry {
  final Uri image;
  final List<String> notes;

  EasterEggGalleryEntry({
    required this.image,
    required this.notes,
  });

  factory EasterEggGalleryEntry.fromMap(Map<String, dynamic> serialized) {
    return EasterEggGalleryEntry(
      image: Uri.parse(serialized.require<String>("image")),
      notes: serialized.optionalList("notes") ?? [],
    );
  }

  EasterEggGalleryEntry copy() {
    return EasterEggGalleryEntry(image: image, notes: [...notes]);
  }
}

class EasterEggStep {
  final String name;
  final String summary;
  final String? iconName;
  List<int> dependencies;
  final List<String> notes;
  final List<EasterEggGalleryEntry> gallery;
  final List<ZombiesEdition> validIn;
  final EasterEggStepKind kind;

  EasterEggStep({
    required this.name,
    required this.summary,
    required this.iconName,
    required this.dependencies,
    required this.notes,
    required this.gallery,
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

    var serializedGallery = map.optionalList("gallery") ?? [];
    var gallery = serializedGallery
        .cast<Map<String, dynamic>>()
        .map(EasterEggGalleryEntry.fromMap)
        .toList();
    return EasterEggStep(
      name: map.require("name"),
      summary: map.require("summary"),
      iconName: map.optional("icon"),
      notes: map.optionalList("notes") ?? [],
      gallery: gallery,
      validIn: validIn,
      dependencies: dependencies,
      kind: kind,
    );
  }

  IconData? tryFindIcon() {
    var name = iconName;
    if (name != null) {
      return MdiIcons.fromString(name);
    }
    return null;
  }

  EasterEggStep copy() {
    return EasterEggStep(
      name: name,
      summary: summary,
      iconName: iconName,
      dependencies: [...dependencies],
      notes: [...notes],
      gallery: gallery.map((e) => e.copy()).toList(),
      validIn: [...validIn],
      kind: kind,
    );
  }
}
