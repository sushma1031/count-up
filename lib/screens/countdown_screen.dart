import 'package:flutter/material.dart';
import 'package:count_up/utils/assets.dart';
import 'package:count_up/widgets/scale_text_sequence.dart';
import 'package:count_up/services/audio_service.dart';

class CountdownScreen extends StatefulWidget {
  final String? message;
  final double fontSize;
  final List<String> textSequence;
  final Duration stepDuration;
  final AudioService? onCompleteAudioPlayer;
  const CountdownScreen(
      {Key? key,
      required this.textSequence,
      this.onCompleteAudioPlayer,
      this.message,
      this.fontSize = 36,
      this.stepDuration = const Duration(milliseconds: 1500)})
      : super(key: key);

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  @override
  void initState() {
    super.initState();
    widget.onCompleteAudioPlayer?.configure();
  }

  @override
  void dispose() {
    // The screen pops as soon as the sound starts, so let it finish before releasing the player.
    widget.onCompleteAudioPlayer?.disposeWhenDone();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final player = widget.onCompleteAudioPlayer;
    return Scaffold(
      backgroundColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
      body: Container(
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
                    if (player != null) {
                      await player.play();
                    }
                    if (mounted) Navigator.pop(context, true);
                  },
                ),
              ),
            ]),
      ),
    );
  }
}
