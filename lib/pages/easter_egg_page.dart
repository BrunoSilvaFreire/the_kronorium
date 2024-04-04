import 'package:flutter/material.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:widget_arrows/arrows.dart';
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
      _verticesGroupedByLevel[level] = levelNodes = <(int,EasterEggStep)>[];

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
    double cardWidth,
    double levelSpacing,
    double siblingSpacing,
  ) sync* {
    for (var pair in _verticesGroupedByLevel.entries) {
      int level = pair.key;
      yield Positioned(
        top: 0,
        bottom: 0,
        left: level * (cardWidth + levelSpacing),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            for (var (index, step) in pair.value)

              ArrowElement(
                show: true,
                id: step.name,
                color: Colors.red,
                targetAnchor: Alignment.centerLeft,
                sourceAnchor: Alignment.centerRight,
                straights: true,
                targetIds: [
                  ...graph
                      .edgesFrom(index)
                      .where((element) {
                        var (_, edge) = element;
                        return edge == StepEdgeKind.dependant;
                      })
                      .map((e) => graph.vertex(e.$1)!.name)
                ],
                child: SizedBox(
                  width: cardWidth,
                  child: EasterEggStepCard(
                    step: step,
                  ),
                ),
              ),
          ],
        ),
      );
    }
  }
}

class EasterEggPage extends StatefulWidget {
  final EasterEgg easterEgg;

  const EasterEggPage(
    this.easterEgg, {
    super.key,
  });

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  @override
  Widget build(BuildContext context) {
    EasterEggStepGraph graph = widget.easterEgg.asGraph();
    var layout = GraphLayoutAlgorithm(graph: graph);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          title: Text("${widget.easterEgg.map} - ${widget.easterEgg.name}"),
          background: Image.network(
            widget.easterEgg.thumbnailURL,
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: ArrowContainer(
        child: InteractiveViewer(
          child: Stack(
            children: [
              ...layout.getChildren(
                256,
                32,
                256,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EasterEggStepCard extends StatelessWidget {
  final EasterEggStep step;

  const EasterEggStepCard({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: Border.all(color: Colors.transparent),
        title: Text(
          step.summary,
          style: theme.textTheme.titleMedium,
        ),
        children: [
          for (var note in step.notes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  note,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            )
        ],
      ),
    );
  }
}
