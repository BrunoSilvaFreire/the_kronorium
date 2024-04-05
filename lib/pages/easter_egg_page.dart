import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'package:the_kronorium/pages/graph_layout.dart';
import 'package:the_kronorium/utils.dart';
import 'package:widget_arrows/widget_arrows.dart';
import 'dart:developer' as developer;

class EasterEggPage extends StatefulWidget {
  final EasterEgg easterEgg;

  const EasterEggPage(
    this.easterEgg, {
    super.key,
  });

  @override
  State<EasterEggPage> createState() => _EasterEggPageState();
}

class _EasterEggPageState extends State<EasterEggPage> {
  @override
  Widget build(BuildContext context) {
    EasterEggStepGraph graph = widget.easterEgg.asGraph();
    var layout = GraphLayoutAlgorithm(graph: graph);

    double spacing = 32;
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: FlexibleSpaceBar(
          title: Text("${widget.easterEgg.map} - ${widget.easterEgg.name}"),
          background: Image.network(
            widget.easterEgg.thumbnailURL,
            fit: BoxFit.cover,
          ),
        ),
      ),
      body: ArrowContainer(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(8),
          constrained: false,
          child: Row(
            children: [
              ...layout
                  .getChildren(
                256,
                spacing,
                256,
              )
                  .interleave((element) {
                return SizedBox(
                  width: spacing,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class EasterEggStepCard extends StatelessWidget {
  final EasterEggStep step;

  const EasterEggStepCard({super.key, required this.step});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    Widget child = Text(
      step.summary,
      style: theme.textTheme.titleMedium,
    );

    Widget? leading;
    Widget? subtitle;

    var iconName = step.iconName;
    if (iconName != null) {
      var icon = MdiIcons.fromString(iconName);
      if (icon != null) {
        leading = Icon(icon);
      } else {
        developer.log(
            "Step ${step.name} specified icon ${step.iconName}, but it was not found.",
            level: 2);
      }
    }
    if(step.validIn.isNotEmpty){
      var applicableIn = step.validIn.map((e) => e.name).join(", ");
      subtitle = Text("Only applicable in: ${applicableIn}");
    }
    if (step.notes.isNotEmpty) {
      child = ExpansionTile(
        shape: Border.all(color: Colors.transparent),
        leading: leading,
        title: child,
        subtitle: subtitle,
        children: [
          for (var note in step.notes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  note,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            )
        ],
      );
    } else {
      child = ListTile(
        title: child,
        leading: leading,
        subtitle: subtitle,
      );
    }

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
