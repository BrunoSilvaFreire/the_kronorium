import 'package:flutter/material.dart';

class ContainerCard extends StatelessWidget {
  final double? elevation;
  final double maxWidth;
  final double minWidth;
  final Widget? child;
  final EdgeInsetsGeometry margin;
  final ShapeBorder? shape;

  const ContainerCard({
    super.key,
    this.child,
    this.maxWidth = 512,
    this.minWidth = 256,
    this.margin = const EdgeInsets.all(16),
    this.shape,
    this.elevation
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        minWidth: minWidth,
      ),
      child: Card.filled(
        elevation: elevation,
        shape: shape,
        margin: margin,
        child: child,
      ),
    );
  }
}
