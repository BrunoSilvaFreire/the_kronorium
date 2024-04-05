import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/pages/easter_egg_page.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:widget_arrows/widget_arrows.dart';

class InteractiveEasterEggMap extends ConsumerStatefulWidget {
  const InteractiveEasterEggMap({
    super.key,
    required this.color,
    required this.layout,
    required this.selected,
    required this.spacing,
  });

  final double spacing;
  final Color color;
  final GraphLayoutAlgorithm layout;
  final StateProvider<int?> selected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _InteractiveEasterEggMapState();
  }
}

class _InteractiveEasterEggMapState
    extends ConsumerState<InteractiveEasterEggMap> {
  @override
  Widget build(BuildContext context) {
    var selected = ref.watch(widget.selected);
    return ArrowContainer(
      child: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(8),
        constrained: false,
        minScale: 0.1,
        child: Row(
          children: [
            ...widget.layout.getChildren(
              selected,
              widget.color,
              (index) {
                ref.read(widget.selected.notifier).state = index;
              },
              256,
              widget.spacing,
              256,
            ).interleave((element) {
              return SizedBox(
                width: widget.spacing,
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
