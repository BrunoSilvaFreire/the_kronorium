import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/inspector.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:widget_arrows/widget_arrows.dart';
import 'dart:developer' as developer;

class EasterEggPage extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;

  const EasterEggPage(
    this.easterEgg, {
    super.key,
  });

  @override
  ConsumerState<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends ConsumerState<EasterEggPage> {
  late final _selected = StateProvider<int?>(
    (ref) => null,
  );

  @override
  Widget build(BuildContext context) {
    EasterEggStepGraph graph = widget.easterEgg.asGraph();
    var layout = GraphLayoutAlgorithm(graph: graph);
    var selected = ref.watch(_selected);
    double spacing = 32;
    var theme = Theme.of(context).copyWith(
      colorScheme: ColorScheme.fromSeed(
          seedColor: widget.easterEgg.color, brightness: Brightness.dark),
    );
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          flexibleSpace: FlexibleSpaceBar(
            title: Text("${widget.easterEgg.map} - ${widget.easterEgg.name}"),
            background: Image.network(
              widget.easterEgg.thumbnailURL,
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildMap(theme.colorScheme.primary, layout, selected, spacing),
            ),
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Inspector(
                selected: Provider(
                  (_) {
                    if (selected == null) {
                      return null;
                    }
                    return graph.vertex(selected);
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  ArrowContainer _buildMap(
    Color color,
    GraphLayoutAlgorithm layout,
    int? selected,
    double spacing,
  ) {
    return ArrowContainer(
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(8),
        constrained: false,
        minScale: 0.1,
        child: Row(
          children: [
            ...layout.getChildren(
              selected,
              color,
              (index) {
                ref.read(_selected.notifier).state = index;
              },
              256,
              spacing,
              256,
            ).interleave((element) {
              return SizedBox(
                width: spacing,
              );
            }),
            Container(
              width: 512,
            )
          ],
        ),
      ),
    );
  }
}
