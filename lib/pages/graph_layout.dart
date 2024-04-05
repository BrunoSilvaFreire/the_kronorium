import 'package:flutter/material.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';
import 'package:the_kronorium/widgets/easter_egg_step_card.dart';
import 'package:widget_arrows/widget_arrows.dart';

class GraphLayoutAlgorithm {
  final EasterEggStepGraph graph;
  final _verticesGroupedByLevel = <int, List<(int, EasterEggStep)>>{};
  final _vertexToLevel = <int, int>{};

  Iterable<(int, EasterEggStep)> getAllIndependentVertices(
      EasterEggStepGraph graph) sync* {
    for (int i = 0; i < graph.size; i++) {
      bool hasDependency = graph.edgesFrom(i).any((element) {
        var (_, edge) = element;
        return edge == StepEdgeKind.dependency;
      });
      if (!hasDependency) {
        yield (i, graph.vertex(i)!);
      }
    }
  }

  GraphLayoutAlgorithm({required this.graph}) {
    for (var (index, step) in getAllIndependentVertices(graph)) {
      _recurse(0, index, step);
    }
  }

  void _recurse(int level, int index, EasterEggStep step) {
    var levelNodes = _verticesGroupedByLevel[level];
    if (levelNodes == null) {
      _verticesGroupedByLevel[level] = levelNodes = <(int, EasterEggStep)>[];
    }

    var preExistingLevel = _vertexToLevel[index];

    bool best = true;
    if (preExistingLevel != null) {
      if (preExistingLevel >= level) {
        best = false;
      }
    }
    if (best) {
      if (preExistingLevel != null) {
        _verticesGroupedByLevel[preExistingLevel]!.remove((index, step));
      }
      levelNodes.add((index, step));
      _vertexToLevel[index] = level;
    }
    for (var (neighbor, edge) in graph.edgesFrom(index)) {
      if (edge == StepEdgeKind.dependant) {
        _recurse(level + 1, neighbor, graph.vertex(neighbor)!);
      }
    }
  }

  Iterable<Widget> getChildren(
    int? selectedIndex,
    Color color,
    void Function(int index) onClicked,
    double cardWidth,
    double levelSpacing,
    double siblingSpacing,
  ) sync* {
    for (var pair in _verticesGroupedByLevel.entries) {
      yield Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (var (index, step) in pair.value)
            ArrowElement(
              show: true,
              id: step.name,
              bow: 0,
              stretch: 0,
              color: color,
              targetAnchor: Alignment.centerLeft,
              sourceAnchor: Alignment.centerRight,
              straights: true,
              targetIds: [
                ...graph.edgesFrom(index).where((element) {
                  var (_, edge) = element;
                  return edge == StepEdgeKind.dependant;
                }).map((e) => graph.vertex(e.$1)!.name)
              ],
              child: SizedBox(
                width: cardWidth,
                child: EasterEggStepCard(
                  step: step,
                  isSelected: index == selectedIndex,
                  maxImageHeight: cardWidth * (9.0 / 16.0),
                  onTap: () {
                    onClicked(index);
                  },
                ),
              ),
            ),
        ],
      );
    }
  }
}
