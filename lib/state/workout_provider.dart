import 'package:flutter/material.dart';
import '../models/exercise.dart';
import './timer_provider.dart';
import './rep_provider.dart';
import '../widgets/workout_complete.dart';
import '../services/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class WorkoutProvider extends StatefulWidget {
  final List<Exercise> exercises;
  final AudioService player;
  final double timerVolume;

  WorkoutProvider(
      {Key? key,
      required this.exercises,
      required this.player,
      this.timerVolume = 0.5})
      : super(key: key);

  @override
  State<WorkoutProvider> createState() => _WorkoutProviderState();
}

class _WorkoutProviderState extends State<WorkoutProvider> {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;
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
    await widget.player.setVolume(widget.timerVolume);
  }

  void nextExercise(_) {
    setState(() {
      if (_currentIndex >= _exercises.length - 1) {
        _isWorkoutComplete = true;
      } else
        _currentIndex++;
    });
  }

  void previousExercise(_) {
    setState(() {
      if (_currentIndex > 0) _currentIndex--;
      if (_currentIndex < _exercises.length && _isWorkoutComplete) {
        _isWorkoutComplete = false;
      }
    });
  }

  void restartWorkout() {
    setState(() {
      _currentIndex = 0;
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
