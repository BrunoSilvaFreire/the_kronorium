import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/widgets/interactive_easter_egg_map.dart';

class GraphPage extends StatefulWidget {
  final EasterEgg easterEgg;
  final Widget Function(
    BuildContext context,
    InteractiveEasterEggMap map,
  ) builder;
  final StateProvider<int?> selectedProvider;
  final EdgeInsets mapMargin;
  final List<Widget>? actions;

  const GraphPage({
    super.key,
    required this.easterEgg,
    required this.builder,
    required this.selectedProvider,
    this.actions = const [],
    this.mapMargin = const EdgeInsets.all(8)
  });

  @override
  State<GraphPage> createState() => _BaseGraphPageState();
}

class _BaseGraphPageState extends State<GraphPage> {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: widget.easterEgg.color, brightness: Brightness.dark),
    );
    double spacing = 32;
    EasterEggStepGraph graph = widget.easterEgg.asGraph();
    var layout = GraphLayoutAlgorithm(
      graph: graph,
      color: theme.colorScheme.primary,
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
