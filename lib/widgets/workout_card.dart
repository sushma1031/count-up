import 'package:flutter/material.dart';
import 'package:count_up/models/workout_display.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class WorkoutCard extends StatelessWidget {
  final WorkoutDisplay workout;
  final void Function() onTap;
  const WorkoutCard({Key? key, required this.workout, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalDuration = workout.totalDuration;
    Color primary = Theme.of(context).colorScheme.primary.withValues(alpha: 0.08);
    Color darkBase = Theme.of(context).colorScheme.surface;
    return Card(
      elevation: 24,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              Color.alphaBlend(primary, darkBase),
              Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25)
            ],
            tileMode: TileMode.mirror,
          ),
        ),
        constraints: BoxConstraints(minHeight: 140),
        child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onTap,
            child: Container(
                padding: EdgeInsets.fromLTRB(15, 25, 15, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        workout.name,
                        style: TextStyle(fontSize: 25, fontFamily: "EthosNova"),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (totalDuration != null)
                          Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: Chip(
                                backgroundColor: Color.alphaBlend(primary, darkBase),
                                label: Text(
                                  l10n.workoutDurationMinutes(totalDuration) +
                                      (workout.composition == WorkoutComposition.mixed ? "+" : ""),
                                  style: TextStyle(color: Theme.of(context).colorScheme.secondary),
                                ),
                                shape: RoundedRectangleBorder(
                                    side:
                                        BorderSide(color: Theme.of(context).colorScheme.secondary),
                                    borderRadius: BorderRadius.circular(5)),
                              )),
                        Chip(
                            elevation: 0,
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            label: Text(
                              l10n.workoutExerciseCount(workout.noOfExercises),
                              style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                            ),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: Theme.of(context).colorScheme.secondary),
                                borderRadius: BorderRadius.circular(5))),
                      ],
                    )
                  ],
                ))),
      ),
    );
  }
}
