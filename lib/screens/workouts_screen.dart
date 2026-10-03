import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/screens/exercises_screen.dart';
import 'package:count_up/models/workout_display.dart';
import 'package:count_up/widgets/workout_card.dart';
import 'package:count_up/widgets/settings_dialog.dart';
import 'package:count_up/widgets/danger_confirm_dialog.dart';
import 'package:count_up/utils/errors.dart';
import '../widgets/workout_name_form.dart';
import '../services/storage_service.dart';
import '../services/workout_backup_service.dart';
import '../state/settings_provider.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum WorkoutCollectionAction { deleteAll, importWorkout, exportAll }

class WorkoutsScreen extends StatelessWidget {
  final StorageService db;

  WorkoutsScreen({Key? key, required this.db}) : super(key: key);

  WorkoutBackupService get _backup => WorkoutBackupService(db);

  Future<void> _goToWorkout(BuildContext context, int workoutKey) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesScreen(
          workoutKey: workoutKey,
          db: db,
        ),
      ),
    );

    if (result != null && result == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).workoutNoLongerAvailable),
            duration: Duration(milliseconds: 2500)),
      );
    }
  }

  Future<void> _confirmAndDeleteAllWorkouts(BuildContext context) async {
    final len = db.size;
    if (len == 0) return;
    final confirmed = await DangerConfirmDialog.show(
      context,
      message: AppLocalizations.of(context).confirmDeleteWorkouts(len),
    );
    if (confirmed) await db.clear();
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorWithMessage(message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            l10n.workoutsScreenTitle,
            style: TextStyle(fontFamily: Assets.fontEthosNova, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) {
                        final settings = SettingsProvider.of(context);
                        return Dialog(
                          child: SettingsDialog(settings: settings),
                        );
                      },
                    ),
                icon: Icon(Icons.settings)),
            PopupMenuButton<WorkoutCollectionAction>(
                offset: Offset.fromDirection(90, 50),
                onSelected: (value) async {
                  switch (value) {
                    case WorkoutCollectionAction.importWorkout:
                      var error = await _backup.importWorkout();
                      if (error != null) {
                        _showErrorSnackbar(context, importErrorMessage(context, error));
                      }
                      break;
                    case WorkoutCollectionAction.deleteAll:
                      _confirmAndDeleteAllWorkouts(context);
                      break;
                    case WorkoutCollectionAction.exportAll:
                      var error = await _backup.exportAllWorkouts();
                      if (error != null) {
                        _showErrorSnackbar(context, exportErrorMessage(context, error));
                      }
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<WorkoutCollectionAction>>[
                      PopupMenuItem<WorkoutCollectionAction>(
                        child: Text(l10n.importWorkoutMenuItem),
                        value: WorkoutCollectionAction.importWorkout,
                      ),
                      PopupMenuItem<WorkoutCollectionAction>(
                        child: Text(l10n.exportAllMenuItem),
                        value: WorkoutCollectionAction.exportAll,
                      ),
                      PopupMenuItem<WorkoutCollectionAction>(
                        child: Text(l10n.deleteAllMenuItem),
                        value: WorkoutCollectionAction.deleteAll,
                      )
                    ]),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: StadiumBorder(),
          child: Icon(Icons.add),
          onPressed: () async {
            var workoutKey = await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: WorkoutNameForm(
                    initial: '',
                    label: l10n.newWorkoutLabel,
                    submitLabel: l10n.addBtn,
                    onSubmit: db.addEmptyWorkout,
                    existingNames: db.getAllWorkoutNames(),
                  ),
                  elevation: 24,
                );
              },
            );
            if (workoutKey != null) _goToWorkout(context, workoutKey);
          },
        ),
        body: ValueListenableBuilder(
            valueListenable: db.getListenable(),
            builder: (context, _, __) {
              var workouts = workoutDisplaysFrom(db.getWorkoutEntries());
              return Column(children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(bottom: 72),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: WorkoutCard(
                            workout: workouts[index],
                            onTap: () => _goToWorkout(context, workouts[index].key),
                          ));
                    },
                  ),
                ),
              ]);
            }));
  }
}
