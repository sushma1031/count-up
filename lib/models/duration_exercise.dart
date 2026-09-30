import 'package:hive/hive.dart';
import '../utils/workout_constants.dart';
import 'exercise.dart';
import 'exercise_type.dart';

part 'duration_exercise.g.dart';

@HiveType(typeId: 1)
class DurationExercise extends Exercise {
  @HiveField(0)
  String _name;

  @HiveField(1)
  int _duration;

  DurationExercise(this._name, this._duration);

  @override
  String get name => _name;
  @override
  set name(String value) => _name = value;

  int get duration => _duration;
  set duration(int value) => _duration = value;

  @override
  ExerciseType get type => ExerciseType.duration;

  @override
  String toString() => "$name, ${duration}s";

  @override
  Map<String, dynamic> toJson() {
    return {
      ExerciseJsonKeys.type: kExerciseTypeDuration,
      ExerciseJsonKeys.name: _name,
      ExerciseJsonKeys.duration: _duration,
    };
  }

  factory DurationExercise.fromJson(Map<String, dynamic> json) {
    return DurationExercise(
      json[ExerciseJsonKeys.name] as String,
      json[ExerciseJsonKeys.duration] as int,
    );
  }
}
