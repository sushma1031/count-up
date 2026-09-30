import 'package:count_up/widgets/rep_widget.dart';
import 'package:flutter/material.dart';
import 'package:count_up/utils/workout_exit_dialog.dart';

class RepProvider extends StatelessWidget {
  final String name;
  final String? nextName;
  final int reps;
  final int currentIndex;
  final int noOfExercises;
  final ValueChanged<void> nextExercise;
  final ValueChanged<void> previousExercise;
  final String workoutProgress;

  const RepProvider(
      {Key? key,
      required this.name,
      required this.reps,
      required this.currentIndex,
      required this.noOfExercises,
      required this.nextExercise,
      required this.previousExercise,
      required this.workoutProgress,
      this.nextName})
      : super(key: key);

  Future<void> _goPrevious() async {
    previousExercise(null);
  }

  Future<void> _goNext() async {
    nextExercise(null);
  }

  void _onDone() {
    nextExercise(null);
  }

  void _onPopInvoked(BuildContext context, bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    final bool shouldExit = await showExitWorkoutDialog(context);

    if (shouldExit && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) =>
            _onPopInvoked(context, didPop, result),
        child: RepWidget(
          name: name,
          nextName: nextName,
          reps: reps,
          nextBtnFunction: currentIndex == noOfExercises ? null : _goNext,
          prevBtnFunction: _goPrevious,
          onDone: _onDone,
          workoutProgress: workoutProgress,
        ));
  }
}
