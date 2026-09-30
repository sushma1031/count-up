import 'package:flutter/material.dart';

const int maxExercisesPerWorkout = 50;

const String kExerciseTypeDuration = 'duration';
const String kExerciseTypeRep = 'rep';

abstract class ExerciseJsonKeys {
  static const type = 'type';
  static const name = 'name';
  static const duration = 'duration';
  static const reps = 'reps';
}

abstract class PlaybackStyles {
  static const TextStyle exerciseName = TextStyle(fontSize: 18);
  static const TextStyle count = TextStyle(fontSize: 55, fontWeight: FontWeight.w300);
  static const double circleSize = 275;
  static const double circleStrokeWidth = 8;
  static const double nameBottomPadding = 18;
}
