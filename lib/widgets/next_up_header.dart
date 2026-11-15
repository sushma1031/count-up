import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/offset_animated_text.dart';
import 'package:flutter/material.dart';

class NextUpHeader extends StatelessWidget {
  final String? nextName;
  final bool visible;

  const NextUpHeader({super.key, required this.nextName, this.visible = true});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox(height: 50);

    final l10n = AppLocalizations.of(context);
    return Transform.translate(
        offset: Offset(0, -PlaybackStyles.nextUpBottomOffset),
        child: SizedBox(
            height: 50,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child:
                    OffsetAnimatedText(nextName != null ? l10n.nextUp(nextName!) : l10n.lastOne))));
  }
}
