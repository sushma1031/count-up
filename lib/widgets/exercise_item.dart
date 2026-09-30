import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise.dart';

class ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  const ExerciseItem({Key? key, required this.exercise}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    var style = TextStyle(fontSize: 16);
    final value = exercise is RepExercise
        ? l10n.exerciseRepsCount((exercise as RepExercise).reps)
        : l10n.exerciseDurationSec((exercise as DurationExercise).duration);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(exercise.name, style: style, overflow: TextOverflow.ellipsis)),
        Text(value, style: style)
      ],
    );
  }
}
