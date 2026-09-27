import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/utils/errors.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/exercise_form_field.dart';
import 'package:count_up/widgets/exercises_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_app.dart';

void main() {
  testWidgets('exercise numbering starts at 1 for an empty workout',
      (tester) async {
    await tester.pumpWidget(localizedApp(ExercisesForm(
      workoutKey: 7,
      currentExerciseCount: 0,
      addWorkoutExercises: (_, __) async {},
      returnToStaticList: () {},
      onPop: () async => true,
    )));

    expect(find.byType(ExerciseFormField), findsOneWidget);
    expect(find.text('1.'), findsOneWidget);
  });

  testWidgets('exercise numbering continues and updates when rows change',
      (tester) async {
    final count = maxExercisesPerWorkout - 2;
    await tester.pumpWidget(localizedApp(ExercisesForm(
      workoutKey: 7,
      currentExerciseCount: count,
      addWorkoutExercises: (_, __) async {},
      returnToStaticList: () {},
      onPop: () async => true,
    )));

    expect(find.text('${count + 1}.'), findsOneWidget);
    expect(find.text('1.'), findsNothing);

    await _fillRow(tester, 0);
    await tester.tap(find.byIcon(Icons.add_box));
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseFormField), findsNWidgets(2));
    expect(find.text('${count + 1}.'), findsOneWidget);
    expect(find.text('${count + 2}.'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove_circle).first);
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseFormField), findsOneWidget);
    expect(find.text('${count + 1}.'), findsOneWidget);
    expect(find.text('${count + 2}.'), findsNothing);
  });

  testWidgets('cannot add exercises to a workout with ${maxExercisesPerWorkout} exercises', (tester) async {
    var writes = 0;
    await tester.pumpWidget(localizedApp(ExercisesForm(
      workoutKey: 7,
      currentExerciseCount: maxExercisesPerWorkout,
      addWorkoutExercises: (_, __) async => writes++,
      returnToStaticList: () => fail('Must not leave the form'),
      onPop: () async => true,
    )));
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseFormField), findsNothing);
    expect(find.byIcon(Icons.add_box), findsNothing);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);
    expect(find.byType(SnackBar), findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(find.byType(ExercisesForm)));
    expect(
      find.descendant(
        of: find.byType(SnackBar),
        matching: find.text(l10n.workoutExerciseLimitError(maxExercisesPerWorkout)),
      ),
      findsOneWidget,
    );
    expect(writes, 0);
  });

  testWidgets('one remaining slot allows adding only one more', (tester) async {
    List<Exercise>? saved;
    var returned = false;
    await tester.pumpWidget(localizedApp(ExercisesForm(
      workoutKey: 7,
      currentExerciseCount: maxExercisesPerWorkout - 1,
      addWorkoutExercises: (key, exercises) async {
        expect(key, 7);
        saved = exercises;
      },
      returnToStaticList: () => returned = true,
      onPop: () async => true,
    )));
    await _fillRow(tester, 0);
    await tester.tap(find.byIcon(Icons.add_box));
    await tester.pumpAndSettle();

    expect(find.byType(ExerciseFormField), findsOneWidget);
    expect(find.byType(SnackBar), findsOne);
    final context = tester.element(find.byType(ExercisesForm));
    expect(importErrorMessage(context, ImportError.exerciseLimit),
        AppLocalizations.of(context).workoutExerciseLimitError(maxExercisesPerWorkout));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(saved, hasLength(1));
    expect(saved!.single.name, 'Exercise 0');
    expect(saved!.single.duration, 60);
    expect(returned, isTrue);
  });

  testWidgets('save re-checks the existing count before persisting', (tester) async {
    var count = maxExercisesPerWorkout - 1;
    var writes = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(localizedApp(StatefulBuilder(
      builder: (context, setState) {
        rebuild = setState;
        return ExercisesForm(
          workoutKey: 7,
          currentExerciseCount: count,
          addWorkoutExercises: (_, __) async => writes++,
          returnToStaticList: () => fail('Must not leave the form'),
          onPop: () async => true,
        );
      },
    )));
    await _fillRow(tester, 0);
    rebuild(() => count = maxExercisesPerWorkout);
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(writes, 0);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}

Future<void> _fillRow(WidgetTester tester, int index) async {
  final fields = find.descendant(
    of: find.byType(ExerciseFormField).at(index),
    matching: find.byType(TextField),
  );
  await tester.enterText(fields.at(0), 'Exercise $index');
  await tester.enterText(fields.at(1), '60');
}
