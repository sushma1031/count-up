import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:count_up/state/timer_provider.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';

import '../services/mock_audio_service.dart';

void main() {
  MockAudioService mockPlayer = MockAudioService();

  Widget createWidgetUnderTest(Duration duration, {Key? key, bool isBreak = false}) {
    return MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
      body: TimerProvider(
        key: key,
        name: 'Plank',
        duration: duration,
        currentIndex: 0,
        noOfExercises: 1,
        nextExercise: (_) {},
        previousExercise: (_) {},
        player: mockPlayer,
        workoutProgress: '1/1',
        isBreak: isBreak,
      ),
    ));
  }

  testWidgets('initial state of timer is correct', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('timer counts down correctly', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));
    await tester.pump(Duration(seconds: 1));
    expect(find.text('4'), findsOneWidget);
    await tester.pump(Duration(seconds: 4));
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('pause and resume timer', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));

    // Pause the timer
    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    await tester.pump(Duration(seconds: 2));
    expect(find.text('5'), findsOneWidget); // Timer should be paused

    // Resume the timer
    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();
    await tester.pump(Duration(seconds: 2));
    expect(find.text('3'), findsOneWidget); // Timer should resume
  });

  testWidgets('play sound at 3 seconds remaining', (WidgetTester tester) async {
    final GlobalKey<State<TimerProvider>> timerProviderKey =
        GlobalKey(); // create unique key to identify widget
    Widget testWidget =
        createWidgetUnderTest(Duration(seconds: 5), key: timerProviderKey);
    await tester.pumpWidget(testWidget);
    await tester.pump(Duration(seconds: 1));
    expect(
        mockPlayer.status, AudioStatus.stopped); // Ensure no sound played yet
    await tester.pump(Duration(seconds: 1));
    expect(mockPlayer.status, AudioStatus.playing); // Ensure sound played
  });

  testWidgets('previous tooltip switches to restart after 3s', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 10)));
    expect(find.byTooltip('Previous'), findsOneWidget);

    await tester.pump(Duration(seconds: 3));
    expect(find.byTooltip('Previous'), findsOneWidget);

    await tester.pump(Duration(seconds: 1));
    expect(find.byTooltip('Restart'), findsOneWidget);
  });

  testWidgets('break previous tooltip never says restart', (tester) async {
    await tester.pumpWidget(
        createWidgetUnderTest(Duration(seconds: 10), isBreak: true));
    await tester.pump(Duration(seconds: 5));
    expect(find.byTooltip('Previous'), findsOneWidget);
    expect(find.byTooltip('Restart'), findsNothing);
  });

  testWidgets('pause tooltip reflects state', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest(Duration(seconds: 5)));
    expect(find.byTooltip('Pause'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.pause));
    await tester.pump();
    expect(find.byTooltip('Resume'), findsOneWidget);
  });
}
