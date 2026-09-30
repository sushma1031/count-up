import 'package:hive/hive.dart';
import '../utils/workout_constants.dart';
import 'exercise.dart';
import 'exercise_type.dart';

part 'rep_exercise.g.dart';

@HiveType(typeId: 5)
class RepExercise extends Exercise {
  @HiveField(0)
  String _name;

  @HiveField(1)
  int _reps;

  RepExercise(this._name, this._reps);

  @override
  String get name => _name;
  @override
  set name(String value) => _name = value;

  int get reps => _reps;
  set reps(int value) => _reps = value;

  @override
  ExerciseType get type => ExerciseType.rep;

  @override
  String toString() => "$name, $reps reps";

  @override
  Map<String, dynamic> toJson() {
    return {
      ExerciseJsonKeys.type: kExerciseTypeRep,
      ExerciseJsonKeys.name: _name,
      ExerciseJsonKeys.reps: _reps,
    };
  }

  factory RepExercise.fromJson(Map<String, dynamic> json) {
    return RepExercise(
      json[ExerciseJsonKeys.name] as String,
      json[ExerciseJsonKeys.reps] as int,
    );
  }
}
