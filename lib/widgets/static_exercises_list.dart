import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../widgets/exercise_item.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  final Widget? header;

  const StaticExerciseList({super.key, required this.exercises, this.header});

  @override
  Widget build(BuildContext context) {
    final header = this.header;
    final offset = header == null ? 0 : 1;
    return ListView.builder(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 96),
      itemCount: exercises.length + offset,
      itemBuilder: (context, index) {
        return Padding(
            padding: EdgeInsets.only(top: 24),
            child: header != null && index == 0
                ? header
                : ExerciseItem(exercise: exercises[index - offset]));
      },
    );
  }
}
