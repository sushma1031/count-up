import 'package:count_up/screens/countdown_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_audio_service.dart';

void main() {
  testWidgets('configures the player on open, plays at the end, and releases it after popping',
      (tester) async {
    final player = MockAudioService();
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    tester.state<NavigatorState>(find.byType(Navigator)).push(MaterialPageRoute<bool>(
          builder: (_) => CountdownScreen(
            textSequence: const ['1'],
            stepDuration: const Duration(milliseconds: 100),
            onCompleteAudioPlayer: player,
          ),
        ));
    await tester.pump();

    expect(player.configured, true);
    expect(player.status, AudioStatus.stopped);
    expect(player.disposed, false);

    await tester.pumpAndSettle();

    expect(find.byType(CountdownScreen), findsNothing);
    expect(player.status, AudioStatus.playing);
    expect(player.disposed, true);
  });
}
