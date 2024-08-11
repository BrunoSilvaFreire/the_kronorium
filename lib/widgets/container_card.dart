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
    this.elevation,
  });

  ContainerCard.leftSideContainer({
    Key? key,
    required List<Widget> children,
  }) : this(
          key: key,
          elevation: 12,
          margin: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            right: 16,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        );

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
