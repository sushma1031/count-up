import 'package:test/test.dart';
import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/validate_exercise.dart';
import 'package:count_up/models/exercise_draft.dart';
import 'package:count_up/models/exercise_type.dart';
import 'package:count_up/gen/l10n/app_localizations_en.dart';

void main() {
  group('Utility functions work correctly', () {
    test('.formatDuration() formats duration correctly', () {
      var d = Duration(seconds: 60);
      expect(formatDuration(d), equals('01 : 00'));
      d = Duration(seconds: 45);
      expect(formatDuration(d), equals('45'));
    });
  });

  test('.validateExercise() validates exercise name and duration corrrectly',
      () {
    final validate = validateExercise(AppLocalizationsEn());

    ExerciseDraft draft(String name, String value) =>
        ExerciseDraft(name: name, value: value, type: ExerciseType.duration);

    expect(validate(draft("Crunches", "15")), null);
    expect(validate(draft("Crunches", "99")), null);

    expect(validate(draft("", "10")), "Fields cannot be empty");
    expect(validate(draft("  ", "10")), "Fields cannot be empty");
    expect(validate(draft("Crunches", "")), "Fields cannot be empty");
    expect(validate(draft("", "")), "Fields cannot be empty");

    expect(validate(draft("Crunches", "x")), "Duration must be in range [1, 999]");
    expect(validate(draft("Crunches", "0")), "Duration must be in range [1, 999]");
    expect(validate(draft("Crunches", "-1")), "Duration must be in range [1, 999]");
    expect(validate(draft("Crunches", "1000")), "Duration must be in range [1, 999]");
  });

  test('.validateExercise() validates reps with a distinct error message', () {
    final validate = validateExercise(AppLocalizationsEn());

    ExerciseDraft draft(String name, String value) =>
        ExerciseDraft(name: name, value: value, type: ExerciseType.rep);

    expect(validate(draft("Push-ups", "15")), null);
    expect(validate(draft("Push-ups", "999")), null);

    expect(validate(draft("Push-ups", "0")), "Reps must be in range [1, 999]");
    expect(validate(draft("Push-ups", "1000")), "Reps must be in range [1, 999]");
    expect(validate(draft("Push-ups", "x")), "Reps must be in range [1, 999]");
  });
}
