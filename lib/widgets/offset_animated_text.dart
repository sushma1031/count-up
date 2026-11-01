import 'package:flutter/material.dart';

class OffsetAnimatedText extends StatefulWidget {
  final String text;
  const OffsetAnimatedText(this.text, {super.key});

  @override
  State<OffsetAnimatedText> createState() => _OffsetAnimatedTextState();
}

class _OffsetAnimatedTextState extends State<OffsetAnimatedText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<Offset> _offsetAnm;
  late Animation<double> _opacityAnm;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this)
      ..forward();
    _offsetAnm = Tween<Offset>(begin: Offset(0.0, 1.2), end: Offset(0.0, 0.5))
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _opacityAnm = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnm,
      child: FadeTransition(
          opacity: _opacityAnm,
          child: Text(widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20))),
    );
  }
}
