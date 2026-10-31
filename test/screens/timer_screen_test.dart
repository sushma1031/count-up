import 'package:count_up/models/exercise.dart';
import 'package:count_up/screens/timer_screen.dart';
import 'package:count_up/gen/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_audio_service.dart';

void main() {
  final exercises = [DurationExercise('Plank', 6), DurationExercise('Crunches', 5)];

  Widget buildScreen(MockAudioService player) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: TimerScreen(e: exercises, player: player),
    );
  }

  testWidgets('configures the audio player without overriding its volume', (tester) async {
    final player = MockAudioService();
    await tester.pumpWidget(buildScreen(player));
    await tester.pump();

    expect(player.configured, true);
    expect(player.volume, isNull);
  });

  testWidgets('renders the first exercise', (tester) async {
    await tester.pumpWidget(buildScreen(MockAudioService()));
    await tester.pump();

    expect(find.text('Plank'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });
}
