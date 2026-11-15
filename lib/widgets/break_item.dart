import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class BreakIcon extends StatelessWidget {
  const BreakIcon({super.key});

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.timer_outlined, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant);
}

class BreakItem extends StatelessWidget {
  final int seconds;
  final bool isDefault;
  final Widget? leading;

  const BreakItem({super.key, required this.seconds, required this.isDefault, this.leading});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    const style = TextStyle(fontSize: 16);

    final leading = this.leading;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null)
          Padding(
            // Centres a 20px icon on the first line of text.
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: leading,
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.breakDurationLabel, style: style),
              if (isDefault)
                Text(
                  l10n.breakDurationDefaultHint,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
        Text(l10n.exerciseDurationSec(seconds), style: style),
      ],
    );
  }
}
