import 'package:count_up/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import '../state/workout_provider.dart';
import '../services/audio_service.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class TimerScreen extends StatelessWidget {
  final List<Exercise> e;

  final AudioService player;
  final int breakSeconds;
  final int countdownSeconds;
  final AudioService Function()? createStartPlayer;

  const TimerScreen(
      {super.key,
      required this.e,
      required this.player,
      this.breakSeconds = 0,
      this.countdownSeconds = 0,
      this.createStartPlayer});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).timerScreenTitle,
            style: TextStyle(fontFamily: Assets.fontEthosNova, fontWeight: FontWeight.bold)),
      ),
      body: Center(
          child: WorkoutProvider(
        exercises: e,
        player: player,
        breakSeconds: breakSeconds,
        countdownSeconds: countdownSeconds,
        createStartPlayer: createStartPlayer,
      )),
    );
  }
}
