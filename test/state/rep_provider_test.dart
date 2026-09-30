import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:count_up/state/rep_provider.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

void main() {
  Widget createWidgetUnderTest({
    int reps = 12,
    int currentIndex = 0,
    int noOfExercises = 1,
    ValueChanged<void>? nextExercise,
    ValueChanged<void>? previousExercise,
    String? nextName,
  }) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: RepProvider(
            name: 'Push ups',
            reps: reps,
            currentIndex: currentIndex,
            noOfExercises: noOfExercises,
            nextExercise: nextExercise ?? (_) {},
            previousExercise: previousExercise ?? (_) {},
            workoutProgress: '1/1',
            nextName: nextName,
          ),
        ));
  }

  testWidgets('shows exercise name and rep count', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(reps: 12));
    expect(find.text('Push ups'), findsOneWidget);
    expect(find.text('12 REPS', findRichText: true), findsOneWidget);
  });

  testWidgets('does not auto-advance over time', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(reps: 12));
    await tester.pump(Duration(seconds: 10));
    expect(find.text('Push ups'), findsOneWidget);
    expect(find.text('12 REPS', findRichText: true), findsOneWidget);
  });

  testWidgets('done button calls nextExercise', (WidgetTester tester) async {
    bool nextCalled = false;
    await tester.pumpWidget(createWidgetUnderTest(
      nextExercise: (_) => nextCalled = true,
    ));

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(nextCalled, true);
  });

  testWidgets('previous button calls previousExercise',
      (WidgetTester tester) async {
    bool previousCalled = false;
    await tester.pumpWidget(createWidgetUnderTest(
      previousExercise: (_) => previousCalled = true,
    ));

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();

    expect(previousCalled, true);
  });

  testWidgets('next button calls nextExercise', (WidgetTester tester) async {
    bool nextCalled = false;
    await tester.pumpWidget(createWidgetUnderTest(
      currentIndex: 0,
      noOfExercises: 1,
      nextExercise: (_) => nextCalled = true,
    ));

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();

    expect(nextCalled, true);
  });

  testWidgets('disables next button on last exercise',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(
      currentIndex: 1,
      noOfExercises: 1,
    ));

    final nextIconBtn = find.widgetWithIcon(IconButton, Icons.skip_next);
    expect(tester.widget<IconButton>(nextIconBtn).onPressed, null);
  });

  testWidgets('shows exit confirmation dialog on back navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Workout Incomplete!'), findsOneWidget);
  });
}
