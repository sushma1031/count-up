import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../screens/countdown_screen.dart';
import '../services/timer_audio_service.dart';
import '../screens/timer_screen.dart';
import '../state/settings_provider.dart';
import '../utils/assets.dart';
import '../widgets/exercise_item.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class StaticExerciseList extends StatelessWidget {
  final List<Exercise> exercises;
  const StaticExerciseList({Key? key, required this.exercises}) : super(key: key);

  void _startWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(
          e: exercises,
          player: TimerAudioService(Assets.audioExerciseChange),
        ),
      ),
    );
  }

  Future<void> countdownAndStart(BuildContext context) async {
    final countdownSeconds = SettingsProvider.of(context).preWorkoutCountdownSeconds;

    if (countdownSeconds <= 0) {
      _startWorkout(context);
      return;
    }

    final shouldStart = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CountdownScreen(
          textSequence: List.generate(
            countdownSeconds,
            (i) => (countdownSeconds - i).toString(),
            growable: false,
          ),
          stepDuration: const Duration(seconds: 1),
          onCompleteAudioPlayer: TimerAudioService(Assets.audioWorkoutStart),
          fontSize: 50,
        ),
      ),
    );

    if (shouldStart == true && context.mounted) {
      _startWorkout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
          padding: EdgeInsets.only(top: 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 8)),
            onPressed: (exercises.length > 0) ? () => countdownAndStart(context) : null,
            child: Text(AppLocalizations.of(context).startWorkoutBtn),
          )),
      Expanded(
          child: Padding(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 24),
              child: exercises.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).emptyWorkoutHint,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: exercises.length,
                      itemBuilder: (context, index) {
                        return Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: ExerciseItem(exercise: exercises[index]));
                      },
                    ))),
    ]);
  }
}
