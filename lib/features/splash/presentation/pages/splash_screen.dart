import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/core/router/app_router.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/splash_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SplashCubit>().initializeApp();
  }

  void _handleNavigation(SplashState state) {
    state.whenOrNull(
      authenticated: (user) {
        Navigator.of(context).pushReplacementNamed(AppRouter.mainLayoutRoute);
      },
      unauthenticated: () {
        Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
      },
      error: (message) {
        Navigator.of(context).pushReplacementNamed(AppRouter.loginRoute);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        _handleNavigation(state);
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: BlocBuilder<SplashCubit, SplashState>(
          builder: (context, state) {
            final String message = state.maybeWhen(
              loading: (msg, _) => msg,
              orElse: () => 'Initializing System...',
            );
            final double progress = state.maybeWhen(
              loading: (_, prog) => prog,
              orElse: () => 0.0,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(color: colorScheme.surface),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                            Icons.rocket_launch_rounded,
                            size: 240,
                            color: primaryColor,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            curve: Curves.easeOutBack,
                            duration: 800.ms,
                          )
                          .shimmer(
                            delay: 2000.ms,
                            duration: 1500.ms,
                            color: colorScheme.secondary.withValues(alpha: 0.5),
                          )
                          .then()
                          .moveY(
                            begin: 0,
                            end: -10,
                            duration: 2000.ms,
                            curve: Curves.easeInOut,
                          )
                          .then()
                          .moveY(begin: -10, end: 0, duration: 2000.ms),
                      const SizedBox(height: 24),
                      Text(
                            'Route Mentor Assistant',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.2,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                      const SizedBox(height: 30),
                      Text(
                            'Automated Mentoring Tool',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.outline,
                              letterSpacing: 1.2,
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ).animate().fadeIn(duration: 600.ms),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          color: colorScheme.primary,
                          minHeight: 2,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
