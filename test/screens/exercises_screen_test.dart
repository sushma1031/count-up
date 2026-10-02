import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/edit_exercises_screen.dart';
import 'package:count_up/screens/edit_workout_screen.dart';
import 'package:count_up/screens/exercises_screen.dart';
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

void main() {
  late MockStorageService db;

  setUp(() => db = MockStorageService());
  tearDown(() => db.notifier.dispose());

  testWidgets('menu has Edit Exercises and no separate add entry', (tester) async {
    await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await tester.tap(find.byWidgetPredicate((w) => w is PopupMenuButton<WorkoutAction>));
    await tester.pumpAndSettle();

    expect(find.text('Edit Exercises'), findsOneWidget);
    expect(find.text('Add Exercises'), findsNothing);
  });

  testWidgets('exercises added in Edit Exercises are persisted on Save',
      (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);
    var mutations = 0;
    db.getListenable().addListener(() => mutations++);

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
    expect(mutations, 0);

    await _tapAppBarSave(tester);

    expect(mutations, isNonZero);
    final saved = db.getWorkout(workoutKey)!.exercises;
    expect(saved.map((e) => e.name), ['Plank', 'Push-ups']);
    expect((saved[1] as RepExercise).reps, 15);
    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.byType(StaticExerciseList), findsOneWidget);
    expect(find.text('15 reps'), findsOneWidget);
  });

  testWidgets('closing Edit Exercises without changes returns to the list', (tester) async {
    await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editExercise);
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.byType(EditExercisesScreen), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(StaticExerciseList), findsOneWidget);
  });

  testWidgets('renaming in Edit Workout updates the title on Save', (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editWorkout);
    expect(find.byType(EditWorkoutScreen), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Core');
    await _tapAppBarSave(tester);

    expect(db.getWorkout(workoutKey)!.name, 'Core');
    expect(find.byType(EditWorkoutScreen), findsNothing);
    expect(find.descendant(of: find.byType(AppBar), matching: find.text('Core')), findsOneWidget);
  });

  testWidgets('closing Edit Workout with changes discards them without asking', (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editWorkout);
    await tester.enterText(find.byType(TextFormField), 'Core');
    await tester.pump();
    await tester.tap(find.byType(CloseButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(EditWorkoutScreen), findsNothing);
    expect(db.getWorkout(workoutKey)!.name, 'Workout');
  });

  testWidgets('back from Edit Workout with changes asks to discard', (tester) async {
    final workoutKey = await _pumpScreen(tester, db, [DurationExercise('Plank', 60)]);

    await _openMenuItem(tester, WorkoutAction.editWorkout);
    await tester.enterText(find.byType(TextFormField), 'Core');
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(find.byType(EditWorkoutScreen), findsNothing);
    expect(db.getWorkout(workoutKey)!.name, 'Workout');
  });
}
