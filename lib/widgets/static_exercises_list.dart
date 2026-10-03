import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/exercise_item.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  const StaticExerciseList({Key? key, required this.exercises}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: exercises.isEmpty
            ? null
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  return Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: ExerciseItem(exercise: exercises[index]));
                },
              ));
  }
}
