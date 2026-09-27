import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_workout_screen.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/services/storage_service.dart';
import 'package:count_up/services/workout_backup_service.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/danger_confirm_dialog.dart';
import 'package:count_up/widgets/icon_text_item.dart';
import 'package:flutter/material.dart';
import '../widgets/exercises_form.dart';
import '../widgets/static_exercises_list.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum WorkoutView { staticList, add, editWorkout, editExercise }

enum WorkoutAction { addExercise, editWorkout, editExercise, deleteWorkout, exportWorkout }

class ExercisesScreen extends StatefulWidget {
  final int workoutKey;
  final StorageService db;
  const ExercisesScreen({Key? key, required this.db, required this.workoutKey})
      : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout _w;
  var _currentView = WorkoutView.staticList;
  late Widget _child;
  bool _invalid = false;

  Future<bool> _onPop() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final l10n = AppLocalizations.of(context);
            return AlertDialog(
              title: Text(
                l10n.unsavedChangesTitle,
              ),
              content: Text(
                l10n.discardChangesConfirm,
              ),
              actions: <Widget>[
                TextButton(
                    child: Text(l10n.yesBtn),
                    onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text(l10n.noBtn),
                    onPressed: () => Navigator.of(context).pop(false)),
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _confirmAndDeleteWorkout(int workoutKey) async {
    final confirmed = await DangerConfirmDialog.show(
      context,
      message: AppLocalizations.of(context).confirmDeleteWorkout(_w.name, _w.exercises.length),
    );
    if (confirmed) await widget.db.deleteWorkout(workoutKey);
    return confirmed;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).errorWithMessage(message))),
    );
  }

  void initState() {
    super.initState();
    final workout = widget.db.getWorkout(widget.workoutKey);
    if (workout == null) {
      _invalid = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop<bool>(context, false);
      });
      return;
    }
    _w = workout;
    _child = StaticExerciseList(exercises: _w.exercises);
  }

  void _returnToStaticList() {
    setState(() {
      _currentView = WorkoutView.staticList;
      _child = StaticExerciseList(exercises: _w.exercises);
    });
  }

  String _getAppBarTitle(BuildContext context, WorkoutView view) {
    final l10n = AppLocalizations.of(context);
    switch (view) {
      case WorkoutView.staticList:
        return _w.name;
      case WorkoutView.add:
        return l10n.addExercisesTitle;
      case WorkoutView.editWorkout:
        return l10n.editWorkoutTitle;
      case WorkoutView.editExercise:
        return l10n.editExercisesTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_invalid)
      return const Center(
        child: CircularProgressIndicator(),
      );
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
            leading: _currentView == WorkoutView.staticList
                ? BackButton()
                : IconButton(onPressed: _returnToStaticList, icon: Icon(Icons.close)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(_getAppBarTitle(context, _currentView),
                style: TextStyle(fontFamily: "EthosNova", fontWeight: FontWeight.bold)),
            actions: _currentView == WorkoutView.staticList
                ? [
                    PopupMenuButton<WorkoutAction>(
                        offset: Offset.fromDirection(90, 50),
                        onSelected: (value) async {
                          switch (value) {
                            case WorkoutAction.addExercise:
                              if (_w.exercises.length >= maxExercisesPerWorkout) {
                                _showErrorSnackbar(
                                    l10n.workoutExerciseLimitError(maxExercisesPerWorkout));
                                break;
                              }
                              setState(() {
                                _currentView = WorkoutView.add;
                                _child = ExercisesForm(
                                  workoutKey: widget.workoutKey,
                                  currentExerciseCount: _w.exercises.length,
                                  addWorkoutExercises: widget.db.addWorkoutExercises,
                                  returnToStaticList: _returnToStaticList,
                                  onPop: _onPop,
                                );
                              });
                              break;
                            case WorkoutAction.editWorkout:
                              setState(() {
                                _currentView = WorkoutView.editWorkout;
                                _child = EditWorkoutScreen(
                                    workout: _w,
                                    workoutNames: widget.db.getAllWorkoutNames(),
                                    workoutKey: widget.workoutKey,
                                    updateWorkoutName: widget.db.updateWorkoutName,
                                    updateWorkoutExercises: widget.db.updateWorkoutExercises,
                                    returnToStaticList: _returnToStaticList,
                                    onPop: _onPop);
                              });
                              break;
                            case WorkoutAction.editExercise:
                              setState(() {
                                _currentView = WorkoutView.editExercise;
                                _child = EditExercisesScreen(
                                    exercises: _w.exercises,
                                    modifyExercise: widget.db.modifyExercises,
                                    workoutKey: widget.workoutKey,
                                    returnToStaticList: _returnToStaticList,
                                    onPop: _onPop);
                              });
                              break;
                            case WorkoutAction.exportWorkout:
                              var error = await WorkoutBackupService(widget.db).exportWorkout(_w);
                              if (error != null) {
                                _showErrorSnackbar(exportErrorMessage(context, error));
                              }
                              break;
                            case WorkoutAction.deleteWorkout:
                              await _confirmAndDeleteWorkout(widget.workoutKey).then((value) {
                                if (value) Navigator.pop(context);
                              });
                              break;
                          }
                        },
                        itemBuilder: (context) => <PopupMenuEntry<WorkoutAction>>[
                              PopupMenuItem<WorkoutAction>(
                                child: Opacity(
                                  opacity: _w.exercises.length >= maxExercisesPerWorkout ? 0.38 : 1,
                                  child: IconTextItem(
                                    icon: Icons.add,
                                    text: l10n.addExercisesTitle,
                                  ),
                                ),
                                value: WorkoutAction.addExercise,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.reorder,
                                  text: l10n.editWorkoutTitle,
                                ),
                                value: WorkoutAction.editWorkout,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.edit,
                                  text: l10n.editExercisesTitle,
                                ),
                                value: WorkoutAction.editExercise,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.download,
                                  text: l10n.exportMenuItem,
                                ),
                                value: WorkoutAction.exportWorkout,
                              ),
                              PopupMenuItem<WorkoutAction>(
                                child: IconTextItem(
                                  icon: Icons.delete,
                                  text: l10n.deleteWorkoutMenuItem,
                                ),
                                value: WorkoutAction.deleteWorkout,
                              ),
                            ]),
                  ]
                : []),
        body: _child);
  }
}
