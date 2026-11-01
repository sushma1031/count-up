import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import '../models/exercise.dart';
import './timer_provider.dart';
import './rep_provider.dart';
import '../widgets/workout_complete.dart';
import '../services/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutProvider extends StatefulWidget {
  final List<Exercise> exercises;
  final AudioService player;

  final int breakSeconds;

  WorkoutProvider(
      {super.key,
      required this.exercises,
      required this.player,
      this.breakSeconds = 0});

  @override
  State<WorkoutProvider> createState() => _WorkoutProviderState();
}

class _WorkoutProviderState extends State<WorkoutProvider> {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;
  bool _isOnBreak = false;
  bool _wakeLockEnabled = false;

  @override
  void initState() {
    _exercises = widget.exercises;
    _currentIndex = 0;
    initAudioPlayer();
    super.initState();
  }

  Future<void> initAudioPlayer() async {
    await widget.player.configure();
  }

  void nextExercise(_) {
    setState(() {
      if (_isOnBreak) {
        _isOnBreak = false;
        _currentIndex++;
      } else if (_currentIndex >= _exercises.length - 1) {
        _isWorkoutComplete = true;
      } else if (widget.breakSeconds > 0) {
        _isOnBreak = true;
      } else
        _currentIndex++;
    });
  }

  void previousExercise(_) {
    setState(() {
      // From a break, the previous exercise is the one at _currentIndex.
      if (_isOnBreak) {
        _isOnBreak = false;
        return;
      }
      if (_currentIndex > 0) _currentIndex--;
      if (_currentIndex < _exercises.length && _isWorkoutComplete) {
        _isWorkoutComplete = false;
      }
    });
  }

  void restartWorkout() {
    setState(() {
      _currentIndex = 0;
      _isOnBreak = false;
      _isWorkoutComplete = false;
    });
  }

  @override
  void dispose() {
    widget.player.dispose();
    if (_wakeLockEnabled) {
      WakelockPlus.disable();
      _wakeLockEnabled = false;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // enable wakelock only in the timer screen
    if (!_isWorkoutComplete && !_wakeLockEnabled) {
      WakelockPlus.enable();
      _wakeLockEnabled = true;
    } else if (_isWorkoutComplete && _wakeLockEnabled) {
      WakelockPlus.disable();
      _wakeLockEnabled = false;
    }

    final currentExercise = _exercises[_currentIndex];
    final String? nextName = _currentIndex < _exercises.length - 1
        ? _exercises[_currentIndex + 1].name
        : null;
    final String workoutProgress =
        "${_currentIndex + 1}/${_exercises.length}";

    return Center(
        child: _isWorkoutComplete
            ? WorkoutComplete(
                restartWorkout: restartWorkout,
              )
            : _isOnBreak
                ? TimerProvider(
                    name: AppLocalizations.of(context).breakName,
                    nextName: nextName,
                    duration: Duration(seconds: widget.breakSeconds),
                    currentIndex: _currentIndex,
                    nextExercise: nextExercise,
                    previousExercise: previousExercise,
                    noOfExercises: _exercises.length - 1,
                    workoutProgress: workoutProgress,
                    player: widget.player,
                    isBreak: true,
                  )
                : currentExercise is RepExercise
                ? RepProvider(
                    name: currentExercise.name,
                    nextName: nextName,
                    reps: currentExercise.reps,
                    currentIndex: _currentIndex,
                    nextExercise: nextExercise,
                    previousExercise: previousExercise,
                    noOfExercises: _exercises.length - 1,
                    workoutProgress: workoutProgress,
                  )
                : TimerProvider(
                    name: currentExercise.name,
                    nextName: nextName,
                    duration: Duration(
                        seconds: (currentExercise as DurationExercise)
                            .duration),
                    currentIndex: _currentIndex,
                    nextExercise: nextExercise,
                    previousExercise: previousExercise,
                    noOfExercises: _exercises.length - 1,
                    workoutProgress: workoutProgress,
                    player: widget.player,
                  ));
  }
}
