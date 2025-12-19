import 'package:flutter/material.dart';
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Mentor Assistant',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'FollowUp Hero',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Text(
                'Sign in to sync your students and sheets.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GoogleLoginButton(
                onPressed: onLoginPressed,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
