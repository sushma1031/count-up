import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/screens/exercises_screen.dart';
import 'package:count_up/widgets/workout_name_form.dart';
import 'package:count_up/widgets/exercise_sheet.dart';
import 'package:count_up/widgets/static_exercises_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_storage_service.dart';
import '../test_app.dart';

Future<int> _pumpScreen(WidgetTester tester, MockStorageService db, List<Exercise> exercises) async {
  final workoutKey = await db.addWorkout(Workout('Workout', exercises));
  await tester.pumpWidget(localizedApp(ExercisesScreen(db: db, workoutKey: workoutKey)));
  await tester.pumpAndSettle();
  return workoutKey;
}

Future<void> _openMenuItem(WidgetTester tester, WorkoutAction action) async {
  await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton<WorkoutAction>));
  await tester.pumpAndSettle();
  await tester.tap(find.byWidgetPredicate(
      (w) => w is PopupMenuItem<WorkoutAction> && w.value == action));
  await tester.pumpAndSettle();
}

Future<void> _tapAppBarSave(WidgetTester tester) async {
  await tester.tap(find.descendant(of: find.byType(AppBar), matching: find.text('Save')));
  await tester.pumpAndSettle();
}

Future<void> _openRename(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Rename workout'));
  await tester.pumpAndSettle();
}

Future<void> _renameTo(WidgetTester tester, String name) async {
  await _openRename(tester);
  await tester.enterText(find.byType(TextFormField), name);
  await tester.tap(
      find.descendant(of: find.byType(WorkoutNameForm), matching: find.text('Save')));
  await tester.pumpAndSettle();
}

void main() {
  late MockStorageService db;

  setUp(() => db = MockStorageService());
  tearDown(() => db.notifier.dispose());


  testWidgets('exercises added in Edit Exercises are persisted on Save',
      (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editExercise);
    expect(find.byType(EditExercisesScreen), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reps'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Push-ups');
    await tester.enterText(fields.at(1), '15');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    await _tapAppBarSave(tester);

    final saved = db.getWorkout(workoutKey)!.exercises;
    expect(saved.map((e) => e.name), ['Plank', 'Push-ups']);
    expect((saved[1] as RepExercise).reps, 15);
    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.byType(StaticExerciseList), findsOneWidget);
    expect(find.text('15 reps'), findsOneWidget);
  });

  testWidgets('empty workout offers Add Exercises, which opens Edit Exercises with the add sheet',
      (tester) async {
    await _pumpScreen(tester, db, []);

    expect(find.byTooltip('Start workout'), findsNothing);
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Add Exercises'));
    await tester.pumpAndSettle();

    expect(find.byType(EditExercisesScreen), findsOneWidget);
    expect(find.byType(ExerciseSheet), findsOneWidget);
  });

  testWidgets('workout with exercises offers a Start workout FAB', (tester) async {
    await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    final fab = find.byType(FloatingActionButton);
    expect(find.descendant(of: fab, matching: find.byIcon(Icons.play_arrow)), findsOneWidget);
    expect(find.byTooltip('Start workout'), findsOneWidget);
    expect(find.text('Add Exercises'), findsNothing);
  });

  testWidgets('closing Edit Exercises without changes returns to the list', (tester) async {
    await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editExercise);
    expect(find.byType(ExerciseSheet), findsNothing);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(StaticExerciseList), findsOneWidget);
  });

  testWidgets('renaming updates storage and the title', (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _renameTo(tester, 'Core');

    expect(db.getWorkout(workoutKey)!.name, 'Core');
    expect(find.byType(WorkoutNameForm), findsNothing);
    expect(find.text('Core'), findsOneWidget);
  });

  testWidgets('rename rejects a name used by another workout', (tester) async {
    await db.addWorkout(Workout('Legs', []));
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _renameTo(tester, 'Legs');

    expect(find.text('Name already in use'), findsOneWidget);
    expect(find.byType(WorkoutNameForm), findsOneWidget);
    expect(db.getWorkout(workoutKey)!.name, 'Workout');
  });


  testWidgets('dismissing the rename dialog preserves original name', (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openRename(tester);
    await tester.enterText(find.byType(TextFormField), 'Core');
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(WorkoutNameForm), findsNothing);
    expect(db.getWorkout(workoutKey)!.name, 'Workout');
  });
}
