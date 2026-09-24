import 'package:count_up/models/exercise.dart';
import 'package:count_up/widgets/exercise_form_field.dart';
import 'package:flutter/material.dart';
import 'package:count_up/utils/validate_exercise.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class EditExercisesScreen extends StatefulWidget {
  final int workoutKey;
  final List<Exercise> exercises;
  final Future<int> Function(int, List<Map>) modifyExercise;
  final void Function() returnToStaticList;
  final Future<bool> Function() onPop;
  const EditExercisesScreen(
      {Key? key,
      required this.modifyExercise,
      required this.returnToStaticList,
      required this.onPop,
      required this.workoutKey,
      required this.exercises})
      : super(key: key);

  @override
  State<EditExercisesScreen> createState() => _EditExercisesScreenState();
}

class _EditExercisesScreenState extends State<EditExercisesScreen> {
  final _formKey = GlobalKey<FormState>();
  List<List<String>> _data = [];
  List<bool> _hasChanged = [];

  List<List<String>> formatExercises(List<Exercise> ex) {
    List<List<String>> list = [];
    for (Exercise e in ex) list.add(<String>[e.name, e.duration.toString()]);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _data = formatExercises(widget.exercises);
    _hasChanged = List<bool>.filled(_data.length, false);
  }

  void _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    final bool shouldPop = await widget.onPop();
    if (shouldPop && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: _onPopInvoked,
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
          body: Form(
              key: _formKey,
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: ListView.builder(
                              itemCount: _data.length,
                              itemBuilder: (context, index) {
                                return Row(
                                    key: UniqueKey(),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          child: ExerciseFormField(
                                        initialValue: [..._data[index]],
                                        onSaved: (newValue) {
                                          var old = _data[index];
                                          if (newValue == null) {
                                            _hasChanged[index] = false;
                                            return;
                                          }
                                          if (newValue[0] != old[0] ||
                                              newValue[1] != old[1]) {
                                            _hasChanged[index] = true;
                                            _data[index] = newValue;
                                          }
                                        },
                                        validator: validateExercise(AppLocalizations.of(context)),
                                      ))
                                    ]);
                              })),
                      SizedBox(
                          width: 75,
                          child: ElevatedButton(
                            onPressed: () async {
                              var valid = _formKey.currentState!.validate();
                              if (!valid) {
                                return;
                              }
                              _formKey.currentState!.save();
                              List<Map> toModify = [];
                              for (int i = 0; i < _hasChanged.length; i++) {
                                if (_hasChanged[i]) {
                                  toModify.add({
                                    'index': i,
                                    'name': _data[i][0],
                                    'duration': int.parse(_data[i][1])
                                  });
                                }
                              }
                              if (toModify.length > 0)
                                await widget.modifyExercise(widget.workoutKey, toModify);

                              widget.returnToStaticList();
                            },
                            child: Text(l10n.saveBtn),
                          ))
                    ],
                  ))),
        ));
  }
}
