import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentor_assistant/features/main_layout/cubit/navigation_cubit.dart';

class ReportEmptyStateWidget extends StatelessWidget {
  const ReportEmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings_suggest, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Cycle not configured yet.',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Please go to Settings to configure your groups.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NavigationCubit>().changeIndex(3);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(MediaQuery.sizeOf(context).width * 0.36, 60),
            ),
            child: const Text('Go to Settings'),
          ).animate().fadeIn(),
        ],
      ).animate().fadeIn().slideY(begin: 0.1, end: 0),
    );
  }
}
