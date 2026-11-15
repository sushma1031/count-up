import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const Counter({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 10,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          iconSize: 20,
          onPressed: value > min ? () => onChanged((value - step).clamp(min, max)) : null,
        ),
        SizedBox(
          width: 45,
          child: Text(
            '${value}s',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          iconSize: 20,
          onPressed: value < max ? () => onChanged((value + step).clamp(min, max)) : null,
        ),
      ],
    );
  }
}
