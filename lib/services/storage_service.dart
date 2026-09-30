import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

abstract class StorageService<T> {
  int get size;

  Future<void> loadData();
  ValueListenable<T> getListenable();
  List<Workout> getAllWorkouts();
  List<MapEntry<int, Workout>> getWorkoutEntries();
  List<String> getAllWorkoutNames();
  Workout? getWorkout(int key);
  List<Exercise> getWorkoutExercises(int key);
  Future<int> addEmptyWorkout(String name);
  Future<int> addManyEmptyWorkouts(List<String> names);
  Future<int> addWorkout(Workout workout);
  Future<int> addManyWorkouts(List<Workout> workouts);
  Future<Workout?> updateWorkoutName(int key, String name);
  Future<Workout?> addWorkoutExercises(int key, List<Exercise> toAdd);
  Future<Workout?> updateWorkoutExercises(int key, List<Exercise> newExercises);
  Future<void> deleteWorkout(int key);
  Future<void> close();
  Future<void> clear();
  Future<void> delete();
}
