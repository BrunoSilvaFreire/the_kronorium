import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

const kCorsSolution =
    "Some images may not be available on web platforms due to CORS. Try using another url for this image if you're editing this easter egg, or use the desktop app.";

class ImageDownloadErrorIndicator extends StatelessWidget {
  final Axis axis;

  const ImageDownloadErrorIndicator({super.key, this.axis = Axis.vertical});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var children = [
      Icon(MdiIcons.imageOff, color: theme.disabledColor),
      Text(
        "Failed to load image",
        style: theme.textTheme.titleMedium,
      ),
      if (kIsWeb)
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            kCorsSolution,
            style: theme.textTheme.bodySmall,
          ),
        ),
    ];
    switch (axis) {
      case Axis.horizontal:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
      case Axis.vertical:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children,
        );
    }
  }
}
