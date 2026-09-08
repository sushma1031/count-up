import 'dart:async';
import 'package:count_up/widgets/timer_widget.dart';
import 'package:flutter/material.dart';
import 'package:count_up/services/audio_service.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class TimerProvider extends StatefulWidget {
  final Duration duration;
  final String name;
  final String? nextName;
  final String workoutProgress;
  final int currentIndex;
  final int noOfExercises;
  final ValueChanged<void> nextExercise;
  final ValueChanged<void> previousExercise;
  final AudioService player;
  const TimerProvider(
      {Key? key,
      required this.name,
      required this.duration,
      required this.currentIndex,
      required this.noOfExercises,
      required this.nextExercise,
      required this.previousExercise,
      required this.player,
      required this.workoutProgress,
      this.nextName})
      : super(key: key);
  @override
  State<TimerProvider> createState() => _TimerProviderState();
}

class _TimerProviderState extends State<TimerProvider>
    with SingleTickerProviderStateMixin {
  final String audioPath = Assets.audioExerciseChange;
  late Timer _timer;
  late Duration _timeLeft;
  late AnimationController _controller;
  bool _isPaused = false;
  var oneSec = Duration(seconds: 1);
  @override
  void initState() {
    super.initState();
    _timeLeft = widget.duration;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + oneSec,
    )..addListener(() {
        setState(() {});
      });
    startTimer();
  }

  void startTimer() {
    _controller.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeLeft -= Duration(seconds: 1);
        if (_timeLeft.inSeconds == 3) {
          widget.player.play();
        }
        if (_timeLeft.inSeconds <= -1) {
          timer.cancel();
          widget.player.status = AudioStatus.stopped;
          widget.nextExercise(null);
        }
      });
    });
  }

  Future<void> pauseTimer() async {
    _timer.cancel();
    _controller.stop();
    await widget.player.pause();
  }

  Future<void> resumeTimer() async {
    startTimer();
    _controller.forward(from: _controller.value);
    await widget.player.resume();
  }

  Future<void> restartTimer() async {
    if (!_isPaused) {
      _timer.cancel();
      _controller.stop();
    }
    setState(() {
      _timeLeft = widget.duration;
      _controller.duration = widget.duration;
      _controller.reset();
    });
    if (!_isPaused) {
      startTimer();
      _controller.forward();
    }
  }

  Future<void> goPrevious() async {
    await widget.player.stop();

    if (widget.duration.inSeconds - _timeLeft.inSeconds > 2) {
      restartTimer();
    } else {
      _timer.cancel();
      _controller.stop();
      widget.previousExercise(null);
      if (_isPaused) {
        setState(() {
          _isPaused = false;
        });
      }
    }
  }

  Future<void> goNext() async {
    await widget.player.stop();
    _timer.cancel();
    _controller.stop();
    widget.nextExercise(null);
    if (_isPaused) {
      setState(() {
        _isPaused = false;
      });
    }
  }

  void togglePauseResume() {
    if (_isPaused) {
      resumeTimer();
    } else {
      pauseTimer();
    }
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    _timeLeft = widget.duration;
    _controller.duration = widget.duration;
    _controller.reset();

    // perform any other operations here, like setting a short break, etc.

    startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _controller.dispose();
    widget.player.stop();
    super.dispose();
  }

  Future<bool> _showExitDialog() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                l10n.workoutIncompleteTitle,
              ),
              content: Text(
                l10n.exitWorkoutConfirm,
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(l10n.yesBtn),
                    onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text(l10n.noBtn),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
              elevation: 20,
            );
          },
        ) ??
        false;
  }

  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    if (!_isPaused) {
      setState(() {
        _isPaused = true;
      });
      await pauseTimer();
    }
    final bool shouldExit = await _showExitDialog();

    if (shouldExit && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
        child: TimerWidget(
          name: widget.name,
          nextName: widget.nextName,
          nextBtnFunction:
              widget.currentIndex == widget.noOfExercises ? null : goNext,
          pauseResume: _isPaused ? Icons.play_arrow : Icons.pause,
          togglePauseResume: togglePauseResume,
          timeLeft: _timeLeft,
          workoutProgress: widget.workoutProgress,
          prevBtnFunction: goPrevious,
          controller: _controller,
        ));
  }
}
