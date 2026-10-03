import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/countdown_screen.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/screens/timer_screen.dart';
import 'package:count_up/services/storage_service.dart';
import 'package:count_up/services/timer_audio_service.dart';
import 'package:count_up/services/workout_backup_service.dart';
import 'package:count_up/state/settings_provider.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/widgets/danger_confirm_dialog.dart';
import 'package:count_up/widgets/icon_text_item.dart';
import 'package:count_up/widgets/workout_name_form.dart';
import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import '../widgets/static_exercises_list.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

enum WorkoutAction { editExercise, deleteWorkout, exportWorkout }

const int _kWorkoutNameMaxLines = 2;

class ExercisesScreen extends StatefulWidget {
  final int workoutKey;
  final StorageService db;
  const ExercisesScreen({Key? key, required this.db, required this.workoutKey}) : super(key: key);

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  late Workout _w;
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
                    child: Text(l10n.yesBtn), onPressed: () => Navigator.of(context).pop(true)),
                TextButton(
                    child: Text(l10n.noBtn), onPressed: () => Navigator.of(context).pop(false)),
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
  }

  void _reloadWorkout() {
    final workout = widget.db.getWorkout(widget.workoutKey);
    if (workout != null) setState(() => _w = workout);
  }

  Future<void> _goToEditExercises({required bool initiallyOpenSheet}) async {
    await Navigator.push(
        context,
        MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => EditExercisesScreen(
                exercises: _w.exercises,
                updateWorkoutExercises: widget.db.updateWorkoutExercises,
                workoutKey: widget.workoutKey,
                onPop: _onPop,
                initiallyOpenSheet: initiallyOpenSheet)));
    if (mounted) _reloadWorkout();
  }

  Future<void> _renameWorkout() async {
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        content: WorkoutNameForm(
          initial: _w.name,
          label: l10n.renameWorkoutLabel,
          submitLabel: l10n.saveBtn,
          existingNames: widget.db.getAllWorkoutNames(),
          onSubmit: (name) async {
            if (name != _w.name) await widget.db.updateWorkoutName(widget.workoutKey, name);
            return null;
          },
        ),
        elevation: 24,
      ),
    );
    if (mounted) _reloadWorkout();
  }

  void _startWorkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TimerScreen(
          e: _w.exercises,
          player: TimerAudioService(Assets.audioExerciseChange),
        ),
      ),
    );
  }

  Future<void> _countdownAndStart() async {
    final countdownSeconds = SettingsProvider.of(context).preWorkoutCountdownSeconds;

    if (countdownSeconds <= 0) {
      _startWorkout();
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

    if (shouldStart == true && mounted) {
      _startWorkout();
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
            leading: BackButton(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton<WorkoutAction>(
                  offset: Offset.fromDirection(90, 50),
                  onSelected: (value) async {
                    switch (value) {
                      case WorkoutAction.editExercise:
                        await _goToEditExercises(initiallyOpenSheet: false);
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
                          child: IconTextItem(
                            icon: Icons.edit_note,
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
            ]),
        floatingActionButton: _w.exercises.isEmpty
            ? FloatingActionButton.extended(
                shape: StadiumBorder(),
                onPressed: () => _goToEditExercises(initiallyOpenSheet: true),
                icon: Icon(Icons.add),
                label: Text(l10n.addExercisesBtn),
              )
            : FloatingActionButton(
                shape: StadiumBorder(),
                tooltip: l10n.startWorkoutTooltip,
                onPressed: _countdownAndStart,
                child: Icon(Icons.play_arrow),
              ),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.only(left: 32, bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(
                        _w.name,
                        maxLines: _kWorkoutNameMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontFamily: Assets.fontEthosNova, fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: AppLocalizations.of(context).renameWorkoutTooltip,
                  iconSize: 16,
                  onPressed: _renameWorkout,
                ),
              ],
            ),
          ),
          Expanded(child: StaticExerciseList(exercises: _w.exercises)),
        ]));
  }
}
