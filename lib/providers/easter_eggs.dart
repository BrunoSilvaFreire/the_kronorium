import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:the_kronorium/editing/editable_object.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/serialization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:the_kronorium/utils.dart';

part 'easter_eggs.g.dart';

abstract class AbstractEasterEggRegistry
    extends AsyncNotifier<List<EasterEgg>> {
  Future<List<EasterEgg>> loadEasterEggsFrom(
    Stream<Map<String, dynamic>> streams,
    bool editable,
  ) async {
    return streams.map(
      (event) {
        return EasterEgg.fromMap(event, editable);
      },
    ).toList();
  }
}

@Riverpod(keepAlive: true)
class EasterEggRegistry extends AbstractEasterEggRegistry {
  Stream<Map<String, dynamic>> loadEasterEggStreams() async* {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');

    final Map<String, dynamic> manifestMap = json.decode(manifestContent);

    final easterEggs = manifestMap.keys
        .where((String key) => key.contains('easter_eggs/'))
        .where((String key) => key.contains('.json'))
        .toList();

    for (var value in easterEggs) {
      Map<String, dynamic> entry = json.decode(
        await rootBundle.loadString(value, cache: false),
      );
      if (entry.optional<bool>("hidden") ?? false) {
        continue;
      }
      yield entry;
    }
  }

  @override
  FutureOr<List<EasterEgg>> build() {
    return loadEasterEggsFrom(loadEasterEggStreams(), false);
  }
}

enum StepEdgeKind {
  dependency,
  dependant,
}

typedef EasterEggStepGraph = AdjacencyList<EasterEggStep, StepEdgeKind>;

class EasterEgg {
  String name;
  String map;
  String thumbnailURL;
  final List<EasterEggStep> steps;
  Color color;
  EasterEggStepGraph? _cachedGraph;
  final bool editable;
  ZombiesEdition primaryEdition;

  EasterEgg({
    required this.name,
    required this.map,
    required this.thumbnailURL,
    required this.steps,
    required this.color,
    required this.primaryEdition,
    this.editable = false,
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

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'map': map,
      'thumbnail': thumbnailURL,
      'steps': steps
          .map(
            (e) => e.toMap(this),
          )
          .toList(),
      'color': color.value.toRadixString(16).padLeft(8, '0'),
      'edition': primaryEdition.name
    };
  }

  factory EasterEgg.fromMap(
    Map<String, dynamic> map,
    bool editable,
  ) {
    var serializedSteps = map.requireList<Map<String, dynamic>>("steps");

    var steps = serializedSteps.map((serialized) {
      List<int> dependencies = _extractDependencies(
        serialized,
        serializedSteps,
      );

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
      editable: editable,
      primaryEdition: map.requireEnum("edition", ZombiesEdition.values),
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

  static List<int> extractDependencies(
    Map<String, dynamic> serializedStep,
    List<EasterEggStep> allSteps,
  ) {
    var dependencyNames = serializedStep.optionalList<String>("dependencies");
    if (dependencyNames == null) {
      return List<int>.empty();
    }

    return dependencyNames
        .map((stepName) => findIndexOfStep(allSteps, stepName))
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

  static int findIndexOfStep(
    List<EasterEggStep> allSteps,
    String stepName,
  ) {
    var indexWhere = allSteps.indexWhere((step) => step.name == stepName);
    if (indexWhere == -1) {
      throw Exception("Unable to find step named $stepName");
    }
    return indexWhere;
  }

  EasterEgg copy(String newName) {
    return EasterEgg(
      name: newName,
      map: map,
      thumbnailURL: thumbnailURL,
      steps: steps.map((e) => e.copy()).toList(),
      color: color,
      primaryEdition: primaryEdition,
    );
  }

  void removeStep(EasterEggStep step) {
    var index = steps.indexWhere(
      (element) => element.name == step.name,
    );
    removeByIndex(index);
  }

  void removeByIndex(int index) {
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

  void removeAll(Set<int> selected) {
    var toRemove = selected.toList();
    toRemove.sort(
      (a, b) => b - a,
    );
    for (int index in toRemove) {
      removeByIndex(index);
    }
  }

  int addStep(EasterEggStep step) {
    var index = steps.length;
    steps.add(step);
    _cachedGraph = null;
    return index;
  }

  void invalidateCache(){
    _cachedGraph = null;
  }
}

enum ZombiesEdition {
  all,
  worldAtWar,
  blackOps1,
  blackOps2,
  ghosts,
  advancedWarfare,
  blackOps3,
  infiniteWarfare,
  blackOps4,
  worldWar2,
  blackOpsColdWar,
  vanguard,
  modernWarfare,
  blackOps6
}

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

  Map<String, dynamic> toMap() {
    return {
      'image': image.toString(),
      'notes': notes,
    };
  }
}

class EasterEggStep extends EditableObject {
  List<int> dependencies;
  final List<String> notes;
  final List<EasterEggGalleryEntry> gallery;
  final List<ZombiesEdition> validIn;

  String _summary;
  String? _iconName;
  EasterEggStepKind _kind;

  EasterEggStep({
    required super.name,
    required String summary,
    required String? iconName,
    required this.dependencies,
    required this.notes,
    required this.gallery,
    required this.validIn,
    required EasterEggStepKind kind,
  })  : _summary = summary,
        _iconName = iconName,
        _kind = kind;

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
      iconName: map.optional("iconName"),
      notes: map.optionalList("notes") ?? [],
      gallery: gallery,
      validIn: validIn,
      dependencies: dependencies,
      kind: kind,
    );
  }

  String get summary {
    return _summary;
  }

  String? get iconName {
    return _iconName;
  }

  EasterEggStepKind get kind {
    return _kind;
  }

  set summary(String value) {
    _summary = value;
    notifyListeners();
  }

  set iconName(String? value) {
    _iconName = value;
    notifyListeners();
  }

  set kind(EasterEggStepKind value) {
    _kind = value;
    notifyListeners();
  }

  Map<String, dynamic> toMap(EasterEgg easterEgg) {
    return {
      'name': name,
      'summary': summary,
      'iconName': iconName,
      'dependencies': dependencies.map((e) => easterEgg.steps[e].name).toList(),
      'notes': notes,
      'gallery': gallery.map((e) => e.toMap()).toList(),
      'validIn': validIn.map((e) => e.name).toList(),
      'kind': kind.name,
    };
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

  @override
  String toString() {
    return 'EasterEggStep{name: $name, summary: $summary}';
  }

  void removeDependency(int dependencyIndex) {
    dependencies.remove(dependencyIndex);
    notifyListeners();
  }

  void addDependency(int value) {
    dependencies.add(value);
    notifyListeners();
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
