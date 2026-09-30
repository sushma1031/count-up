import 'package:flutter/widgets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise_draft.dart';
import 'package:count_up/models/exercise_type.dart';

const int minExerciseValue = 1;
const int maxExerciseValue = 999;

FormFieldValidator<ExerciseDraft> validateExercise(AppLocalizations l10n) {
  return (ExerciseDraft? value) {
    if (value == null || value.name.trim().isEmpty || value.value.isEmpty)
      return l10n.fieldsCannotBeEmpty;
    var num = int.tryParse(value.value);
    if (num == null || num < minExerciseValue || num > maxExerciseValue)
      return value.type == ExerciseType.rep
          ? l10n.repsRangeError
          : l10n.durationRangeError;

    return null;
  };
}
