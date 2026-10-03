import 'package:count_up/models/exercise.dart';
import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import '../state/settings_provider.dart';
import '../state/workout_provider.dart';
import '../services/audio_service.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class TimerScreen extends StatelessWidget {
  final List<Exercise> e;

  final AudioService player;

  const TimerScreen({Key? key, required this.e, required this.player})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context).timerScreenTitle,
            style: TextStyle(
                fontFamily: Assets.fontEthosNova, fontWeight: FontWeight.bold)),
      ),
      body: Center(
          child: WorkoutProvider(
        exercises: e,
        player: player,
        timerVolume: SettingsProvider.of(context).timerVolume,
      )),
    );
  }
}
