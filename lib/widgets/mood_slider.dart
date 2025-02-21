import 'package:flutter/material.dart';

class MoodSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: value,
          onChanged: onChanged,
          min: 0,
          max: 100,
          divisions: 100,
          label: '${value.round()}%',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Pésimo'),
              Text('Normal'),
              Text('¡Excelente!'),
            ],
          ),
        ),
      ],
    );
  }
}

