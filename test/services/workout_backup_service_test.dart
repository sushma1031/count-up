import 'dart:convert';

import 'package:count_up/models/workout.dart';
import 'package:count_up/services/workout_backup_service.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_storage_service.dart';

void main() {
  late MockStorageService db;

  setUp(() {
    db = MockStorageService();
    db.workoutsMap[99] = Workout('Workout', []);
  });

  tearDown(() {
    db.notifier.dispose();
  });

  for (final count in [
    maxExercisesPerWorkout - 1,
    maxExercisesPerWorkout,
    maxExercisesPerWorkout + 1,
  ]) {
    test('import handles a workout with $count exercises', () async {
      final workoutJson = jsonEncode({
        'name': 'Workout',
        'exercises': List.generate(
          count,
          (i) => {'name': 'Exercise $i', 'duration': 60},
        ),
      });

      final result =
          await WorkoutBackupService(db).importWorkoutJson(workoutJson);

      if (count > maxExercisesPerWorkout) {
        expect(result.error, ImportError.exerciseLimit);
        expect(result.workoutKey, isNull);
        expect(db.writes, 0);
        expect(db.size, 1);
      } else {
        expect(result.error, isNull);
        expect(db.writes, 1);
        expect(db.size, 2);
        final imported = db.getWorkout(result.workoutKey!)!;
        expect(imported.name, 'Workout (1)');
        expect(imported.exercises, hasLength(count));
      }
      expect(db.getWorkout(99)!.name, 'Workout');
      expect(db.getWorkout(99)!.exercises, isEmpty);
    });
  }

  test('malformed JSON returns a format error without accessing storage',
      () async {
    final result = await WorkoutBackupService(db).importWorkoutJson('{');

    expect(result.error, ImportError.format);
    expect(db.writes, 0);
    expect(db.size, 1);
  });

  test('wrong structure returns a type error without accessing storage',
      () async {
    final result = await WorkoutBackupService(db).importWorkoutJson(
      jsonEncode({'name': 10, 'exercises': 'not list'}),
    );

    expect(result.error, ImportError.type);
    expect(db.writes, 0);
    expect(db.size, 1);
  });

  test(
      'unknown exercise type in a multi-exercise workout is rejected without a partial import',
      () async {
    final workoutJson = jsonEncode({
      'name': 'Workout',
      'exercises': [
        {'name': 'Crunches', 'duration': 10},
        {'type': 'burpee', 'name': 'Burpees', 'count': 10},
      ],
    });

    final result = await WorkoutBackupService(db).importWorkoutJson(workoutJson);

    expect(result.error, ImportError.format);
    expect(db.writes, 0);
    expect(db.size, 1);
  });

  test(
      'malformed rep count in a multi-exercise workout is rejected without a partial import',
      () async {
    final workoutJson = jsonEncode({
      'name': 'Workout',
      'exercises': [
        {'name': 'Crunches', 'duration': 10},
        {'type': 'rep', 'name': 'Push-ups', 'reps': 'twelve'},
      ],
    });

    final result = await WorkoutBackupService(db).importWorkoutJson(workoutJson);

    expect(result.error, ImportError.type);
    expect(db.writes, 0);
    expect(db.size, 1);
  });
}
