import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';

enum WorkoutComposition { duration, rep, mixed }

class WorkoutDisplay {
  final int key;
  final String name;
  final int noOfExercises;
  final int? totalDuration;
  final WorkoutComposition composition;

  WorkoutDisplay({
    required this.key,
    required this.name,
    required this.noOfExercises,
    this.totalDuration,
    required this.composition,
  });
}

List<WorkoutDisplay> workoutDisplaysFrom(List<MapEntry<int, Workout>> entries) {
  return entries.map((entry) {
    final workout = entry.value;
    final totalSeconds = workout.exercises.fold<int>(
      0,
      (sum, ex) => sum + (ex is DurationExercise ? ex.duration : 0),
    );

    bool hasDuration = false;
    bool hasRep = false;

    for (final ex in workout.exercises) {
      if (ex is DurationExercise) hasDuration = true;
      if (ex is RepExercise) hasRep = true;

      if (hasDuration && hasRep) break;
    }

    final composition = (hasDuration && hasRep)
        ? WorkoutComposition.mixed
        : (hasRep ? WorkoutComposition.rep : WorkoutComposition.duration);
    return WorkoutDisplay(
      key: entry.key,
      name: workout.name,
      noOfExercises: workout.exercises.length,
      totalDuration: hasDuration ? (totalSeconds / 60).ceil() : null,
      composition: composition,
    );
  }).toList();
}
