import 'package:flutter/material.dart';

class ReportStatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const ReportStatChip({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }
}
