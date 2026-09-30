import 'package:flutter/material.dart';
import 'package:count_up/models/exercise.dart';
import 'package:count_up/state/workout_provider.dart';
import 'package:count_up/widgets/workout_complete.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_audio_service.dart';

void main() {
  final exercises = [DurationExercise('Plank', 6), DurationExercise('Crunches', 5)];
  MockAudioService mockPlayer = MockAudioService();
  final Widget testWidget = MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
          body: WorkoutProvider(exercises: exercises, player: mockPlayer)));
  testWidgets('initial exercise and timer duration',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('progress to next exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    // advance by duration of first exercise
    await tester.pump(Duration(seconds: 7));
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Crunches'), findsOneWidget);
  });

  testWidgets('navigate to next exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Crunches'), findsOneWidget);
  });

  testWidgets('navigate manually to previous exercise',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 7)); //progress to next exercise

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('restart exercise', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 3));

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pump();
    expect(find.text('6'), findsOneWidget);
    expect(find.text('Plank'), findsOneWidget);
  });

  testWidgets('complete workout and show completion screen',
      (WidgetTester tester) async {
    final Widget testWidget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: WorkoutProvider(
                exercises: [DurationExercise('Plank', 2)], player: mockPlayer)));
    // Short duration for quick test
    await tester.pumpWidget(testWidget);

    await tester.pump(Duration(seconds: 3));
    await tester.pump();
    expect(find.byType(WorkoutComplete), findsOneWidget);
  });

  testWidgets('disable next button for last exercise',
      (WidgetTester tester) async {
    await tester.pumpWidget(testWidget);
    final nextIconBtn = find.widgetWithIcon(IconButton, Icons.skip_next);
    expect(tester.widget<IconButton>(nextIconBtn).onPressed == null, false);

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pump();

    expect(tester.widget<IconButton>(nextIconBtn).onPressed, null);
  });

  testWidgets('mixed workout transitions from timed to rep exercise',
      (WidgetTester tester) async {
    final mixedExercises = [
      DurationExercise('Plank', 3),
      RepExercise('Push ups', 12),
    ];
    final Widget mixedTestWidget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: WorkoutProvider(
                exercises: mixedExercises, player: mockPlayer)));

    await tester.pumpWidget(mixedTestWidget);
    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    await tester.pump(Duration(seconds: 4));

    expect(find.text('Push ups'), findsOneWidget);
    expect(find.text('12 REPS', findRichText: true), findsOneWidget);
  });

  testWidgets('rep exercise never auto-advances over time',
      (WidgetTester tester) async {
    final repExercises = [
      RepExercise('Push ups', 12),
      DurationExercise('Plank', 5),
    ];
    final Widget repTestWidget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: WorkoutProvider(
                exercises: repExercises, player: mockPlayer)));

    await tester.pumpWidget(repTestWidget);
    expect(find.text('Push ups'), findsOneWidget);

    await tester.pump(Duration(seconds: 30));

    expect(find.text('Push ups'), findsOneWidget);
    expect(find.text('12 REPS', findRichText: true), findsOneWidget);
  });

  testWidgets('tapping done on last rep exercise completes workout',
      (WidgetTester tester) async {
    final Widget repTestWidget = MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
            body: WorkoutProvider(
                exercises: [RepExercise('Push ups', 12)],
                player: mockPlayer)));

    await tester.pumpWidget(repTestWidget);

    await tester.tap(find.byIcon(Icons.check));
    await tester.pump();

    expect(find.byType(WorkoutComplete), findsOneWidget);
  });
}
