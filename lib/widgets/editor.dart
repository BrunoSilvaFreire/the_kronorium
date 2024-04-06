import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/widgets/inspector.dart';

class Editor extends ConsumerWidget {
  final Provider<EasterEggStep?> selected;
  final void Function(EasterEggStep step) onDelete;

  const Editor({
    super.key,
    required this.selected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var actual = ref.watch(selected);
    return Inspector(
      selected: selected,
      bottom: [
        TextButton.icon(
          onPressed: actual == null ? null : () {
            onDelete(actual);
          },
          icon: Icon(MdiIcons.delete),
          label: const Text("Delete step"),
        )
      ],
    );
  }
}
