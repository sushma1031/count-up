import 'package:hive/hive.dart';
import 'package:count_up/services/settings_service.dart';
import './exercise.dart';

part 'workout.g.dart';

@HiveType(typeId: 2)
class Workout extends HiveObject {
  @HiveField(0)
  String _name;

  @HiveField(1)
  List<Exercise> _exercises;

  @HiveField(2)
  int? _breakSeconds;

  String get name => _name;
  set name(value) => _name = value;

  List<Exercise> get exercises => _exercises;
  set exercises(value) => _exercises = value;

  int? get breakSeconds => _breakSeconds;
  set breakSeconds(int? value) => _breakSeconds = value;

  Workout(this._name, this._exercises, [this._breakSeconds]);

  @override
  String toString() => this.name;

  Workout.fromWorkout(Workout other)
      : this._name = other.name,
        this._exercises = other.exercises,
        this._breakSeconds = other.breakSeconds;

  Map<String, dynamic> toJson() {
    return {
      'name': _name,
      'exercises': _exercises.map((ex) => ex.toJson()).toList(),
      if (_breakSeconds != null) 'breakSeconds': _breakSeconds,
    };
  }

  factory Workout.fromJson(Map<String, dynamic> json) {
    List<Exercise> exercises = (json['exercises'] as List<dynamic>)
        .map((e) => Exercise.fromJson(e as Map<String, dynamic>))
        .toList();
    final breakSeconds = (json['breakSeconds'] as int?)?.clamp(
      SettingsService.minBreakDurationSeconds,
      SettingsService.maxBreakDurationSeconds,
    );
    return Workout(
      json['name'] as String,
      exercises,
      breakSeconds,
    );
  }
}
