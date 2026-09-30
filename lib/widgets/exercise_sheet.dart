import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/exercise_draft.dart';
import 'package:count_up/models/exercise_type.dart';
import 'package:count_up/utils/validate_exercise.dart';

const double _kSheetContentPadding = 20;

Future<Exercise?> showExerciseSheet(BuildContext context, {Exercise? initial}) {
  return showModalBottomSheet<Exercise>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => ExerciseSheet(initial: initial),
  );
}

class ExerciseSheet extends StatefulWidget {
  final Exercise? initial;
  const ExerciseSheet({Key? key, this.initial}) : super(key: key);

  @override
  State<ExerciseSheet> createState() => _ExerciseSheetState();
}

class _ExerciseSheetState extends State<ExerciseSheet> {
  ExerciseDraft? _original;
  late ExerciseType _type;
  late final TextEditingController _nameController;
  late final TextEditingController _valueController;
  String? _error;

  bool get _isEdit => _original != null;

  ExerciseDraft get _draft => ExerciseDraft(
        name: _nameController.text,
        value: _valueController.text,
        type: _type,
      );

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _original = initial == null ? null : ExerciseDraft.fromExercise(initial);
    _type = _original?.type ?? ExerciseType.duration;
    _nameController = TextEditingController(text: _original?.name ?? '');
    _valueController = TextEditingController(text: _original?.value ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  void _typeChanged(ExerciseType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _valueController.clear();
      _error = null;
    });
  }

  void _done() {
    final draft = _draft;
    final original = _original;
    if (original != null &&
        draft.name == original.name &&
        draft.value == original.value &&
        draft.type == original.type) {
      Navigator.of(context).pop();
      return;
    }
    final error = validateExercise(AppLocalizations.of(context))(draft);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(draft.toExercise());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      // viewInsets.bottom is the on-screen keyboard's height (0 when it's closed).
      // Adding it lifts the sheet above the keyboard so the fields stay visible.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              _kSheetContentPadding, 0, _kSheetContentPadding, _kSheetContentPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEdit ? l10n.editExerciseTitle : l10n.addExerciseTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(onPressed: _done, child: Text(l10n.doneBtn)),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<ExerciseType>(
                showSelectedIcon: false,
                style: ButtonStyle(
                  visualDensity: VisualDensity(vertical: -2),
                  // Matches the M2 default enabled TextField underline colour.
                  side: WidgetStatePropertyAll(
                      BorderSide(color: colorScheme.onSurface.withValues(alpha: 0.4))),
                ),
                segments: [
                  ButtonSegment(
                    value: ExerciseType.duration,
                    label: Text(l10n.exerciseTypeDurationLabel),
                  ),
                  ButtonSegment(
                    value: ExerciseType.rep,
                    label: Text(l10n.exerciseTypeRepLabel),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) => _typeChanged(selection.first),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _nameController,
                      autofocus: !_isEdit,
                      enableSuggestions: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(hintText: l10n.exerciseNameHint),
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: TextField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _done(),
                      decoration: InputDecoration(
                        hintText: _type == ExerciseType.rep
                            ? l10n.exerciseRepsHint
                            : l10n.exerciseDurationHint,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    _error!,
                    style: TextStyle(color: colorScheme.error, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
