import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/widgets/scale_text_sequence.dart';
import 'package:count_up/services/audio_service.dart';

class Countdown extends StatefulWidget {
  final String? message;
  final double fontSize;
  final List<String> textSequence;
  final Duration stepDuration;
  final AudioService Function()? createPlayer;
  final VoidCallback onFinished;
  const Countdown(
      {super.key,
      required this.textSequence,
      required this.onFinished,
      this.createPlayer,
      this.message,
      this.fontSize = 36,
      this.stepDuration = const Duration(milliseconds: 1500)});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late final AudioService? _player = widget.createPlayer?.call();

  @override
  void initState() {
    super.initState();
    _player?.configure();
  }

  @override
  void dispose() {
    // The countdown is replaced as soon as the sound starts, so let it finish before releasing the player.
    _player?.disposeWhenDone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    return Container(
      alignment: Alignment.center,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (message != null)
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            Container(
              constraints: BoxConstraints(minHeight: 75),
              child: ScaleTextSequence(
                widget.textSequence,
                textStyle: TextStyle(
                  fontSize: widget.fontSize,
                  fontFamily: Assets.fontEthosNova,
                  fontWeight: FontWeight.bold,
                ),
                duration: widget.stepDuration,
                onFinished: () async {
                  await _player?.play();
                  if (mounted) widget.onFinished();
                },
              ),
            ),
          ]),
    );
  }
}
