import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/router/app_router.dart';
import 'package:mentor_assistant/core/theme/app_theme.dart';
import 'package:mentor_assistant/core/di/injection.dart';
import 'package:mentor_assistant/core/usecases/usecase.dart';
import 'package:mentor_assistant/features/auth/domain/usecases/check_auto_login_usecase.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/theme/theme_cubit.dart';

class MentorAssistant extends StatelessWidget {
  final String initialRoute;

  const MentorAssistant({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Mentor Assistant',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            onGenerateRoute: AppRouter.onGenerateRoute,
            initialRoute: initialRoute,
          );
        },
      ),
    );
  }
}

Future<String> getInitialRoute() async {
  final checkAutoLogin = getIt<CheckAutoLoginUseCase>();
  final result = await checkAutoLogin(const NoParams());
  return result.fold(
    (_) => AppRouter.loginRoute,
    (_) => AppRouter.mainLayoutRoute,
  );
}
