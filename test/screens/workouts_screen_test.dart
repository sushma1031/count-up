import 'package:count_up/screens/exercises_screen.dart';
import 'package:count_up/screens/workouts_screen.dart';
import 'package:count_up/state/settings_provider.dart';
import 'package:count_up/widgets/volume_slider.dart';
import 'package:count_up/widgets/counter.dart';
import 'package:count_up/widgets/danger_confirm_dialog.dart';
import 'package:count_up/widgets/settings_dialog.dart';
import 'package:count_up/widgets/workout_card.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:count_up/app.dart';

import '../services/mock_settings_service.dart';
import '../services/mock_storage_service.dart';

void main() {
  late MockStorageService mockDB;
  late MockSettingsService mockSettings;
  late Widget screen;

  setUp(() {
    mockDB = MockStorageService();
    mockDB.loadData();
    mockSettings = MockSettingsService();
    screen = SettingsProvider(
      settings: mockSettings,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WorkoutsScreen(db: mockDB),
      ),
    );
  });
  tearDown(() => mockDB.notifier.dispose());

  group('Workouts Screen loads correctly', () {
    testWidgets('display loading screen', (tester) async {
      await tester.pumpWidget(CountUpApp(db: mockDB, settings: mockSettings));
      expect(find.text('COUNT UP'), findsOneWidget);
      await tester.pump(Duration(seconds: 3));
    });

    testWidgets('display workouts', (tester) async {
      await tester.pumpWidget(screen);
      expect(find.text('COUNT UP'), findsNothing);
      expect(find.text('Abs'), findsOneWidget);
      expect(find.text('Thighs'), findsOneWidget);

      expect(find.byType(WorkoutCard), findsNWidgets(2));
    });
  });

  testWidgets('adding a workout stores it and opens it', (tester) async {
    await tester.pumpWidget(screen);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Biceps');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(mockDB.getAllWorkoutNames(), contains('Biceps'));
    expect(find.byType(ExercisesScreen), findsOneWidget);
    expect(find.text('Biceps'), findsOneWidget);
  });

  testWidgets('add rejects an existing workout name', (tester) async {
    await tester.pumpWidget(screen);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Abs');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();

    expect(find.text('Name already in use'), findsOneWidget);
    expect(mockDB.writes, 0);
  });

  testWidgets('clears workouts correctly', (tester) async {
    await tester.pumpWidget(screen);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete All'));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(
        of: find.byType(DangerConfirmDialog), matching: find.text('Delete All')));
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutCard), findsNothing);
  });

  testWidgets('updates sound volume from settings', (tester) async {
    await tester.pumpWidget(screen);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(VolumeSlider), findsOneWidget);

    await tester.drag(find.byType(Slider).first, const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(mockSettings.soundVolume, 1.0);
  });

  testWidgets('updates pre-workout countdown from settings', (tester) async {
    await tester.pumpWidget(screen);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsDialog), findsOneWidget);
    expect(find.text('Pre-workout countdown'), findsOneWidget);
    expect(find.byType(Counter), findsNWidgets(2));
    expect(find.text('5s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline).first);
    await tester.pump();

    expect(mockSettings.preWorkoutCountdownSeconds, 6);
    expect(find.text('6s'), findsOneWidget);
  });

  testWidgets('updates break duration from settings in steps of 5', (tester) async {
    await tester.pumpWidget(screen);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Break between exercises'), findsOneWidget);
    expect(find.text('0s'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle_outline).last);
    await tester.pump();

    expect(mockSettings.breakDurationSeconds, 5);
    expect(find.text('5s'), findsNWidgets(2));
  });
}
