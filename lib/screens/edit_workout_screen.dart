import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/widgets/exercise_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class EditWorkoutScreen extends StatefulWidget {
  final Workout workout;
  final List<String> workoutNames;
  final int workoutKey;
  final Future<Workout?> Function(int key, String name) updateWorkoutName;
  final Future<Workout?> Function(int key, List<Exercise> newExercises)
      updateWorkoutExercises;
  final Future<bool> Function() onPop;

  const EditWorkoutScreen(
      {Key? key,
      required this.workout,
      required this.workoutNames,
      required this.workoutKey,
      required this.updateWorkoutName,
      required this.updateWorkoutExercises,
      required this.onPop})
      : super(key: key);

  @override
  State<EditWorkoutScreen> createState() => _EditWorkoutScreenState();
}

class _EditWorkoutScreenState extends State<EditWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  late final List<Exercise> _ex;
  String _name = '';

  @override
  void initState() {
    super.initState();
    _name = widget.workout.name;
    _ex = <Exercise>[...widget.workout.exercises];
  }

  bool get _hasChanges =>
      widget.workout.name != _name || !listEquals(widget.workout.exercises, _ex);

  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    if (await widget.onPop() && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (widget.workout.name != _name) {
      await widget.updateWorkoutName(widget.workoutKey, _name);
    }
    if (!listEquals(widget.workout.exercises, _ex))
      await widget.updateWorkoutExercises(widget.workoutKey, _ex);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
        // Leaving without changes needs no confirmation (and allows predictive back).
        canPop: !_hasChanges,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            appBar: AppBar(
              leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(l10n.editWorkoutTitle,
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
            body: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                          height: 100,
                          //seperate this as a component that can be reused
                          child: Form(
                              key: _formKey,
                              child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 25, right: 25, top: 10),
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    initialValue: widget.workout.name,
                                    enableSuggestions: true,
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return l10n.workoutNameRequired;
                                      }
                                      if (value != widget.workout.name &&
                                          widget.workoutNames.contains(value)) {
                                        return l10n.workoutNameAlreadyInUse;
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                        filled: false,
                                        labelText: l10n.workoutNameLabel,
                                        fillColor: Colors.white70),
                                    onChanged: (value) {
                                      setState(() => _name = value);
                                    },
                                    onSaved: (value) {
                                      _name = value!;
                                    },
                                  )))),
                      Expanded(
                          flex: 2,
                          child: ReorderableListView(
                              buildDefaultDragHandles: true,
                              children: <Widget>[
                                for (int index = 0; index < _ex.length; index++)
                                  ListTile(
                                    key: Key('$index'),
                                    leading: IconButton(
                                      icon: Icon(
                                        Icons.remove_circle_outline,
                                        size: 20,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _ex.removeAt(index);
                                        });
                                      },
                                    ),
                                    title: ExerciseItem(exercise: _ex[index]),
                                    trailing: ReorderableDragStartListener(
                                      index: index,
                                      child: Icon(
                                        Icons.drag_handle,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  )
                              ],
                              onReorder: (int oldIndex, int newIndex) {
                                setState(() {
                                  if (oldIndex < newIndex) {
                                    newIndex -= 1;
                                  }
                                  final Exercise item = _ex.removeAt(oldIndex);
                                  _ex.insert(newIndex, item);
                                });
                              })),
                    ]))));
  }
}
