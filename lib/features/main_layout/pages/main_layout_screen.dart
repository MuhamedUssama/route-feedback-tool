import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mentor_assistant/features/main_layout/cubit/navigation_cubit.dart';
import 'package:mentor_assistant/features/main_layout/cubit/navigation_state.dart';
import 'package:mentor_assistant/features/main_layout/widgets/custom_navigation_rail.dart';

import 'package:mentor_assistant/features/follow_up/presentation/pages/follow_up_screen.dart';
import 'package:mentor_assistant/features/feedback/presentation/pages/feedback_screen.dart';
import 'package:mentor_assistant/features/report/presentation/pages/report_screen.dart';
import 'package:mentor_assistant/features/settings/presentation/pages/settings_screen.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          BlocBuilder<NavigationCubit, NavigationState>(
            builder: (context, state) {
              return CustomNavigationRail(
                selectedIndex: state.selectedIndex,
                onDestinationSelected: (index) {
                  context.read<NavigationCubit>().changeIndex(index);
                },
              );
            },
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: BlocBuilder<NavigationCubit, NavigationState>(
              builder: (context, state) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.95,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(state.selectedIndex),
                    child: [
                      const FollowUpScreen(),
                      const FeedbackScreen(),
                      const ReportScreen(),
                      const SettingsScreen(),
                    ][state.selectedIndex],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
