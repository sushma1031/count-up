import 'package:count_up/utils/validate_exercise.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/exercise_form_field.dart';
import 'package:flutter/material.dart';
import '../models/exercise.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class ExercisesForm extends StatefulWidget {
  final Future<void> Function(int, List<Exercise>) addWorkoutExercises;
  final void Function() returnToStaticList;
  final int workoutKey;
  final int currentExerciseCount;
  final Future<bool> Function() onPop;
  const ExercisesForm(
      {Key? key,
      required this.addWorkoutExercises,
      required this.returnToStaticList,
      required this.onPop,
      required this.workoutKey,
      required this.currentExerciseCount})
      : super(key: key);
  @override
  State<ExercisesForm> createState() => _ExercisesFormState();
}

class _ExercisesFormState extends State<ExercisesForm> {
  final _formKey = GlobalKey<FormState>();
  int _rows = 1;
  List<List<String>> _allData = [];

  @override
  void initState() {
    super.initState();
    if (widget.currentExerciseCount >= maxExercisesPerWorkout) {
      _rows = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showExerciseLimitError();
      });
    }
  }

  void _showExerciseLimitError() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(AppLocalizations.of(context)
          .workoutExerciseLimitError(maxExercisesPerWorkout)),
    ));
  }

  void updateAllData(List<String> data, int index) {
    if (index < _allData.length) {
      _allData[index] = data;
    } else {
      _allData.add(data);
    }
  }

  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) return;
    final shouldPop = await widget.onPop();

    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
        canPop: _rows == 0,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerLowest,
            body: Form(
                key: _formKey,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_rows == 0)
                            Text(l10n.workoutExerciseLimitError(maxExercisesPerWorkout)),
                          Expanded(
                            child: ListView.builder(
                                itemCount: _rows,
                                itemBuilder: (context, index) {
                                  return Row(
                                      key: UniqueKey(),
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        IconButton(
                                            onPressed: (_rows == 1)
                                                ? null
                                                : () {
                                                    setState(() {
                                                      if (index <
                                                          _allData.length)
                                                        _allData
                                                            .removeAt(index);
                                                      _rows--;
                                                    });
                                                  },
                                            icon: Icon(
                                              Icons.remove_circle,
                                              size: 16,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.8),
                                            )),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16, right: 12),
                                          child: Text(
                                              '${widget.currentExerciseCount + index + 1}.'),
                                        ),
                                        Expanded(
                                            child: ExerciseFormField(
                                          initialValue:
                                              (index < _allData.length)
                                                  ? _allData[index]
                                                  : ["", ""],
                                          onSaved: (newValue) {
                                            updateAllData(newValue!, index);
                                          },
                                          validator: validateExercise(
                                              AppLocalizations.of(context)),
                                        )),
                                        SizedBox(
                                            width: 45,
                                            child: (index < _rows - 1)
                                                ? null
                                                : IconButton(
                                                    onPressed: () {
                                                      if (widget.currentExerciseCount + _rows >=
                                                          maxExercisesPerWorkout) {
                                                        _showExerciseLimitError();
                                                        return;
                                                      }
                                                      var valid = _formKey
                                                          .currentState!
                                                          .validate();
                                                      if (!valid) {
                                                        return;
                                                      }
                                                      _formKey.currentState!
                                                          .save();

                                                      setState(() {
                                                        _rows++;
                                                      });
                                                    },
                                                    icon: Icon(
                                                      Icons.add_box,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .secondary,
                                                      size: 20,
                                                    ),
                                                    tooltip:
                                                        l10n.addAnotherExerciseTooltip,
                                                  ))
                                      ]);
                                }),
                          ),
                          SizedBox(
                              width: 75,
                              child: ElevatedButton(
                                onPressed: _rows == 0 ? null : () async {
                                  if (widget.currentExerciseCount + _rows >
                                      maxExercisesPerWorkout) {
                                    _showExerciseLimitError();
                                    return;
                                  }
                                  var valid = _formKey.currentState!.validate();
                                  if (!valid) {
                                    return;
                                  }
                                  _formKey.currentState!.save();
                                  List<Exercise> ex = _allData
                                      .map((e) =>
                                          Exercise(e[0], int.parse(e[1])))
                                      .toList();

                                  await widget.addWorkoutExercises(
                                      widget.workoutKey, ex);
                                  widget.returnToStaticList();
                                },
                                child: Text(l10n.saveBtn),
                              ))
                        ])))));
  }
}
