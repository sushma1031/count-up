import 'package:flutter/material.dart';

class CircleOutline extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;

  const CircleOutline(
      {Key? key, required this.size, required this.strokeWidth, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color ?? Theme.of(context).colorScheme.secondary,
          width: strokeWidth,
          // Matches [CircularProgressIndicator], which centres its stroke on the edge.
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
    );
  }
}
