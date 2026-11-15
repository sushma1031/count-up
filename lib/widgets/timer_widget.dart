import 'package:count_up/utils/format.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/next_up_header.dart';
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
  final bool isPaused;
  final bool restartsOnPrevious;

  const TimerWidget(
      {super.key,
      required this.controller,
      required this.name,
      required this.timeLeft,
      required this.prevBtnFunction,
      required this.nextBtnFunction,
      required this.togglePauseResume,
      required this.isPaused,
      required this.restartsOnPrevious,
      required this.workoutProgress,
      this.nextName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          NextUpHeader(nextName: nextName, visible: timeLeft.inSeconds <= 5),
          Padding(
              padding: EdgeInsets.only(left: 24, right: 24),
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: PlaybackStyles.exerciseName)),
          SizedBox(
              height: PlaybackStyles.circleAndControlsHeight,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox.square(
                        dimension: PlaybackStyles.circleSize,
                        child: Stack(alignment: Alignment.center, children: <Widget>[
                          ReverseCircularProgressIndicator(
                            controller: controller,
                          ),
                          Text(formatDuration(timeLeft), style: PlaybackStyles.count),
                          Positioned(
                              bottom: PlaybackStyles.progressBottomOffset,
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
                            tooltip:
                                restartsOnPrevious ? l10n.restartTooltip : l10n.previousTooltip,
                            onPressed: prevBtnFunction,
                            icon: Icon(Icons.skip_previous)),
                        IconButton(
                            tooltip: isPaused ? l10n.resumeTooltip : l10n.pauseTooltip,
                            onPressed: togglePauseResume,
                            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause)),
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
