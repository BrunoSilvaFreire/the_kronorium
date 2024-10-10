
import 'package:flutter/material.dart';
import 'package:the_kronorium/providers/easter_eggs.dart';
import 'package:the_kronorium/widgets/image_download_error_indicator.dart';

class EasterEggStepCard extends StatefulWidget {
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
  State<EasterEggStepCard> createState() => _EasterEggStepCardState();
}

class _EasterEggStepCardState extends State<EasterEggStepCard> {
  dynamic _imageError;
  @override
  Widget build(BuildContext context) {
    Widget? leading;
    Widget? subtitle;

    var icon = widget.step.tryFindIcon();
    if (icon != null) {
      leading = Icon(icon);
    }

    if (widget.step.validIn.isNotEmpty) {
      var applicableIn = widget.step.validIn.map((e) => e.name).join(", ");
      subtitle = Text("Only applicable in: $applicableIn");
    } else if (widget.step.kind == EasterEggStepKind.suggestion) {
      subtitle = const Text("This step is not required");
    }

    Widget? image;
    if (widget.step.gallery.isNotEmpty) {
      var thumbnail = widget.step.gallery.first;
      if (_imageError != null) {
        image = ImageDownloadErrorIndicator();
      } else {
        image = Ink.image(
          fit: BoxFit.cover,
          onImageError: (exception, stackTrace) {
            setState(() {
              _imageError = exception;
            });
          },
          image: NetworkImage(
            thumbnail.image.toString(),
          ),
        );
      }
    }

    return ListenableBuilder(
      builder: (BuildContext context, Widget? child) {
        var children = [
          ListTile(
            title: Text(widget.step.summary),
            leading: leading,
            subtitle: subtitle,
            selected: widget.isSelected,
          ),
          if (image != null)
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.maxImageHeight,
                minHeight: widget.maxImageHeight / 2,
              ),
              child: image,
            )
        ];
        var content = InkWell(
          onTap: widget.onTap,
          child: Column(
            children: children,
          ),
        );
        switch (widget.step.kind) {
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
      listenable: widget.step,
    );
  }

}
