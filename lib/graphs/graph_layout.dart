import 'package:flutter/material.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/graphs/layered_graph_layout.dart';
import 'package:the_kronorium/widgets/easter_egg_step_card.dart';
import 'package:widget_arrows/widget_arrows.dart';

Iterable<(int, EasterEggStep)> getAllIndependentVertices(
  EasterEggStepGraph graph,
) sync* {
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

class GraphWidgetBuilder {
  LayeredGraphLayout layout;
  Color baseColor;
  final Widget Function(int index, Widget child)? transformer;
  double cardWidth;
  double levelSpacing;
  double siblingSpacing;

  GraphWidgetBuilder({
    required this.layout,
    required this.baseColor,
    required this.cardWidth,
    required this.levelSpacing,
    required this.siblingSpacing,
    this.transformer,
  });

  Iterable<Widget> getChildren(
    Set<int> selectedIndex,
    void Function(int index) onClicked,
  ) sync* {

    var graph = layout.graph;
    for (var layer in layout.layers) {
      yield Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.max,
        children: [
          for (var (index, node) in layer.map(
            (e) => (e, graph.vertex(e)),
          ))
            switch (node) {
              ActualNode() => ArrowElement(
                  show: true,
                  id: index.toString(),
                  bow: 0,
                  stretch: 0,
                  color: baseColor,
                  targetAnchor: Alignment.centerLeft,
                  sourceAnchor: Alignment.centerRight,
                  straights: true,
                  targetIds: [
                    ...graph
                        .edgesFromEqualTo(index, StepEdgeKind.dependant)
                        .map(
                          (e) => e.toString(),
                        )
                  ],
                  child: SizedBox(
                    width: cardWidth,
                    child: EasterEggStepCard(
                      step: node.wrapped,
                      isSelected: selectedIndex.contains(index),
                      maxImageHeight: cardWidth * (9.0 / 16.0),
                      onTap: () {
                        onClicked(index);
                      },
                    ),
                  ),
                ),
              LayoutNode() => ArrowElement(
                  show: true,
                  id: index.toString(),
                  bow: 0,
                  stretch: 0,
                  color: baseColor,
                  targetAnchor: Alignment.centerLeft,
                  sourceAnchor: Alignment.centerLeft,
                  straights: true,
                  targetIds: [
                    ...graph
                        .edgesFromEqualTo(index, StepEdgeKind.dependant)
                        .map(
                          (e) => e.toString(),
                        )
                  ],
                  child: const SizedBox(
                    width: 32,
                    height: 64,
                  ),
                ),
              _ => throw UnimplementedError(),
            }
        ],
      );
    }
  }
}
