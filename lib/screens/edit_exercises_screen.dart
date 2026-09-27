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
  late final List<GlobalKey<FormFieldState<List<String>>>> _fieldKeys;
  late final List<List<String>> _originalData;
  late final List<List<String>> _data;

  List<List<String>> formatExercises(List<Exercise> ex) {
    List<List<String>> list = [];
    for (Exercise e in ex) list.add(<String>[e.name, e.duration.toString()]);
    return list;
  }

  @override
  void initState() {
    super.initState();
    _originalData = formatExercises(widget.exercises);
    _data = _originalData.map((entry) => List<String>.of(entry)).toList();
    _fieldKeys = List.generate(
      _data.length,
      (_) => GlobalKey<FormFieldState<List<String>>>(),
    );
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final firstError = _fieldKeys.firstWhere((key) => key.currentState!.hasError);
      await Scrollable.ensureVisible(
        firstError.currentContext!,
        alignment: 0.1,
        duration: const Duration(milliseconds: 300),
      );
      return;
    }

    final toModify = <Map>[];
    for (int i = 0; i < _data.length; i++) {
      final draft = _data[i];
      final original = _originalData[i];
      if (draft[0] != original[0] || draft[1] != original[1]) {
        toModify.add({
          'index': i,
          'name': draft[0],
          'duration': int.parse(draft[1]),
        });
      }
    }

    if (toModify.isNotEmpty) {
      await widget.modifyExercise(widget.workoutKey, toModify);
    }
    if (mounted) widget.returnToStaticList();
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
          body: SafeArea(
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                for (int i = 0; i < _data.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 16, right: 12),
                                          child: Text('${i + 1}.'),
                                        ),
                                        Expanded(
                                          child: ExerciseFormField(
                                            key: _fieldKeys[i],
                                            initialValue: [..._data[i]],
                                            onChanged: (newValue) {
                                              _data[i] = List<String>.of(newValue);
                                            },
                                            validator: validateExercise(l10n),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 75,
                        child: ElevatedButton(
                          onPressed: _save,
                          child: Text(l10n.saveBtn),
                        ),
                      ),
                    ],
                  ))),
        ));
  }
}
