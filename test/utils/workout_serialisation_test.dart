import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/utils/workout_serialisation.dart';
import 'package:test/test.dart';

void main() {
  group('JSON export works correctly', () {
    test('returns JSON string for valid workout', () {
      final workout = Workout("Abs", [DurationExercise("Plank", 10)]);
      final jsonResult = exportJson(workout);
      expect(jsonResult, isNotEmpty);
      expect(jsonResult, contains('"name": "Abs"'));
      expect(jsonResult, contains('"exercises"'));
      expect(jsonResult, contains('"name": "Plank"'));
      expect(jsonResult, contains('"duration": 10'));
    });

    test('round-trips a duration-only workout', () {
      final workout = Workout("Cardio", [
        DurationExercise("Jumping Jacks", 30),
        DurationExercise("Plank", 60),
      ]);

      final restored = importFromJson(exportJson(workout));

      expect(restored.exercises, hasLength(2));
      expect(restored.exercises[0], isA<DurationExercise>());
      expect((restored.exercises[0] as DurationExercise).duration, 30);
      expect(restored.exercises[1], isA<DurationExercise>());
      expect((restored.exercises[1] as DurationExercise).duration, 60);
    });

    test('round-trips a rep-only workout', () {
      final workout = Workout("Strength", [
        RepExercise("Push-ups", 12),
        RepExercise("Squats", 20),
      ]);

      final restored = importFromJson(exportJson(workout));

      expect(restored.exercises, hasLength(2));
      expect(restored.exercises[0], isA<RepExercise>());
      expect((restored.exercises[0] as RepExercise).reps, 12);
      expect(restored.exercises[1], isA<RepExercise>());
      expect((restored.exercises[1] as RepExercise).reps, 20);
    });

    test('round-trips a mixed duration/rep workout', () {
      final workout = Workout("Full Body", [
        DurationExercise("Plank", 60),
        RepExercise("Push-ups", 12),
      ]);

      final jsonResult = exportJson(workout);
      final restored = importFromJson(jsonResult);

      expect(restored.exercises, hasLength(2));
      expect(restored.exercises[0], isA<DurationExercise>());
      expect((restored.exercises[0] as DurationExercise).duration, 60);
      expect(restored.exercises[1], isA<RepExercise>());
      expect((restored.exercises[1] as RepExercise).reps, 12);
    });
  });

  group('JSON import works correctly', () {
    test('decodes legacy JSON with no type field as DurationExercise', () {
      final json = '''
        {
            "name": "Abs",
            "exercises": [
                {
                    "name": "Crunches",
                    "duration": 10
                },
                {
                    "name": "Plank",
                    "duration": 15
                }
            ]
        }
        ''';
      final workout = importFromJson(json);
      expect(workout, isNotNull);
      expect(workout, isA<Workout>());
      expect(workout.exercises, isA<List<Exercise>>());
      expect(workout.name, equals("Abs"));
      expect(workout.exercises.length, 2);
      expect(workout.exercises[0].name, equals("Crunches"));
      expect(workout.exercises[0], isA<DurationExercise>());
      expect((workout.exercises[0] as DurationExercise).duration, equals(10));
    });
    test('throws FormatException for invalid JSON', () {
      final json = '''

            "name": "Abs",
            "exercises": [
                {
                    "name": "Crunches",
                    "duration": 10
                },
                {
                    "name": "Plank",
                    "duration": 15
                }
            ]
        }
        ''';
      expect(
          () => importFromJson(json), throwsA(TypeMatcher<FormatException>()));
    });
    test('throws TypeError for incorrect Workout structure', () {
      final json = '''
        {
            "name": 10,
            "exercises": "not list"
        }
        ''';
      expect(() => importFromJson(json), throwsA(TypeMatcher<TypeError>()));
    });

    test('rejects an unknown exercise type without a partial import', () {
      final json = '''
        {
            "name": "Abs",
            "exercises": [
                { "name": "Crunches", "duration": 10 },
                { "type": "burpee", "name": "Burpees", "count": 10 }
            ]
        }
        ''';
      expect(
          () => importFromJson(json),
          throwsA(isA<UnknownExerciseTypeException>()
              .having((e) => e.type, 'type', 'burpee')));
    });

    test('rejects a malformed rep count without a partial import', () {
      final json = '''
        {
            "name": "Abs",
            "exercises": [
                { "name": "Crunches", "duration": 10 },
                { "type": "rep", "name": "Push-ups", "reps": "twelve" }
            ]
        }
        ''';
      expect(() => importFromJson(json), throwsA(TypeMatcher<TypeError>()));
    });

    test('rejects a malformed duration without a partial import', () {
      final json = '''
        {
            "name": "Abs",
            "exercises": [
                { "name": "Crunches", "duration": 10 },
                { "type": "duration", "name": "Plank", "duration": "sixty" }
            ]
        }
        ''';
      expect(() => importFromJson(json), throwsA(TypeMatcher<TypeError>()));
    });
  });

  group('ZIP export includes JSON files for all workouts', () {
    test('archive contains one correctly-typed JSON entry per workout', () {
      final workouts = [
        Workout("Cardio", [DurationExercise("Jumping Jacks", 30)]),
        Workout("Strength", [RepExercise("Push-ups", 12)]),
        Workout("Full Body", [
          DurationExercise("Plank", 60),
          RepExercise("Squats", 20),
        ]),
      ];

      final zipBytes = buildWorkoutsZipBytes(workouts);
      final archive = ZipDecoder().decodeBytes(zipBytes);

      expect(archive.files, hasLength(3));
      expect(archive.files.map((f) => f.name),
          containsAll(['cardio.json', 'strength.json', 'full-body.json']));

      final entriesByName = {for (final f in archive.files) f.name: f};

      final cardio = jsonDecode(utf8.decode(entriesByName['cardio.json']!.content));
      expect(cardio['exercises'][0]['type'], 'duration');
      expect(cardio['exercises'][0]['duration'], 30);

      final strength =
          jsonDecode(utf8.decode(entriesByName['strength.json']!.content));
      expect(strength['exercises'][0]['type'], 'rep');
      expect(strength['exercises'][0]['reps'], 12);

      final fullBody =
          jsonDecode(utf8.decode(entriesByName['full-body.json']!.content));
      expect(fullBody['exercises'][0]['type'], 'duration');
      expect(fullBody['exercises'][1]['type'], 'rep');
    });
  });
}
