import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/utils/workout_constants.dart';

class ReverseCircularProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  const ReverseCircularProgressIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    Color secondary =
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15);
    Color darkSurface = Theme.of(context).colorScheme.surface;
    final backgroundColor = Color.alphaBlend(secondary, darkSurface);
    final color = Theme.of(context).colorScheme.secondary;
    final semanticsLabel = AppLocalizations.of(context).timeLeftSemanticLabel;
    return Container(
        width: PlaybackStyles.circleSize,
        height: PlaybackStyles.circleSize,
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) => CircularProgressIndicator(
            backgroundColor: backgroundColor,
            color: color,
            strokeWidth: PlaybackStyles.circleStrokeWidth,
            value: 1 - controller.value,
            semanticsLabel: semanticsLabel,
          ),
        ));
  }
}
