import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ConfigSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const ConfigSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
        .slideX(
          begin: -0.05,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuad,
        );
  }
}
