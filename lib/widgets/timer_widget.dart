import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/offset_animated_text.dart';
import 'package:count_up/widgets/reverse_circular_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class TimerWidget extends StatelessWidget {
  final AnimationController controller;
  final String name;
  final String? nextName;
  final Duration timeLeft;
  final String workoutProgress;
  final Future<void> Function() prevBtnFunction;
  final Future<void> Function()? nextBtnFunction;
  final void Function() togglePauseResume;
  final IconData pauseResume;

  const TimerWidget(
      {super.key,
      required this.controller,
      required this.name,
      required this.timeLeft,
      required this.prevBtnFunction,
      required this.nextBtnFunction,
      required this.togglePauseResume,
      required this.pauseResume,
      required this.workoutProgress,
      this.nextName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
              height: 50,
              child: timeLeft.inSeconds > 5
                  ? Container()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: OffsetAnimatedText(
                          nextName != null ? l10n.nextUp(nextName!) : l10n.lastOne))),
          SizedBox(
              height: 500,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                        child: Stack(alignment: AlignmentDirectional.center, children: <Widget>[
                      ReverseCircularProgressIndicator(
                        controller: controller,
                      ),
                      Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Padding(
                              padding: EdgeInsets.only(bottom: PlaybackStyles.nameBottomPadding),
                              child: Container(
                                  width: 200,
                                  child: Text(name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: PlaybackStyles.exerciseName))),
                          Text('${formatDuration(timeLeft)}', style: PlaybackStyles.count)
                        ]),
                      ]),
                      Align(
                          heightFactor: 10,
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            workoutProgress,
                            style: TextStyle(
                                fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                          ))
                    ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            tooltip: l10n.previousTooltip,
                            onPressed: prevBtnFunction,
                            icon: Icon(Icons.skip_previous)),
                        IconButton(
                            tooltip: l10n.pauseResumeTooltip,
                            onPressed: togglePauseResume,
                            icon: Icon(pauseResume)),
                        IconButton(
                          tooltip: l10n.nextTooltip,
                          onPressed: nextBtnFunction,
                          icon: Icon(Icons.skip_next),
                        )
                      ],
                    )
                  ])),
        ]));
  }
}
