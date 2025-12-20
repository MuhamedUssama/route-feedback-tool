import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/features/auth/presentation/widgets/google_login_button.dart';

class LoginBody extends StatelessWidget {
  final VoidCallback onLoginPressed;
  final bool isLoading;

  const LoginBody({
    super.key,
    required this.onLoginPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
                  'Mentor Assistant',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .slideY(begin: -0.2, end: 0, duration: 600.ms)
                .shimmer(
                  delay: 1000.ms,
                  duration: 1200.ms,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                ),
            const SizedBox(height: 12),
            Text(
                  'FollowUp Hero',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                )
                .animate()
                .fadeIn(delay: 400.ms, duration: 600.ms)
                .slideY(begin: -0.1, end: 0),
            const SizedBox(height: 80),
            Text(
                  'Sign in to sync your students and sheets.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                )
                .animate()
                .fadeIn(delay: 800.ms, duration: 600.ms)
                .slideY(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child:
                  GoogleLoginButton(
                        onPressed: onLoginPressed,
                        isLoading: isLoading,
                      )
                      .animate()
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        curve: Curves.easeOutBack,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
