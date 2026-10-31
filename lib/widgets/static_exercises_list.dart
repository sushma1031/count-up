import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/exercise_item.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  const StaticExerciseList({super.key, required this.exercises});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 96),
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        return Padding(
            padding: EdgeInsets.only(top: 24),
            child: ExerciseItem(exercise: exercises[index]));
      },
    );
  }
}
