import 'package:count_up/models/workout.dart';

class WorkoutDisplay {
  final int key;
  final String name;
  final int noOfExercises;
  final int totalDuration;

  WorkoutDisplay(this.key, this.name, this.noOfExercises, this.totalDuration);
}

List<WorkoutDisplay> workoutDisplaysFrom(List<MapEntry<int, Workout>> entries) {
  return entries.map((entry) {
    final workout = entry.value;
    final totalSeconds = workout.exercises.fold<int>(0, (sum, ex) => sum + ex.duration);
    return WorkoutDisplay(
      entry.key,
      workout.name,
      workout.exercises.length,
      (totalSeconds / 60).ceil(),
    );
  }).toList();
}
