import 'package:flutter/foundation.dart';
import 'package:count_up/services/storage_service.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';

class WorkoutListValueNotifier extends ValueNotifier<List<Workout>> {
  WorkoutListValueNotifier(List<Workout> value) : super(value);

  void update(List<Workout> newWorkouts) {
    value = newWorkouts;
    notifyListeners();
  }
}

class MockStorageService implements StorageService<List<Workout>> {
  final WorkoutListValueNotifier notifier = WorkoutListValueNotifier([]);

  Map<int, Workout> workoutsMap = {};
  int _nextKey = 0;

  /// Tracks calls that changed stored workouts - does not include seeding and
  /// direct modifications of the map.
  int writes = 0;

  int get size => workoutsMap.length;

  Future<void> loadData() async {
    var e = [DurationExercise('Plank', 10), DurationExercise('Crunches', 5)];
    workoutsMap = {};
    _nextKey = 0;
    _add(Workout('Abs', e));
    _add(Workout('Thighs', e));
    _notify();
  }

  int _add(Workout workout) {
    final key = _nextKey++;
    workoutsMap[key] = workout;
    return key;
  }

  void _notify() {
    notifier.update(workoutsMap.values.toList());
  }

  @override
  ValueListenable<List<Workout>> getListenable() {
    return notifier;
  }

  List<Workout> getAllWorkouts() {
    return workoutsMap.values.toList();
  }

  List<MapEntry<int, Workout>> getWorkoutEntries() {
    return workoutsMap.entries.toList();
  }

  List<String> getAllWorkoutNames() {
    return workoutsMap.values.map((w) => w.name).toList();
  }

  Workout? getWorkout(int key) {
    var w = workoutsMap[key];
    if (w == null) {
      print('Error: Workout with key $key not found.\n');
    }
    return w;
  }

  List<Exercise> getWorkoutExercises(int key) {
    return workoutsMap[key]!.exercises;
  }

  Future<int> addEmptyWorkout(String name) async {
    return addWorkout(Workout(name, []));
  }

  Future<int> addManyEmptyWorkouts(List<String> names) async {
    for (String name in names) await addEmptyWorkout(name);
    return Future.value(names.length);
  }

  Future<int> addWorkout(Workout wkt) async {
    writes++;
    final key = _add(wkt);
    _notify();
    return Future.value(key);
  }

  Future<int> addManyWorkouts(List<Workout> wkts) async {
    for (Workout wkt in wkts) await addWorkout(wkt);
    return Future.value(wkts.length);
  }

  Future<Workout?> updateWorkoutName(int key, String name) async {
    final w = workoutsMap[key];
    if (w == null) return null;
    writes++;
    w.name = name;
    _notify();
    return Future.value(w);
  }

  Future<Workout?> addWorkoutExercises(int key, List<Exercise> toAdd) async {
    final w = workoutsMap[key];
    if (w == null) return null;
    writes++;
    w.exercises.addAll(toAdd);
    _notify();
    return Future.value(w);
  }

  Future<Workout?> updateWorkoutExercises(
      int key, List<Exercise> newExercises) async {
    final w = workoutsMap[key];
    if (w == null) return null;
    writes++;
    w.exercises = newExercises;
    _notify();
    return Future.value(w);
  }

  Future<void> deleteWorkout(int key) async {
    writes++;
    workoutsMap.remove(key);
    _notify();
    return Future.value();
  }

  Future<void> close() async {
    workoutsMap = {};
    _notify();
    return Future.value();
  }

  Future<void> clear() async {
    writes++;
    workoutsMap = {};
    _notify();
    return Future.value();
  }

  Future<void> delete() async {
    writes++;
    workoutsMap = {};
    _notify();
    return Future.value();
  }
}
