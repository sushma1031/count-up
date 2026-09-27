import 'package:count_up/models/exercise.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/widgets/exercise_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

void main() {
  testWidgets('renders 30 numbered rows in a scrollable form', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    expect(find.byType(ListView), findsNothing);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Column),
      ),
      findsWidgets,
    );
    expect(find.byType(Form), findsOneWidget);
    final form = tester.widget<Form>(find.byType(Form));
    expect(form.key, isA<GlobalKey<FormState>>());
    expect(form.autovalidateMode, AutovalidateMode.disabled);
    expect(find.byType(ExerciseFormField), findsNWidgets(30));
    for (int i = 0; i < 30; i++) {
      expect(_row(i), findsOneWidget);
      expect(_field(i), findsOneWidget);
      expect(tester.state(_field(i)).mounted, isTrue);
      expect(find.ancestor(of: _field(i), matching: find.byType(Form)),
          findsOneWidget);
      final field = tester.widget<ExerciseFormField>(_field(i));
      expect(field.key, isA<GlobalKey>());
      expect(field.autovalidateMode, AutovalidateMode.disabled);
      expect(find.descendant(of: _row(i), matching: find.text('${i + 1}.')),
          findsOneWidget);
      expect(find.descendant(of: _field(i), matching: find.text('${i + 1}.')),
          findsNothing);
      _expectDraft(tester, i, 'Exercise ${i + 1}', '60');
    }
    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
  });

  testWidgets('saves offscreen and visible edits in one exact batch',
      (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await _edit(tester, 0, 'Edited first', '91');
    editor.expectOriginalsUnchanged();
    await _scrollToLast(tester);
    await _edit(tester, 29, 'Edited last', '123');

    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
    await _save(tester);

    editor.expectSaved([
      {'index': 0, 'name': 'Edited first', 'duration': 91},
      {'index': 29, 'name': 'Edited last', 'duration': 123},
    ]);
  });

  testWidgets('preserves all field states and draft fields while scrolling',
      (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);
    final fieldStates = List.generate(30, (i) => tester.state(_field(i)));
    await _edit(tester, 0, 'Retained first', '87');

    await _scrollToLast(tester);
    for (int i = 0; i < 30; i++) {
      expect(tester.state(_field(i)), same(fieldStates[i]));
      expect(fieldStates[i].mounted, isTrue);
    }
    _expectDraft(tester, 0, 'Retained first', '87');
    await _scrollTo(tester, 0);

    for (int i = 0; i < 30; i++) {
      expect(tester.state(_field(i)), same(fieldStates[i]));
      expect(fieldStates[i].mounted, isTrue);
    }
    _expectDraft(tester, 0, 'Retained first', '87');
    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
  });

  testWidgets('parent rebuild preserves offscreen field state and edits',
      (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);
    final fieldStates = List.generate(30, (i) => tester.state(_field(i)));
    await _edit(tester, 0, 'Rebuilt first', '82');
    await _scrollToLast(tester);

    editor.rebuild(() {});
    await tester.pump();

    expect(find.byType(ExerciseFormField), findsNWidgets(30));
    for (int i = 0; i < 30; i++) {
      expect(tester.state(_field(i)), same(fieldStates[i]));
      expect(fieldStates[i].mounted, isTrue);
    }
    _expectDraft(tester, 0, 'Rebuilt first', '82');
    await _scrollTo(tester, 0);
    _expectDraft(tester, 0, 'Rebuilt first', '82');
    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
    await _save(tester);
    editor.expectSaved([
      {'index': 0, 'name': 'Rebuilt first', 'duration': 82},
    ]);
  });

  testWidgets('save scrolls to the first invalid row', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await _scrollTo(tester, 20);
    await _edit(tester, 20, 'Exercise 21', '0');
    await _scrollTo(tester, 12);
    await _edit(tester, 12, '', '60');
    await _scrollTo(tester, 29);
    expect(_field(12).hitTestable(), findsNothing);

    await _save(tester);

    _expectInViewport(tester, _field(12));
  });
}

Finder _field(int index) => find.byType(ExerciseFormField).at(index);

Finder _row(int index) =>
    find.ancestor(of: _field(index), matching: find.byType(Row)).first;

Finder _input(int index, int part) => find
    .descendant(of: _field(index), matching: find.byType(TextField))
    .at(part);

Future<void> _edit(
    WidgetTester tester, int index, String name, String duration) async {
  await tester.enterText(_input(index, 0), name);
  await tester.enterText(_input(index, 1), duration);
  await tester.pump();
}

void _expectDraft(
    WidgetTester tester, int index, String name, String duration) {
  expect(tester.widget<TextField>(_input(index, 0)).controller!.text, name);
  expect(tester.widget<TextField>(_input(index, 1)).controller!.text, duration);
}

void _expectInViewport(WidgetTester tester, Finder finder) {
  expect(finder.hitTestable(), findsOneWidget);
  final viewport = tester.getRect(find.byType(SingleChildScrollView));
  final rect = tester.getRect(finder);
  expect(rect.top, greaterThanOrEqualTo(viewport.top - 0.1));
  expect(rect.bottom, lessThanOrEqualTo(viewport.bottom + 0.1));
}

Future<void> _scrollTo(WidgetTester tester, int index) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.ensureVisible(_row(index));
  await tester.pumpAndSettle();
}

Future<void> _scrollToLast(WidgetTester tester) async {
  final firstState = tester.state(_field(0));
  await _scrollTo(tester, 29);
  expect(_row(0), findsOneWidget);
  expect(_field(0), findsOneWidget);
  expect(_field(0).hitTestable(), findsNothing);
  expect(tester.state(_field(0)), same(firstState));
  expect(firstState.mounted, isTrue);
  expect(find.byType(ExerciseFormField), findsNWidgets(30));
  _expectInViewport(tester, _field(29));
}

Future<void> _save(WidgetTester tester) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
  await tester.pumpAndSettle();
}

class _EditorHarness {
  final exercises = List.generate(30, (i) => Exercise('Exercise ${i + 1}', 60));
  final writes = <Map<String, Object>>[];
  late final List<List<Object>> _originalValues;
  late StateSetter rebuild;
  int returns = 0;

  _EditorHarness() {
    _originalValues = _values;
  }

  List<List<Object>> get _values => exercises
      .map((exercise) => <Object>[exercise.name, exercise.duration])
      .toList();

  Future<void> pump(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(localizedApp(
      StatefulBuilder(builder: (context, setState) {
        rebuild = setState;
        return EditExercisesScreen(
          workoutKey: 42,
          exercises: exercises,
          modifyExercise: (key, updates) async {
            expectOriginalsUnchanged();
            writes.add({
              'workoutKey': key,
              'updates': updates.map((update) => Map.of(update)).toList(),
            });
            return updates.length;
          },
          returnToStaticList: () => returns++,
          onPop: () async => true,
        );
      }),
    ));
    await tester.pumpAndSettle();
  }

  void expectOriginalsUnchanged() => expect(_values, _originalValues);

  void expectSaved(List<Map> updates) {
    expect(writes, [
      {'workoutKey': 42, 'updates': updates},
    ]);
    expect(returns, 1);
    expectOriginalsUnchanged();
  }
}
