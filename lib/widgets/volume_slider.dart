import 'package:flutter/material.dart';

class VolumeSlider extends StatefulWidget {
  final double initial;
  final double min;
  final double max;
  final double step;
  final void Function(double) onChanged;

  const VolumeSlider(
      {super.key,
      this.initial = 0.5,
      this.min = 0.0,
      this.max = 1.0,
      this.step = 0.1,
      required this.onChanged})
      : assert(step > 0),
        assert(max > min);

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  late double _currentSliderValue;

  @override
  void initState() {
    super.initState();
    _currentSliderValue = widget.initial.clamp(widget.min, widget.max);
  }

  @override
  Widget build(BuildContext context) {
    final divisions = ((widget.max - widget.min) / widget.step).round();

    return Row(
      children: [
        Expanded(
          child: Slider(
            value: _currentSliderValue,
            min: widget.min,
            max: widget.max,
            divisions: divisions,
            padding: const EdgeInsetsDirectional.only(top: 14, bottom: 14, end: 10),
            onChanged: (double value) {
              setState(() {
                _currentSliderValue = value;
              });
            },
            onChangeEnd: widget.onChanged,
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '${(_currentSliderValue * 100).round()}%',
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
