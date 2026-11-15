import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/next_up_header.dart';
import 'package:count_up/widgets/circle_outline.dart';
import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class RepWidget extends StatelessWidget {
  final String name;
  final String? nextName;
  final int reps;
  final String workoutProgress;
  final Future<void> Function() prevBtnFunction;
  final Future<void> Function()? nextBtnFunction;
  final void Function() onDone;

  const RepWidget(
      {super.key,
      required this.name,
      required this.reps,
      required this.prevBtnFunction,
      required this.nextBtnFunction,
      required this.onDone,
      required this.workoutProgress,
      this.nextName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
        padding: EdgeInsets.only(top: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          NextUpHeader(nextName: nextName),
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
                          CircleOutline(
                              size: PlaybackStyles.circleSize,
                              strokeWidth: PlaybackStyles.circleStrokeWidth),
                          RichText(
                            text: TextSpan(style: PlaybackStyles.count, children: [
                              TextSpan(text: "$reps"),
                              TextSpan(
                                  text: " ${l10n.repsLabel.toUpperCase()}",
                                  style: const TextStyle(fontSize: 16))
                            ]),
                          ),
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
                            tooltip: l10n.previousTooltip,
                            onPressed: prevBtnFunction,
                            icon: Icon(Icons.skip_previous)),
                        IconButton(
                            tooltip: l10n.doneTooltip, onPressed: onDone, icon: Icon(Icons.check)),
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
