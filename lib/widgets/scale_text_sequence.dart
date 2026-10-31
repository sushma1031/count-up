import 'package:count_up/widgets/scale_animated_text.dart';
import 'package:flutter/material.dart';

class ScaleTextSequence extends StatefulWidget {
  final List<String> texts;
  final TextStyle? textStyle;
  final Duration duration;
  final VoidCallback? onFinished;
  const ScaleTextSequence(this.texts,
      {super.key,
      this.duration = const Duration(milliseconds: 1000),
      this.onFinished,
      this.textStyle});

  @override
  State<ScaleTextSequence> createState() => _ScaleTextSequenceState();
}

class _ScaleTextSequenceState extends State<ScaleTextSequence> {
  int _currentIndex = 0;
  int _lastIndex = 0;

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.texts.length - 1;
  }

  void goNext() {
    setState(() {
      if (_currentIndex == _lastIndex)
        widget.onFinished?.call();
      else
        _currentIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaleAnimatedText(
      widget.texts[_currentIndex],
      duration: widget.duration,
      goNext: goNext,
      textStyle: widget.textStyle,
    );
  }
}
