import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:count_up/services/workout_storage_service.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  Hive.init(Directory.systemTemp.path);
  Hive.registerAdapter(DurationExerciseAdapter());
  Hive.registerAdapter(RepExerciseAdapter());
  Hive.registerAdapter(WorkoutAdapter());

  TestWidgetsFlutterBinding.ensureInitialized();
  String box = 'testBox';

  tearDownAll(() async {
    await Hive.close();
  });

  WorkoutStorageService db = WorkoutStorageService(box);
  await db.loadData();
  test('clears box successfully', () async {
    await db.clear();
    expect(db.getAllWorkouts().length, 0);
  });

  test('adds workouts correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(db.getWorkout(0)!.name, 'Abs');

    await db.addManyEmptyWorkouts(['Thighs', 'Biceps']);
    var workoutNames = db.getAllWorkoutNames();
    expect(workoutNames.length, 3);
    expect(workoutNames, ['Abs', 'Thighs', 'Biceps']);
  });

  test('updates workout name correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    expect(db.getAllWorkouts()[0].name, 'Abs');

    await db.updateWorkoutName(0, 'Thighs');
    expect(db.getAllWorkouts()[0].name, 'Thighs');
  });
  test('adds workout exercises correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [DurationExercise('Plank', 60)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 1);

    await db.addWorkoutExercises(
        0, [DurationExercise('Crunches', 40), DurationExercise('Russian Twist', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.length, 3);

    expect(ex.map((e) => e.name), ['Plank', 'Crunches', 'Russian Twist']);
  });

  test('updates workout exercises correctly', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [
      DurationExercise('Plank', 60),
      DurationExercise('Crunches', 40),
      DurationExercise('Russian Twist', 40)
    ]);

    await db.updateWorkoutExercises(
        0, [DurationExercise('Crunches', 40), DurationExercise('Russian Twist', 40)]);
    var ex = db.getWorkoutExercises(0);
    expect(ex.length, 2);

    await db.updateWorkoutExercises(
        0, [DurationExercise('Russian Twist', 40), DurationExercise('Crunches', 40)]);
    ex = db.getWorkoutExercises(0);
    expect(ex.map((e) => e.name), ['Russian Twist', 'Crunches']);
  });

  test('updates a workout exercise from duration to reps', () async {
    await db.clear();
    await db.addEmptyWorkout('Abs');
    await db.addWorkoutExercises(0, [
      DurationExercise('Plank', 60),
      DurationExercise('Crunches', 40),
    ]);
    await db.updateWorkoutExercises(0, [
      DurationExercise('Plank', 60),
      RepExercise('Push-ups', 20),
    ]);
    var ex = db.getWorkoutExercises(0);
    expect(ex[0], isA<DurationExercise>());
    expect(ex[1], isA<RepExercise>());
    expect(ex[1].name, 'Push-ups');
    expect((ex[1] as RepExercise).reps, 20);
  });
  test('deletes a workout successfully', () async {
    await db.clear();
    await db.addManyEmptyWorkouts(['Thighs', 'Biceps']);
    expect(db.getAllWorkouts().length, 2);

    await db.deleteWorkout(1);
    var workouts = db.getAllWorkouts();
    expect(workouts.length, 1);
    expect(workouts.where((e) => e.name == "Biceps").length, 0);
  });
  test('deletes box successfully', () async {
    await db.loadData();
    await db.delete();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
  test('closes box successfully', () async {
    await db.close();
    expect(() => db.getAllWorkouts(), throwsA(TypeMatcher<HiveError>()));
  });
}
