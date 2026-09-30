import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/exercise_type.dart';
import 'package:count_up/widgets/exercise_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

class _SheetResult {
  Exercise? exercise;
  bool closed = false;
}

Future<_SheetResult> _openSheet(WidgetTester tester, {Exercise? initial}) async {
  final result = _SheetResult();
  await tester.pumpWidget(localizedApp(Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            result.exercise = await showExerciseSheet(context, initial: initial);
            result.closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ),
  )));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return result;
}

final _typeSelector = find.byWidgetPredicate((w) => w is SegmentedButton<ExerciseType>);
final _nameField = find.byType(TextField).at(0);
final _valueField = find.byType(TextField).at(1);

ExerciseType _selectedType(WidgetTester tester) =>
    tester.widget<SegmentedButton<ExerciseType>>(_typeSelector).selected.single;

String _text(WidgetTester tester, Finder field) =>
    tester.widget<TextField>(field).controller!.text;

void main() {
  group('add mode', () {
    testWidgets('starts empty with Duration selected', (tester) async {
      await _openSheet(tester);

      expect(find.text('Add Exercise'), findsOneWidget);
      expect(_selectedType(tester), ExerciseType.duration);
      expect(_text(tester, _nameField), isEmpty);
      expect(_text(tester, _valueField), isEmpty);
      expect(find.text('Seconds'), findsOneWidget);
    });

    testWidgets('Done returns a Duration exercise', (tester) async {
      final result = await _openSheet(tester);

      await tester.enterText(_nameField, 'Plank');
      await tester.enterText(_valueField, '45');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(result.closed, isTrue);
      final exercise = result.exercise as DurationExercise;
      expect(exercise.name, 'Plank');
      expect(exercise.duration, 45);
    });

    testWidgets('Done returns a Rep exercise after switching type', (tester) async {
      final result = await _openSheet(tester);

      await tester.tap(find.text('Reps'));
      await tester.pumpAndSettle();
      expect(_selectedType(tester), ExerciseType.rep);

      await tester.enterText(_nameField, 'Push-ups');
      await tester.enterText(_valueField, '12');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final exercise = result.exercise as RepExercise;
      expect(exercise.name, 'Push-ups');
      expect(exercise.reps, 12);
    });

    testWidgets('keyboard done on the value field submits', (tester) async {
      final result = await _openSheet(tester);

      await tester.enterText(_nameField, 'Squats');
      await tester.enterText(_valueField, '30');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(result.closed, isTrue);
      expect(result.exercise, isA<DurationExercise>());
    });
  });

  group('validation', () {
    testWidgets('empty fields show an error and keep the sheet open', (tester) async {
      final result = await _openSheet(tester);

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Fields cannot be empty'), findsOneWidget);
      expect(result.closed, isFalse);
      expect(find.byType(ExerciseSheet), findsOneWidget);
    });

    testWidgets('out-of-range reps show the reps error', (tester) async {
      final result = await _openSheet(tester);

      await tester.tap(find.text('Reps'));
      await tester.pumpAndSettle();
      await tester.enterText(_nameField, 'Burpees');
      await tester.enterText(_valueField, '1000');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('Reps must be in range [1, 999]'), findsOneWidget);
      expect(result.closed, isFalse);
    });
  });

  group('edit mode', () {
    testWidgets('starts with the exercise values', (tester) async {
      await _openSheet(tester, initial: RepExercise('Lunges', 20));

      expect(find.text('Edit Exercise'), findsOneWidget);
      expect(_selectedType(tester), ExerciseType.rep);
      expect(_text(tester, _nameField), 'Lunges');
      expect(_text(tester, _valueField), '20');
    });

    testWidgets('Done without changes returns null', (tester) async {
      final result = await _openSheet(tester, initial: DurationExercise('Plank', 60));

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(result.closed, isTrue);
      expect(result.exercise, isNull);
    });

    testWidgets('returns a new exercise without mutating the original', (tester) async {
      final original = DurationExercise('Plank', 60);
      final result = await _openSheet(tester, initial: original);

      await tester.enterText(_nameField, 'Side plank');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final edited = result.exercise as DurationExercise;
      expect(edited, isNot(same(original)));
      expect(edited.name, 'Side plank');
      expect(edited.duration, 60);
      expect(original.name, 'Plank');
    });

    testWidgets('switching type clears the value and returns the new type', (tester) async {
      final result = await _openSheet(tester, initial: DurationExercise('Plank', 60));

      await tester.tap(find.text('Reps'));
      await tester.pumpAndSettle();
      expect(_text(tester, _valueField), isEmpty);
      expect(_text(tester, _nameField), 'Plank');

      await tester.enterText(_valueField, '10');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final exercise = result.exercise as RepExercise;
      expect(exercise.name, 'Plank');
      expect(exercise.reps, 10);
    });
  });

  testWidgets('dismissing discards changes', (tester) async {
    final result = await _openSheet(tester, initial: DurationExercise('Plank', 60));

    await tester.enterText(_nameField, 'Changed');
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(result.closed, isTrue);
    expect(result.exercise, isNull);
    expect(find.byType(ExerciseSheet), findsNothing);
  });
}
