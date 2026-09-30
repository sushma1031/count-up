import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/utils/workout_constants.dart';

class ReverseCircularProgressIndicator extends StatelessWidget {
  final AnimationController controller;
  const ReverseCircularProgressIndicator({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color secondary =
        Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15);
    Color darkSurface = Theme.of(context).colorScheme.surface;
    return Container(
        width: PlaybackStyles.circleSize,
        height: PlaybackStyles.circleSize,
        child: CircularProgressIndicator(
          backgroundColor: Color.alphaBlend(secondary, darkSurface),
          color: Theme.of(context).colorScheme.secondary,
          strokeWidth: PlaybackStyles.circleStrokeWidth,
          value: 1 - controller.value,
          semanticsLabel: AppLocalizations.of(context).timeLeftSemanticLabel,
        ));
  }
}
