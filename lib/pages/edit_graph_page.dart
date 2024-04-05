import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/editor.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/widgets/interactive_easter_egg_map.dart';

class EditEasterEggPage extends ConsumerStatefulWidget {
  final EasterEgg easterEgg;

  const EditEasterEggPage(
    this.easterEgg, {
    super.key,
  });

  @override
  ConsumerState<EditEasterEggPage> createState() => _EditEasterEggPageState();
}

class _EditEasterEggPageState extends ConsumerState<EditEasterEggPage> {
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
        body: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 256, maxWidth: 356),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FloatingActionButton.extended(
                        elevation: 0,
                        backgroundColor: theme.colorScheme.onPrimaryContainer,
                        foregroundColor: theme.colorScheme.onPrimary,
                        onPressed: () {

                        },
                        icon: Icon(MdiIcons.plusCircle),
                        label: const Text("Add Step"),
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: InteractiveEasterEggMap(
                      color: theme.colorScheme.primary,
                      layout: layout,
                      selected: _selected,
                      spacing: spacing,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: Editor(
                      selected: Provider(
                        (_) {
                          if (selected == null) {
                            return null;
                          }
                          return graph.vertex(selected);
                        },
                      ),
                      onDelete: (EasterEggStep step) {
                        setState(() {
                          widget.easterEgg.remove(step);
                        });
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
