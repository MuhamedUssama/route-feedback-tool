import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/theme/theme_cubit.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, currentMode) {
        return Row(
              children: [
                Expanded(
                  child: ThemeOption(
                    icon: Icons.light_mode,
                    label: 'Light',
                    isSelected: currentMode == ThemeMode.light,
                    onTap: () =>
                        context.read<ThemeCubit>().updateTheme(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ThemeOption(
                    icon: Icons.dark_mode,
                    label: 'Dark',
                    isSelected: currentMode == ThemeMode.dark,
                    onTap: () =>
                        context.read<ThemeCubit>().updateTheme(ThemeMode.dark),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ThemeOption(
                    icon: Icons.settings_brightness,
                    label: 'System',
                    isSelected: currentMode == ThemeMode.system,
                    onTap: () => context.read<ThemeCubit>().updateTheme(
                      ThemeMode.system,
                    ),
                  ),
                ),
              ],
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 600.ms)
            .slideY(begin: 0.2, end: 0);
      },
    );
  }
}

class ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeOption({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: 300.ms,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: .3),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: .4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                    icon,
                    color: isSelected ? Colors.white : colorScheme.onSurface,
                    size: 32,
                  )
                  .animate(target: isSelected ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
