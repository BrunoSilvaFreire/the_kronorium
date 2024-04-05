import 'package:flutter/material.dart';
import 'package:the_kronorium/easter_eggs.dart';
import 'dart:developer' as developer;

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
    var theme = Theme.of(context);
    Widget? leading;
    Widget? subtitle;

    var icon = step.tryFindIcon();
    if (icon != null) {
      leading = Icon(icon);
    } else {
      developer.log(
          "Step ${step.name} specified icon ${step.iconName}, but it was not found.",
          level: 2);
    }
    if (step.validIn.isNotEmpty) {
      var applicableIn = step.validIn.map((e) => e.name).join(", ");
      subtitle = Text("Only applicable in: $applicableIn");
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

    return Card.filled(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
