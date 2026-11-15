import 'package:count_up/widgets/countdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../services/mock_audio_service.dart';

void main() {
  Widget buildCountdown(MockAudioService player, VoidCallback onFinished) {
    return MaterialApp(
      home: Scaffold(
        body: Countdown(
          textSequence: const ['1'],
          stepDuration: const Duration(milliseconds: 100),
          createPlayer: () => player,
          onFinished: onFinished,
        ),
      ),
    );
  }

  testWidgets('configures the player on mount and plays it when finished', (tester) async {
    final player = MockAudioService();
    var finished = 0;
    await tester.pumpWidget(buildCountdown(player, () => finished++));

    expect(player.configured, true);
    expect(player.status, AudioStatus.stopped);
    expect(player.disposed, false);
    expect(finished, 0);

    await tester.pumpAndSettle();

    expect(player.status, AudioStatus.playing);
    expect(player.disposed, false);
    expect(finished, 1);
  });

  testWidgets('releases the player when removed from the tree', (tester) async {
    final player = MockAudioService();
    await tester.pumpWidget(buildCountdown(player, () {}));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const MaterialApp(home: Scaffold()));

    expect(player.disposed, true);
  });
}
