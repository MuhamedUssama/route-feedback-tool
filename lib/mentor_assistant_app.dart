import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/router/app_router.dart';
import 'package:mentor_assistant/core/theme/app_theme.dart';
import 'package:mentor_assistant/core/widgets/custom_title_bar.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/theme/theme_cubit.dart';

class MentorAssistant extends StatelessWidget {
  const MentorAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Route Mentor Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: AppRouter.splashRoute,
            builder: (context, child) {
              return Column(
                children: [
                  const CustomTitleBar(),
                  Expanded(child: child!),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
