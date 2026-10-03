import 'dart:math';
import 'package:flutter/material.dart';
import 'package:count_up/screens/countdown_screen.dart';
import 'package:count_up/services/timer_audio_service.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class WorkoutComplete extends StatelessWidget {
  final void Function() restartWorkout;
  final bgImage = const AssetImage(Assets.imageBGDesign1);

  Future<void> countdownAndRestart(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountdownScreen(
            message: l10n.anotherRoundMessage,
            textSequence: [l10n.countdownGet, l10n.countdownSet, l10n.countdownGo],
            onCompleteAudioPlayer: TimerAudioService(Assets.audioWorkoutStart),
            fontSize: 40,
          ),
        )).then((value) {
      if (value == true) restartWorkout();
    });
  }

  WorkoutComplete({Key? key, required this.restartWorkout});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final messages = <String>[
      l10n.workoutCompleteMessage1,
      l10n.workoutCompleteMessage2,
      l10n.workoutCompleteMessage3,
      l10n.workoutCompleteMessage4,
    ];
    var index = Random().nextInt(4);
    return Container(
        decoration: BoxDecoration(
          image: DecorationImage(fit: BoxFit.fitWidth, image: bgImage),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(l10n.workoutCompleteTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 52,
                      fontFamily: Assets.fontEthosNova,
                    ))),
            Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 25),
                child: Text(
                  messages[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.5),
                )),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await countdownAndRestart(context);
                    },
                    child: Text(l10n.repeatBtn),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(
                          context, (Route<dynamic> route) => route.isFirst);
                    },
                    child: Text(l10n.homeBtn),
                  ),
                ]),
          ],
        ));
  }
}
