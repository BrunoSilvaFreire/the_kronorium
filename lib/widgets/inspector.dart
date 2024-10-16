import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/utils.dart';

class Inspector extends ConsumerStatefulWidget {
  static const double maxWidth = 512;
  static const double minWidth = 256;
  final Provider<EasterEggStep> selected;
  final List<Widget> bottom;

  const Inspector(
      {super.key, required this.selected, this.bottom = const <Widget>[]});

  @override
  ConsumerState<Inspector> createState() => _InspectorState();
}

class _InspectorState extends ConsumerState<Inspector> {
  @override
  Widget build(BuildContext context) {
    var step = ref.watch(widget.selected);
    List<Widget> children;
    var theme = Theme.of(context);
    if (step.notes.isNotEmpty) {
      children = [
        for (var note in step.notes)
          Card.outlined(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                note,
                style: theme.textTheme.bodySmall,
              ),
            ),
          )
      ];
    } else {
      children = [
        const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("No additional notes added."),
          ),
        )
      ];
    }
      return  Column(
      children: [
        ListTile(
          leading: step.tryFindIcon()?.asIcon(),
          title: Text(step.summary),
        ),
        ...children,
        if (widget.bottom.isNotEmpty) ...[
          ButtonBar(
            children: widget.bottom,
          )
        ]
      ],
    );
  }
}
