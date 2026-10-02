import 'dart:math';

import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/exercise_item.dart';
import 'package:count_up/widgets/exercise_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class EditExercisesScreen extends StatefulWidget {
  final int workoutKey;
  final List<Exercise> exercises;
  final Future<Workout?> Function(int key, List<Exercise> newExercises) updateWorkoutExercises;
  final Future<bool> Function() onPop;
  const EditExercisesScreen(
      {Key? key,
      required this.updateWorkoutExercises,
      required this.onPop,
      required this.workoutKey,
      required this.exercises})
      : super(key: key);

  @override
  State<EditExercisesScreen> createState() => _EditExercisesScreenState();
}

class _EditExercisesScreenState extends State<EditExercisesScreen> {
  late final List<Exercise> _exercises = List.of(widget.exercises);

  bool get _hasChanges => !listEquals(widget.exercises, _exercises);

  void _showSnackBar(SnackBar snackBar) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  Future<void> _add() async {
    final l10n = AppLocalizations.of(context);
    if (_exercises.length >= maxExercisesPerWorkout) {
      _showSnackBar(
          SnackBar(content: Text(l10n.workoutExerciseLimitError(maxExercisesPerWorkout))));
      return;
    }
    final exercise = await showExerciseSheet(context);
    if (exercise == null || !mounted) return;
    setState(() => _exercises.add(exercise));
  }

  Future<void> _edit(int index) async {
    final exercise = await showExerciseSheet(context, initial: _exercises[index]);
    if (exercise == null || !mounted) return;
    setState(() => _exercises[index] = exercise);
  }

  void _delete(int index) {
    final l10n = AppLocalizations.of(context);
    final removed = _exercises[index];
    setState(() => _exercises.removeAt(index));
    _showSnackBar(SnackBar(
      content: Text(l10n.exerciseDeletedMessage(removed.name)),
      action: SnackBarAction(
        label: l10n.undoBtn,
        onPressed: () {
          if (!mounted) return;
          setState(() => _exercises.insert(min(index, _exercises.length), removed));
        },
      ),
    ));
  }

  Future<void> _save() async {
    if (_hasChanges) {
      await widget.updateWorkoutExercises(widget.workoutKey, List.of(_exercises));
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      // Otherwise an Undo snackbar would outlive this screen.
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      return;
    }
    if (await widget.onPop() && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _buildRow(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    final exercise = _exercises[index];
    return Dismissible(
      key: ObjectKey(exercise),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(Icons.delete, color: Theme.of(context).colorScheme.onError),
      ),
      // Since swiping isn't available to screen readers, expose delete as an action.
      child: Semantics(
        customSemanticsActions: {
          CustomSemanticsAction(label: l10n.deleteExerciseAction): () => _delete(index),
        },
        child: ListTile(
          titleAlignment: ListTileTitleAlignment.center,
          leading: Text('${index + 1}.', style: const TextStyle(fontSize: 16)),
          minLeadingWidth: 24,
          title: ExerciseItem(exercise: exercise),
          onTap: () => _edit(index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          appBar: AppBar(
            leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(l10n.editExercisesTitle,
                style: TextStyle(fontFamily: "EthosNova", fontWeight: FontWeight.bold)),
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(visualDensity: VisualDensity(vertical: -1)),
                    onPressed: _save,
                    child: Text(l10n.saveBtn),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: StadiumBorder(),
            tooltip: l10n.addExerciseTooltip,
            onPressed: _add,
            child: Icon(Icons.add),
          ),
          body: SafeArea(
              child: Padding(
            padding: EdgeInsets.all(16),
            child: _exercises.isEmpty
                ? Center(child: Text(l10n.noExercisesHint))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _exercises.length,
                    itemBuilder: _buildRow,
                  ),
          )),
        ));
  }
}
