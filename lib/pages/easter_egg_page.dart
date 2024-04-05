import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/inspector.dart';
import 'package:the_kronorium/pages/edit_graph_page.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:the_kronorium/widgets/interactive_easter_egg_map.dart';
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
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EditEasterEggPage(
                        widget.easterEgg.copy(),
                      );
                    },
                  ),
                );
              },
              icon: Icon(MdiIcons.fileDocumentEdit),
              label: const Text("Edit a copy"),
            )
          ],
        ),
        body: Stack(
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
              child: Inspector(
                selected: Provider(
                  (ref) {
                    var selected = ref.watch(_selected);
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
}
