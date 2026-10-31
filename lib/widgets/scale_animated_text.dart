import 'package:flutter/material.dart';

class ScaleAnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration duration;
  final VoidCallback? goNext;
  const ScaleAnimatedText(this.text,
      {super.key, required this.duration, this.goNext, this.textStyle});

  @override
  State<ScaleAnimatedText> createState() => _ScaleAnimatedTextState();
}

class _ScaleAnimatedTextState extends State<ScaleAnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _scaleIn, _scaleOut, _fadeIn, _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this)
      ..forward();
    var curvedIn = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeIn));
    var curvedOut = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.easeOut));
    _scaleIn = Tween<double>(begin: 0.5, end: 1).animate(curvedIn);
    _scaleOut = Tween<double>(begin: 1, end: 0.5).animate(curvedOut);
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(curvedIn);
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(curvedOut);

    _controller.addListener(() {
      setState(() {});
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.goNext?.call();
      }
    });
  }

  @override
  void didUpdateWidget(old) {
    super.didUpdateWidget(old);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = widget.textStyle != null
        ? widget.textStyle
        : TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          );
    return ScaleTransition(
      scale: _scaleIn.value != 1 ? _scaleIn : _scaleOut,
      child: Opacity(
          opacity: _fadeIn.value != 1 ? _fadeIn.value : _fadeOut.value,
          child: Text(widget.text, style: textStyle)),
    );
  }
}
