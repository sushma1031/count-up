import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/models/workout.dart';
import 'package:count_up/screens/exercises_screen.dart';
import 'package:count_up/utils/workout_constants.dart';
import 'package:count_up/widgets/exercises_form.dart';
import 'package:count_up/widgets/static_exercises_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_storage_service.dart';
import '../test_app.dart';

void main() {
  for (final count in [
    maxExercisesPerWorkout - 1,
    maxExercisesPerWorkout,
    maxExercisesPerWorkout + 1,
  ]) {
    testWidgets('Add Exercises respects the limit with $count exercises',
        (tester) async {
      final db = MockStorageService();
      addTearDown(db.notifier.dispose);
      final workoutKey = await db.addWorkout(Workout(
        'Workout',
        List.generate(count, (i) => Exercise('Exercise $i', 60)),
      ));
      final original = db.getWorkout(workoutKey)!.toJson();
      var mutations = 0;
      db.getListenable().addListener(() => mutations++);
      await tester.pumpWidget(localizedApp(
        ExercisesScreen(db: db, workoutKey: workoutKey),
      ));
      await tester.pumpAndSettle();
      final l10n =
          AppLocalizations.of(tester.element(find.byType(ExercisesScreen)));
      final full = count >= maxExercisesPerWorkout;

      await tester.tap(find.byWidgetPredicate(
          (widget) => widget is PopupMenuButton<WorkoutAction>));
      await tester.pumpAndSettle();
      final addItem = find.byWidgetPredicate((widget) =>
          widget is PopupMenuItem<WorkoutAction> &&
          widget.value == WorkoutAction.addExercise);
      expect(
          tester.widget<PopupMenuItem<WorkoutAction>>(addItem).enabled, isTrue);
      final opacity = tester.widget<Opacity>(find.descendant(
        of: addItem,
        matching: find.byType(Opacity),
      ));
      expect(opacity.opacity, full ? 0.38 : 1);

      await tester.tap(addItem);
      await tester.pumpAndSettle();

      if (full) {
        expect(find.byType(StaticExerciseList), findsOneWidget);
        expect(find.byType(ExercisesForm), findsNothing);
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text(l10n.errorWithMessage(
              l10n.workoutExerciseLimitError(maxExercisesPerWorkout),
            )),
          ),
          findsOneWidget,
        );
      } else {
        expect(find.byType(ExercisesForm), findsOneWidget);
        expect(find.byType(StaticExerciseList), findsNothing);
        expect(find.byType(SnackBar), findsNothing);
      }
      expect(db.size, 1);
      expect(db.getWorkout(workoutKey)!.toJson(), original);
      expect(mutations, 0);
    });
  }
}
