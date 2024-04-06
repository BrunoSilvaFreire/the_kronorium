import 'package:flutter/material.dart';
import 'package:the_kronorium/easter_eggs.dart';

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
