import 'package:flutter/material.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';

class EasterEggStepCard extends StatelessWidget {
  final EasterEggStep step;
  final bool isSelected;
  final VoidCallback onTap;
  final double maxImageHeight;

  const EasterEggStepCard({
    super.key,
    required this.step,
    required this.isSelected,
    required this.onTap,
    this.maxImageHeight = 196,
  });

  @override
  Widget build(BuildContext context) {
    Widget? leading;
    Widget? subtitle;

    var icon = step.tryFindIcon();
    if (icon != null) {
      leading = Icon(icon);
    }

    if (step.validIn.isNotEmpty) {
      var applicableIn = step.validIn.map((e) => e.name).join(", ");
      subtitle = Text("Only applicable in: $applicableIn");
    } else if (step.kind == EasterEggStepKind.suggestion){
      subtitle = const Text("This step is not required");
    }

    Widget? image;
    if (step.gallery.isNotEmpty) {
      var thumbnail = step.gallery.first;
      image = Ink.image(
        fit: BoxFit.cover,
        image: NetworkImage(
          thumbnail.image.toString(),
        ),
      );
    }

    return ListenableBuilder(
      builder: (BuildContext context, Widget? child) {
        var children = [
              ListTile(
                title: Text(step.summary),
                leading: leading,
                subtitle: subtitle,
                selected: isSelected,
              ),
              if (image != null)
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxImageHeight),
                  child: image,
                )
            ];
        var content = InkWell(
          onTap: onTap,
          child: Column(
            children: children,
          ),
        );
        switch (step.kind) {
          case EasterEggStepKind.requirement:
            return Card.filled(
              clipBehavior: Clip.antiAlias,
              child: content,
            );
          case EasterEggStepKind.suggestion:
            return Card.outlined(
              clipBehavior: Clip.antiAlias,
              child: content,
            );
        }
      },
      listenable: step,
    );
  }
}
