import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import '../models/exercise.dart';
import './timer_provider.dart';
import './rep_provider.dart';
import '../widgets/workout_complete.dart';
import '../widgets/countdown.dart';
import '../services/audio_service.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

enum _Countdown { none, start, anotherRound }

class WorkoutProvider extends StatefulWidget {
  final List<Exercise> exercises;
  final AudioService player;

  final int breakSeconds;
  final int countdownSeconds;
  final AudioService Function()? createStartPlayer;

  WorkoutProvider(
      {super.key,
      required this.exercises,
      required this.player,
      this.breakSeconds = 0,
      this.countdownSeconds = 0,
      this.createStartPlayer});

  @override
  State<WorkoutProvider> createState() => _WorkoutProviderState();
}

class _WorkoutProviderState extends State<WorkoutProvider> {
  List<Exercise> _exercises = [];
  int _currentIndex = 0;
  bool _isWorkoutComplete = false;
  bool _isOnBreak = false;
  bool _wakeLockEnabled = false;
  _Countdown _countdown = _Countdown.none;

  @override
  void initState() {
    _exercises = widget.exercises;
    _currentIndex = 0;
    initAudioPlayer();
    if (widget.countdownSeconds > 0) _countdown = _Countdown.start;
    super.initState();
    _syncWakeLock();
  }

  // enable wakelock only while the workout is in progress
  void _syncWakeLock() {
    final shouldEnable = !_isWorkoutComplete;
    if (shouldEnable == _wakeLockEnabled) return;
    _wakeLockEnabled = shouldEnable;
    if (shouldEnable) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }
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
    _syncWakeLock();
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
    _syncWakeLock();
  }

  void restartWorkout() {
    setState(() {
      _currentIndex = 0;
      _isOnBreak = false;
      _isWorkoutComplete = false;
      _countdown = _Countdown.anotherRound;
    });
    _syncWakeLock();
  }

  void _endCountdown() => setState(() => _countdown = _Countdown.none);

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
    final l10n = AppLocalizations.of(context);
    final n = widget.countdownSeconds;
    return Center(
      child: switch (_countdown) {
        _Countdown.start => Countdown(
            textSequence: [for (var i = n; i > 0; i--) '$i'],
            fontSize: 50,
            stepDuration: const Duration(seconds: 1),
            createPlayer: widget.createStartPlayer,
            onFinished: _endCountdown,
          ),
        _Countdown.anotherRound => Countdown(
            textSequence: [
              l10n.countdownGet,
              l10n.countdownSet,
              l10n.countdownGo
            ],
            message: l10n.anotherRoundMessage,
            fontSize: 40,
            createPlayer: widget.createStartPlayer,
            onFinished: _endCountdown,
          ),
        _Countdown.none => _buildWorkout(context),
      },
    );
  }

  Widget _buildWorkout(BuildContext context) {
    final currentExercise = _exercises[_currentIndex];
    final String? nextName = _currentIndex < _exercises.length - 1
        ? _exercises[_currentIndex + 1].name
        : null;
    final String workoutProgress = "${_currentIndex + 1}/${_exercises.length}";

    return _isWorkoutComplete
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
                        seconds:
                            (currentExercise as DurationExercise).duration),
                    currentIndex: _currentIndex,
                    nextExercise: nextExercise,
                    previousExercise: previousExercise,
                    noOfExercises: _exercises.length - 1,
                    workoutProgress: workoutProgress,
                    player: widget.player,
                  );
  }
}
