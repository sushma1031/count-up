import 'package:hive/hive.dart';
import '../utils/workout_constants.dart';
import 'duration_exercise.dart';
import 'exercise_type.dart';
import 'rep_exercise.dart';

export 'duration_exercise.dart';
export 'rep_exercise.dart';

abstract class Exercise extends HiveObject {
  Exercise();

  String get name;
  set name(String value);

  ExerciseType get type;

  Map<String, dynamic> toJson();

  factory Exercise.fromJson(Map<String, dynamic> json) {
    final rawType = json[ExerciseJsonKeys.type] as String?;
    return switch (rawType) {
      kExerciseTypeRep => RepExercise.fromJson(json),
      // Missing type is considered DurationExercise for backward compatibility
      // (exercises created before rep-based was introduced).
      kExerciseTypeDuration || null => DurationExercise.fromJson(json),
      final type => throw UnknownExerciseTypeException(type),
    };
  }
}

class UnknownExerciseTypeException implements Exception {
  final String type;

  const UnknownExerciseTypeException(this.type);

  @override
  String toString() => 'UnknownExerciseTypeException: $type';
}
