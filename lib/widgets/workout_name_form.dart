import 'package:flutter/material.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

class WorkoutNameForm extends StatefulWidget {
  final String initial;
  final String label;
  final String submitLabel;
  final List<String> existingNames;
  final Future<Object?> Function(String) onSubmit;
  const WorkoutNameForm({
    Key? key,
    required this.initial,
    required this.label,
    required this.submitLabel,
    required this.existingNames,
    required this.onSubmit,
  }) : super(key: key);
  @override
  State<WorkoutNameForm> createState() => _WorkoutNameFormState();
}

class _WorkoutNameFormState extends State<WorkoutNameForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller = TextEditingController(text: widget.initial)
  ..selection = TextSelection(baseOffset: 0, extentOffset: widget.initial.length);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await widget.onSubmit(_controller.text);
    if (mounted) Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Form(
        key: _formKey,
        child: SizedBox(
            height: 150,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                      child: TextFormField(
                    controller: _controller,
                    autofocus: true,
                    enableSuggestions: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (String? value) {
                      if (value == null || value.isEmpty) {
                        return l10n.nameRequired;
                      }
                      if (value != widget.initial && widget.existingNames.contains(value)) {
                        return l10n.workoutNameAlreadyInUse;
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: widget.label,
                    ),
                  )),
                  ElevatedButton(
                    onPressed: _submit,
                    child: Text(widget.submitLabel),
                  )
                ])));
  }
}
