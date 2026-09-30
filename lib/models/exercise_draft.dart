import 'exercise.dart';
import 'exercise_type.dart';

class ExerciseDraft {
  final String name;
  final String value;
  final ExerciseType type;

  const ExerciseDraft({
    required this.name,
    required this.value,
    required this.type,
  });

  factory ExerciseDraft.fromExercise(Exercise exercise) {
    if (exercise is RepExercise) {
      return ExerciseDraft(
          name: exercise.name, value: '${exercise.reps}', type: ExerciseType.rep);
    }
    if (exercise is DurationExercise) {
      return ExerciseDraft(
          name: exercise.name, value: '${exercise.duration}', type: ExerciseType.duration);
    }
    throw ArgumentError('Unsupported exercise: ${exercise.runtimeType}');
  }

  /// Assumes the draft has passed [validateExercise].
  Exercise toExercise() {
    final parsed = int.parse(value);
    return type == ExerciseType.rep ? RepExercise(name, parsed) : DurationExercise(name, parsed);
  }

  ExerciseDraft copyWith({String? name, String? value}) {
    return ExerciseDraft(
      name: name ?? this.name,
      value: value ?? this.value,
      type: type,
    );
  }
}
