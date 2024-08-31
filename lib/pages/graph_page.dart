import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/graphs/graph_layout.dart';
import 'package:the_kronorium/graphs/layered_graph_layout.dart';
import 'package:the_kronorium/widgets/interactive_easter_egg_map.dart';

class GraphPage extends StatefulWidget {
  final EasterEgg easterEgg;
  final Widget Function(
    BuildContext context,
    InteractiveEasterEggMap map,
  ) builder;
  final StateProvider<Set<int>> selectedProvider;
  final EdgeInsets mapMargin;
  final List<Widget>? actions;

  const GraphPage(
      {super.key,
      required this.easterEgg,
      required this.builder,
      required this.selectedProvider,
      this.actions = const [],
      this.mapMargin = const EdgeInsets.all(8)});

  @override
  State<GraphPage> createState() => _BaseGraphPageState();
}

class _BaseGraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    var baseTheme = Theme.of(context);
    var theme = baseTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: widget.easterEgg.color,
        brightness: baseTheme.brightness,
      ),
    );
    double spacing = 256;
    EasterEggStepGraph graph = widget.easterEgg.asGraph();
    var layout = GraphWidgetBuilder(
      layout: LayeredGraphLayout(graph: graph),
      baseColor: theme.colorScheme.primary,
      cardWidth: 256,
      levelSpacing: spacing,
      siblingSpacing: 256,
    );
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: _buildAppBar(),
        body: Builder(builder: (context) {
          return widget.builder(
            context,
            InteractiveEasterEggMap(
              layout: layout,
              selected: widget.selectedProvider,
              spacing: spacing,
              margin: widget.mapMargin,
              layeredLayout: LayeredGraphLayout(
                graph: graph,
              ),
            ),
          );
        }),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      flexibleSpace: FlexibleSpaceBar(
        title: Text("${widget.easterEgg.map} - ${widget.easterEgg.name}"),
        background: Stack(
          children: [
            Positioned.fill(
                child: Image.network(widget.easterEgg.thumbnailURL,
                    fit: BoxFit.cover)),
            const Positioned.fill(
                child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: FractionalOffset.centerLeft,
                    end: FractionalOffset.centerRight,
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    stops: [
                      0.2,
                      0.5,
                      .8
                    ]),
              ),
            )),
          ],
        ),
      ),
      actions: widget.actions,
    );
  }
}
