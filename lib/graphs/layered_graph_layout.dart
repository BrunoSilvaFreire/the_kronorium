import 'dart:collection';

import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/graphs/graph_layout.dart';

sealed class SugiyamaNode<TVertex> {
  late double x, y;
}

class ActualNode<TVertex> extends SugiyamaNode<TVertex> {
  final TVertex wrapped;

  ActualNode(this.wrapped);

  @override
  String toString() {
    return 'ActualNode{wrapped: $wrapped}';
  }
}

class LayoutNode<TVertex> extends SugiyamaNode<TVertex> {
  final int forDestination;

  LayoutNode({required this.forDestination});

  @override
  String toString() {
    return 'LayoutNode{forDestination: $forDestination}';
  }
}

class SugiyamaGraph<TVertex, TEdge>
    extends AdjacencyList<SugiyamaNode<TVertex>, TEdge?> {}

/// Based on <href src="https://en.wikipedia.org/wiki/Layered_graph_drawing">
class LayeredGraphLayout {
  final EasterEggStepGraph _graph;

  late final _layoutGraph = _buildSugiyamaGraph();

  final _layers = <List<int>>[];
  final _vertexToLayer = <int, int>{};

  // (layer, destination) -> concentratorIndex
  final _concentrators = <(int, int), int>{};

  LayeredGraphLayout({required AdjacencyList<EasterEggStep, StepEdgeKind> graph}) : _graph = graph {
    _buildLayers();
    _layerPolish();
    _minimizeCrossings();
  }


  List<List<int>> get layers => _layers;

  SugiyamaGraph<EasterEggStep, StepEdgeKind> get graph => _layoutGraph;

  List<int> getLayer(int layer) {
    if (layer >= _layers.length) {
      List<int> currentLayer = [];
      _layers.add(currentLayer);
      return currentLayer;
    } else {
      return _layers[layer];
    }
  }

  void addLayoutVertices(
    int fromIndex,
    int toIndex,
    int layerIndex,
    int nextLayerIndex,
  ) {
    int referenceIndex = fromIndex;
    var direction = (nextLayerIndex - layerIndex).sign;
    for (int l = layerIndex; l != nextLayerIndex; l += direction) {
      var midwayIndex = _layoutGraph.push(
        LayoutNode(
          forDestination: toIndex,
        ),
      );

      var concentratorKey = (l, toIndex);
      _concentrators[concentratorKey] = midwayIndex;

      _vertexToLayer[midwayIndex] = l;
      _layers[l].add(midwayIndex);

      _layoutGraph.connect(referenceIndex, midwayIndex, StepEdgeKind.dependant);
      _layoutGraph.connect(
          midwayIndex, referenceIndex, StepEdgeKind.dependency);
      referenceIndex = midwayIndex;
    }
    _layoutGraph.connect(referenceIndex, toIndex, StepEdgeKind.dependant);
    _layoutGraph.connect(toIndex, referenceIndex, StepEdgeKind.dependency);
  }

  void _layerPolish() {
    // Check for dummy/intermediate steps
    for (var (layerIndex, layer) in _layers.indexed) {
      for (var fromIndex in [...layer]) {
        if (!_graph.exists(fromIndex)) {
          // Was added after
          continue;
        }
        var dependants = _graph
            .edgesFromEqualTo(
              fromIndex,
              StepEdgeKind.dependant,
            )
            .toList();

        var edge = StepEdgeKind.dependant;
        for (var toIndex in dependants) {
          var nextLayerIndex = _vertexToLayer[toIndex]!;
          var diff = nextLayerIndex - layerIndex;
          var hopsBetweenLayers = diff.abs();

          var needsIntermediateVertex = hopsBetweenLayers > 1;
          if (needsIntermediateVertex) {
            // Will be substituted by multiple vertices, one per in between layer.
            _layoutGraph.disconnect(fromIndex, toIndex);

            var existingConcentrator = _concentrators[(layerIndex, toIndex)];
            if (existingConcentrator != null) {
              _layoutGraph.connect(
                fromIndex,
                existingConcentrator,
                edge,
              );
            } else {
              addLayoutVertices(
                  fromIndex, toIndex, layerIndex + 1, nextLayerIndex);
            }
          }
        }
      }
    }
  }

  void _buildLayers() {
    var pending = Queue<(int, int)>();
    for (var (index, _) in getAllIndependentVertices(_graph)) {
      pending.add((index, 0));
    }

    while (pending.isNotEmpty) {
      var (index, layer) = pending.removeFirst();

      List<int> currentLayer = getLayer(layer);

      var preExistingLayer = _vertexToLayer[index];

      bool best = true;
      if (preExistingLayer != null) {
        if (preExistingLayer >= layer) {
          best = false;
        }
      }
      if (best) {
        if (preExistingLayer != null) {
          _layers[preExistingLayer].remove(index);
        }
        currentLayer.add(index);
        _vertexToLayer[index] = layer;
      }
      for (var (neighbor, edge) in _graph.edgesFrom(index)) {
        if (edge == StepEdgeKind.dependant) {
          pending.add((neighbor, layer + 1));
        }
      }
    }
  }

  SugiyamaGraph<EasterEggStep, StepEdgeKind> _buildSugiyamaGraph() {
    var other = SugiyamaGraph<EasterEggStep, StepEdgeKind>();
    for (var step in _graph.allVertices) {
      other.push(ActualNode(step));
    }
    for (var (index, step) in _graph.allVertices.indexed) {
      for (var (destination, edge) in _graph.edgesFrom(index)) {
        other.connect(index, destination, edge);
      }
    }
    return other;
  }

  void _minimizeCrossings() {
    const maxIterations = 32;

    bool improved = true;
    int iterations = 0;

    while (improved && iterations < maxIterations) {
      improved = false;
      for (var i = 1; i < _layers.length; i++) {
        var layer = _layers[i];
        var previousLayer = _layers[i - 1];
        var barycenters = <int, double>{};

        for (var vertex in layer) {
          var dependencies = _layoutGraph.edgesFromEqualTo(
            vertex,
            StepEdgeKind.dependency,
          );
          if (dependencies.isEmpty) {
            barycenters[vertex] = -1.0;
          } else {
            var indices = dependencies.map(previousLayer.indexOf).toList();
            double avg;
            if (indices.isNotEmpty) {
              avg = indices.reduce((a, b) => a + b) / indices.length;
            } else {
              avg = -1.0;
            }
            barycenters[vertex] = avg;
          }
        }

        var originalOrder = List.of(layer);
        layer.sort(
              (a, b) => barycenters[a]!.compareTo(barycenters[b]!),
        );
        if (!listEquals(originalOrder, layer)) {
          improved = true;
        }
      }
      iterations++;
    }
  }

  bool listEquals<T>(List<T> first, List<T> second) {
    if (first.length != second.length) return false;
    for (int i = 0; i < first.length; i++) {
      if (first[i] != second[i]) return false;
    }
    return true;
  }
}
