import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/state/settings_provider.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/exercise_sheet.dart';
import 'package:count_up/widgets/break_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_settings_service.dart';
import '../test_app.dart';

void main() {
  testWidgets('renders numbered rows without writing', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    final names = ['Plank', 'Push-ups', 'Squats'];
    for (int i = 0; i < names.length; i++) {
      final tile = find.ancestor(of: find.text(names[i]), matching: find.byType(ListTile));
      expect(find.descendant(of: tile, matching: find.text('${i + 1}.')), findsOneWidget);
    }
    expect(find.text('60s'), findsOneWidget);
    expect(find.text('12 reps'), findsOneWidget);
    expect(editor.writes, isEmpty);
  });

  testWidgets('tapping a row edits it in place', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.tap(find.text('Squats'));
    await tester.pumpAndSettle();
    expect(find.text('Edit Exercise'), findsOneWidget);
    await tester.enterText(_sheetField(1), '50');
    await _tapSheetDone(tester);
    await _save(tester);

    expect(editor.savedNames, ['Plank', 'Push-ups', 'Squats']);
    expect((editor.writes.single.exercises[2] as DurationExercise).duration, 50);
    editor.expectOriginalsUnchanged();
  });

  testWidgets('FAB adds an exercise to the end', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Add Exercise'), findsOneWidget);
    await tester.enterText(_sheetField(0), 'Lunges');
    await tester.enterText(_sheetField(1), '30');
    await _tapSheetDone(tester);

    expect(find.text('4.'), findsOneWidget);
    expect(editor.writes, isEmpty);

    await _save(tester);
    expect(editor.savedNames, ['Plank', 'Push-ups', 'Squats', 'Lunges']);
  });

  testWidgets('initiallyOpenSheet opens the add sheet on arrival', (tester) async {
    final editor = _EditorHarness(count: 0, initiallyOpenSheet: true);
    await editor.pump(tester);

    expect(find.text('Add Exercise'), findsOneWidget);
  });

  testWidgets('FAB at the exercise limit shows an error instead of the sheet', (tester) async {
    final editor = _EditorHarness(
        count: maxExercisesPerWorkout, makeExercise: (i) => DurationExercise('Ex $i', 10));
    await editor.pump(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseSheet), findsNothing);
    expect(find.text('Exercises limit reached: $maxExercisesPerWorkout'), findsOneWidget);
  });

  testWidgets('swipe deletes a row and Undo restores it in place', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.drag(find.text('Push-ups'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Push-ups'), findsNothing);
    expect(find.text('Push-ups deleted'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final tile = find.ancestor(of: find.text('Push-ups'), matching: find.byType(ListTile));
    expect(find.descendant(of: tile, matching: find.text('2.')), findsOneWidget);

    await _save(tester);
    expect(editor.writes, isEmpty, reason: 'delete + undo is not a change');
  });

  testWidgets('a deletion is saved when not undone', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.drag(find.text('Plank'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await _save(tester);

    expect(editor.savedNames, ['Push-ups', 'Squats']);
    expect(find.text('Plank deleted'), findsNothing,
        reason: 'the Undo snackbar must not outlive the screen');
  });

  testWidgets('drag handle reorders and renumbers rows correctly, and Save persists the changes',
      (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await _dragHandle(tester, 0, const Offset(0, 200));

    final tile = find.ancestor(of: find.text('Plank'), matching: find.byType(ListTile));
    expect(find.descendant(of: tile, matching: find.text('3.')), findsOneWidget);
    expect(editor.writes, isEmpty);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(editor.popPrompts, 1, reason: 'a reorder is an unsaved change');

    await _save(tester);
    expect(editor.savedNames, ['Push-ups', 'Squats', 'Plank']);
    editor.expectOriginalsUnchanged();
  });

  testWidgets('close with changes discards them without asking', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.drag(find.text('Plank'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(editor.popPrompts, 0);
    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.text('Plank deleted'), findsNothing);
    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
  });

  testWidgets('back without changes leaves without asking', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(editor.popPrompts, 0);
    expect(find.byType(EditExercisesScreen), findsNothing);
  });

  testWidgets('back with changes asks, and stays when not confirmed', (tester) async {
    final editor = _EditorHarness();
    await editor.pump(tester);

    await tester.drag(find.text('Plank'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(editor.popPrompts, 1);
    expect(find.byType(EditExercisesScreen), findsOneWidget);
    expect(editor.writes, isEmpty);
  });

  testWidgets('back with changes discards them when confirmed', (tester) async {
    final editor = _EditorHarness(confirmDiscard: true);
    await editor.pump(tester);

    await tester.drag(find.text('Plank'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(editor.popPrompts, 1);
    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.text('Plank deleted'), findsNothing);
    expect(editor.writes, isEmpty);
    editor.expectOriginalsUnchanged();
  });

  group('break duration', () {
    Future<void> openBreakSheet(WidgetTester tester) async {
      await tester.tap(find.byType(BreakItem));
      await tester.pumpAndSettle();
    }

    Finder pill(String label) => find.widgetWithText(ChoiceChip, label);

    testWidgets('is hidden with fewer than two exercises', (tester) async {
      final editor = _EditorHarness(count: 1);
      await editor.pump(tester);

      expect(find.byType(BreakItem), findsNothing);
    });

    testWidgets('shows the global default when the workout has none saved', (tester) async {
      final editor = _EditorHarness();
      await editor.pump(tester);

      expect(find.text('${_defaultBreakSeconds}s'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);
    });

    testWidgets('shows the saved value without a Default subtitle', (tester) async {
      final editor = _EditorHarness(breakSeconds: 30);
      await editor.pump(tester);

      expect(find.text('30s'), findsOneWidget);
      expect(find.text('Default'), findsNothing);
    });

    testWidgets('a picked preset is only saved on Save', (tester) async {
      final editor = _EditorHarness();
      await editor.pump(tester);

      await openBreakSheet(tester);
      await tester.tap(pill('30s'));
      await _tapSheetDone(tester);
      expect(find.text('30s'), findsOneWidget);
      expect(editor.writes, isEmpty);

      await _save(tester);
      expect(editor.savedBreak, 30);
    });

    testWidgets('the counter sets a custom value', (tester) async {
      final editor = _EditorHarness();
      await editor.pump(tester);

      await openBreakSheet(tester);
      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await _tapSheetDone(tester);
      await _save(tester);

      expect(editor.savedBreak, _defaultBreakSeconds + 5);
    });

    testWidgets('the Default pill reverts to the global default', (tester) async {
      final editor = _EditorHarness(breakSeconds: 30);
      await editor.pump(tester);

      await openBreakSheet(tester);
      await tester.tap(pill('Default'));
      await _tapSheetDone(tester);
      expect(find.text('${_defaultBreakSeconds}s'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      await _save(tester);
      expect(editor.savedBreak, isNull);
    });

    testWidgets('dismissing the sheet keeps the last picked value', (tester) async {
      final editor = _EditorHarness(breakSeconds: 30);
      await editor.pump(tester);

      await openBreakSheet(tester);
      await tester.tap(pill('15s'));
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.text('15s'), findsOneWidget);
      await _save(tester);
      expect(editor.savedBreak, 15);
    });

    testWidgets('a change counts as unsaved', (tester) async {
      final editor = _EditorHarness();
      await editor.pump(tester);

      await openBreakSheet(tester);
      await tester.tap(pill('30s'));
      await _tapSheetDone(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(editor.popPrompts, 1);
      expect(editor.writes, isEmpty);
    });

    testWidgets('Save writes exercise and break changes together once', (tester) async {
      final editor = _EditorHarness();
      await editor.pump(tester);

      await tester.drag(find.text('Plank'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      await openBreakSheet(tester);
      await tester.tap(pill('30s'));
      await _tapSheetDone(tester);
      await _save(tester);

      expect(editor.writes, hasLength(1));
      expect(editor.savedNames, ['Push-ups', 'Squats']);
      expect(editor.savedBreak, 30);
    });
  });
}

const _homeText = 'home';
const _defaultBreakSeconds = 10;

Finder _sheetField(int index) =>
    find.descendant(of: find.byType(ExerciseSheet), matching: find.byType(TextField)).at(index);

Future<void> _dragHandle(WidgetTester tester, int index, Offset by) async {
  final gesture =
      await tester.startGesture(tester.getCenter(find.byIcon(Icons.drag_handle).at(index)));
  await tester.pump();
  for (int i = 0; i < 10; i++) {
    await gesture.moveBy(by / 10);
    await tester.pump();
  }
  await gesture.up();
  await tester.pumpAndSettle();
}

Future<void> _tapSheetDone(WidgetTester tester) async {
  await tester.tap(find.text('Done'));
  await tester.pumpAndSettle();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(AppBar), matching: find.text('Save')));
  await tester.pumpAndSettle();
}

final _defaultExercises = <Exercise Function()>[
  () => DurationExercise('Plank', 60),
  () => RepExercise('Push-ups', 12),
  () => DurationExercise('Squats', 45),
];

class _EditorHarness {
  final List<Exercise> exercises;
  final int? breakSeconds;
  final bool confirmDiscard;
  final bool initiallyOpenSheet;
  final writes = <({List<Exercise> exercises, int? breakSeconds})>[];
  late final List<String> _originalValues = _values;
  int popPrompts = 0;

  _EditorHarness(
      {int? count,
      Exercise Function(int)? makeExercise,
      this.breakSeconds,
      this.confirmDiscard = false,
      this.initiallyOpenSheet = false})
      : exercises = makeExercise != null
            ? List.generate(count!, makeExercise)
            : _defaultExercises.take(count ?? _defaultExercises.length).map((f) => f()).toList();

  List<String> get _values => exercises.map((e) => e.toString()).toList();

  List<String> get savedNames => writes.single.exercises.map((e) => e.name).toList();

  int? get savedBreak => writes.single.breakSeconds;

  Future<void> pump(WidgetTester tester) async {
    // Snapshot before any interaction.
    _originalValues;
    await tester.pumpWidget(SettingsProvider(
      settings: MockSettingsService(breakDurationSeconds: _defaultBreakSeconds),
      child: localizedApp(const Scaffold(body: Text(_homeText))),
    ));
    tester.state<NavigatorState>(find.byType(Navigator)).push(MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => EditExercisesScreen(
              workoutKey: 42,
              exercises: exercises,
              breakSeconds: breakSeconds,
              updateWorkout: (key, {required exercises, required breakSeconds}) async {
                expect(key, 42);
                writes.add((exercises: exercises, breakSeconds: breakSeconds));
                return Workout('w', exercises, breakSeconds);
              },
              onPop: () async {
                popPrompts++;
                return confirmDiscard;
              },
              initiallyOpenSheet: initiallyOpenSheet,
            )));
    await tester.pumpAndSettle();
  }

  void expectOriginalsUnchanged() => expect(_values, _originalValues);
}
