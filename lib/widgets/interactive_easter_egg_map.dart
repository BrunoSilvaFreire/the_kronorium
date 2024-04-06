import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:widget_arrows/widget_arrows.dart';

class InteractiveEasterEggMap extends ConsumerStatefulWidget {
  const InteractiveEasterEggMap({
    super.key,
    required this.layout,
    required this.selected,
    required this.spacing,
    required this.margin,
  });

  final double spacing;
  final EdgeInsets margin;
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
        boundaryMargin: widget.margin,
        constrained: false,
        minScale: 0.1,
        child: Row(
          children: [
            ..._buildChildren(selected),
            Container(
              width: 512,
            )
          ],
        ),
      ),
    );
  }

  Iterable<Widget> _buildChildren(int? selected) {
    return widget.layout.getChildren(
      selected,
      (index) {
        ref.read(widget.selected.notifier).state = index;
      },
    ).interleave((element) {
      return SizedBox(
        width: widget.spacing,
      );
    });
  }
}
