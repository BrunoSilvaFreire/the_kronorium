import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/utils.dart';

class Inspector extends ConsumerStatefulWidget {
  static final double maxWidth = 512;
  static final double minWidth = 256;
  final Provider<EasterEggStep?> selected;

  const Inspector({
    super.key,
    required this.selected,
  });

  @override
  ConsumerState<Inspector> createState() => _InspectorState();
}

class _InspectorState extends ConsumerState<Inspector> {
  @override
  Widget build(BuildContext context) {
    var step = ref.watch(widget.selected);
    List<Widget> children;
    if (step == null) {
      children = [Text("Please click on a step to inspect it")];
    } else {
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
          const Expanded(
            child: Center(
              child: Text("No additional notes added."),
            ),
          )
        ];
      }
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: Inspector.maxWidth,
        minWidth: Inspector.minWidth,
      ),
      child: Card.filled(
        margin: EdgeInsets.all(32),
        child: Column(
          children: [
            ListTile(
              leading: step?.tryFindIcon()?.asIcon(),
              title: Text(step?.summary ?? "Inspector"),
            ),
            ...children
          ],
        ),
      ),
    );
  }
}
