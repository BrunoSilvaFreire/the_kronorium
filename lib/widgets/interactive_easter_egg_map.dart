import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/graphs/adjacency_list.dart';
import 'package:the_kronorium/graphs/graph_layout.dart';
import 'package:the_kronorium/graphs/layered_graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:widget_arrows/widget_arrows.dart';

class InteractiveEasterEggMap extends ConsumerStatefulWidget {
  const InteractiveEasterEggMap({
    super.key,
    required this.layeredLayout,
    required this.layout,
    required this.selected,
    required this.spacing,
    required this.margin,
  });

  final double spacing;
  final EdgeInsets margin;
  final LayeredGraphLayout layeredLayout;
  final GraphWidgetBuilder layout;
  final StateProvider<Set<int>> selected;

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

  Iterable<Widget> _buildChildren(Set<int> selected) {
    var children = widget.layout.getChildren(
      selected,
      (index) {
        var newSet = {...selected};
        if (!newSet.remove(index)) {
          newSet.add(index);
        }
        ref.read(widget.selected.notifier).state = newSet;
      },
    );
    if (children.isEmpty) {
      return [];
    }
    return children.interleave((element) {
      return SizedBox(
        width: widget.spacing,
      );
    });
  }
}
