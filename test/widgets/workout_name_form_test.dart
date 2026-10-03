import 'package:count_up/widgets/workout_name_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

void main() {
  testWidgets('rejects an empty name', (tester) async {
    final form = _FormHarness();
    await form.pump(tester);

    await _submit(tester, '');

    expect(find.text('Please enter a name'), findsOneWidget);
    expect(form.submitted, isEmpty);
    expect(find.byType(WorkoutNameForm), findsOneWidget);
  });

  testWidgets('rejects a name already in use', (tester) async {
    final form = _FormHarness();
    await form.pump(tester);

    await _submit(tester, 'Legs');

    expect(find.text('Name already in use'), findsOneWidget);
    expect(form.submitted, isEmpty);
  });

  testWidgets('allows preserving the initial name even though it is in use', (tester) async {
    final form = _FormHarness(initial: 'Abs');
    await form.pump(tester);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(form.submitted, ['Abs']);
  });

  testWidgets('submits a new name and closes with the onSubmit result', (tester) async {
    final form = _FormHarness();
    await form.pump(tester);

    await _submit(tester, 'Core');

    expect(form.submitted, ['Core']);
    expect(form.dialogResult, 'result:Core');
    expect(find.byType(WorkoutNameForm), findsNothing);
  });
}

class _FormHarness {
  final String initial;
  final submitted = <String>[];
  Object? dialogResult;

  _FormHarness({this.initial = ''});

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(localizedApp(const SizedBox()));
    showDialog<Object?>(
      context: tester.element(find.byType(SizedBox)),
      builder: (_) => AlertDialog(
        content: WorkoutNameForm(
          initial: initial,
          label: 'Name',
          submitLabel: 'Submit',
          existingNames: const ['Abs', 'Legs'],
          onSubmit: (name) async {
            submitted.add(name);
            return 'result:$name';
          },
        ),
      ),
    ).then((result) => dialogResult = result);
    await tester.pumpAndSettle();
  }
}

Future<void> _submit(WidgetTester tester, String name) async {
  await tester.enterText(find.byType(TextFormField), name);
  await tester.tap(find.text('Submit'));
  await tester.pumpAndSettle();
}
