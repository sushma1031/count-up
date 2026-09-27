import 'dart:convert';

import 'package:count_up/models/workout.dart';
import 'package:count_up/services/workout_backup_service.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:flutter_test/flutter_test.dart';

import 'mock_storage_service.dart';

void main() {
  late _TrackingStorageService db;

  setUp(() {
    db = _TrackingStorageService();
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

      final error =
          await WorkoutBackupService(db).importWorkoutJson(workoutJson);

      if (count > maxExercisesPerWorkout) {
        expect(error, ImportError.exerciseLimit);
        expect(db.nameReads, 0);
        expect(db.writes, 0);
        expect(db.size, 1);
      } else {
        expect(error, isNull);
        expect(db.nameReads, 1);
        expect(db.writes, 1);
        expect(db.size, 2);
        final imported = db.getAllWorkouts().last;
        expect(imported.name, 'Workout (1)');
        expect(imported.exercises, hasLength(count));
      }
      expect(db.getWorkout(99)!.name, 'Workout');
      expect(db.getWorkout(99)!.exercises, isEmpty);
    });
  }

  test('malformed JSON returns a format error without accessing storage',
      () async {
    final error = await WorkoutBackupService(db).importWorkoutJson('{');

    expect(error, ImportError.format);
    expect(db.nameReads, 0);
    expect(db.writes, 0);
    expect(db.size, 1);
  });

  test('wrong structure returns a type error without accessing storage',
      () async {
    final error = await WorkoutBackupService(db).importWorkoutJson(
      jsonEncode({'name': 10, 'exercises': 'not list'}),
    );

    expect(error, ImportError.type);
    expect(db.nameReads, 0);
    expect(db.writes, 0);
    expect(db.size, 1);
  });
}

class _TrackingStorageService extends MockStorageService {
  int nameReads = 0;
  int writes = 0;

  @override
  List<String> getAllWorkoutNames() {
    nameReads++;
    return super.getAllWorkoutNames();
  }

  @override
  Future<int> addWorkout(Workout workout) {
    writes++;
    return super.addWorkout(workout);
  }
}
