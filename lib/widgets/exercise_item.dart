import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise.dart';

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final bool truncate;
  const ExerciseItem({Key? key, required this.exercise, this.truncate = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var style = TextStyle(fontSize: 16);
    final value = exercise is RepExercise
        ? l10n.exerciseRepsCount((exercise as RepExercise).reps)
        : l10n.exerciseDurationSec((exercise as DurationExercise).duration);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: 12),
            child: Text(
              exercise.name,
              style: style,
              maxLines: truncate ? 1 : null,
              overflow: truncate ? TextOverflow.ellipsis : null,
            ),
          ),
        ),
        Text(value, style: style)
      ],
    );
  }
}
