import './storage_service.dart';
import '../models/exercise.dart';
import '../models/workout.dart';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class WorkoutStorageService implements StorageService<Box<Workout>> {
  final String boxName;
  late Box<Workout> workouts;
  WorkoutStorageService(this.boxName);

  int get size => workouts.length;

  Future<void> loadData() async {
    try {
      workouts = await Hive.openBox<Workout>(boxName);
    } on HiveError catch (e, stackTrace) {
      debugPrint("Error: Could not load data from Hive: $e\n$stackTrace");
      rethrow;
    } on Exception catch (e, stackTrace) {
      debugPrint("Error: Could not load data from Hive: $e\n$stackTrace");
      rethrow;
    }
  }

  ValueListenable<Box<Workout>> getListenable() {
    return workouts.listenable();
  }

  List<Workout> getAllWorkouts() {
    return workouts.values.toList();
  }

  List<MapEntry<int, Workout>> getWorkoutEntries() {
    return workouts
        .toMap()
        .entries
        .map((e) => MapEntry(e.key as int, e.value))
        .toList();
  }

  List<String> getAllWorkoutNames() {
    return workouts.values.map((w) => w.name).toList();
  }

  Workout? getWorkout(int key) {
    var w = workouts.get(key);
    if (w == null) {
      print('Error: Workout with key $key not found.\n');
    }
    return w;
  }

  List<Exercise> getWorkoutExercises(int key) {
    return workouts.get(key)!.exercises;
  }

  Future<int> addWorkout(Workout workout) async {
    try {
      return await workouts.add(workout);
    } on Exception catch (ex, stackTrace) {
      debugPrint('Error: Could not add workout: $ex\n$stackTrace');
    }
    return -1;
  }

  Future<int> addManyWorkouts(List<Workout> workouts) async {
    int addedCount = 0;
    for (Workout wkt in workouts) {
      int result = await addWorkout(wkt);
      if (result != -1) addedCount++;
    }
    return addedCount;
  }

  Future<int> addEmptyWorkout(String name) async {
    return addWorkout(Workout(name, []));
  }

  Future<int> addManyEmptyWorkouts(List<String> names) async {
    int addedCount = 0;
    for (String name in names) {
      int result = await addEmptyWorkout(name);
      if (result != -1) addedCount++;
    }
    return addedCount;
  }

  Future<Workout?> updateWorkoutName(int key, String name) async {
    Workout? prev = workouts.get(key);
    if (prev == null) {
      debugPrint('Error: Workout with key $key not found.\n');
      return null;
    }
    prev.name = name;
    await prev.save();
    return prev;
  }

  Future<Workout?> addWorkoutExercises(int key, List<Exercise> toAdd) async {
    Workout? w = workouts.get(key);
    if (w == null) {
      debugPrint('Error: Workout with key $key not found.\n');
      return null;
    }
    w.exercises.addAll(toAdd);
    await w.save();
    return w;
  }

  Future<Workout?> updateWorkoutExercises(int key, List<Exercise> newExercises) async {
    Workout? w = getWorkout(key);
    if (w == null) {
      debugPrint('Error: Workout with key $key not found.\n');
      return null;
    }
    w.exercises = newExercises;
    await w.save();
    return w;
  }

  Future<void> deleteWorkout(int key) async {
    await workouts.delete(key);
  }

  Future<void> close() async {
    await workouts.close();
  }

  Future<void> clear() async {
    await workouts.clear();
  }

  Future<void> delete() async {
    await clear();
    await workouts.deleteFromDisk();
  }
}
