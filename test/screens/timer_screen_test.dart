import 'package:count_up/models/exercise.dart';
import 'package:count_up/screens/timer_screen.dart';
import 'package:count_up/state/settings_provider.dart';
import 'package:count_up/state/workout_provider.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_audio_service.dart';
import '../services/mock_settings_service.dart';

void main() {
  final exercises = [DurationExercise('Plank', 6), DurationExercise('Crunches', 5)];

  Widget buildScreen(MockAudioService player, double timerVolume) {
    return SettingsProvider(
      settings: MockSettingsService(timerVolume: timerVolume),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerScreen(e: exercises, player: player),
      ),
    );
  }

  testWidgets('reads the volume from settings and applies to audio player',
      (tester) async {
    final player = MockAudioService();
    await tester.pumpWidget(buildScreen(player, 0.5));
    await tester.pump();

    final provider =
        tester.widget<WorkoutProvider>(find.byType(WorkoutProvider));
    expect(provider.timerVolume, 0.5);
    expect(player.configured, true);
    expect(player.volume, 0.5);
  });

  testWidgets('fails when no SettingsProvider is in the tree', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TimerScreen(e: exercises, player: MockAudioService()),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('renders the first exercise', (tester) async {
    await tester.pumpWidget(buildScreen(MockAudioService(), 0.5));
    await tester.pump();

    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
