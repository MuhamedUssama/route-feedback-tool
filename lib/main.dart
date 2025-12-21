import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/di/injection.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/theme/theme_cubit.dart';
import 'package:mentor_assistant/core/router/app_router.dart';
import 'package:mentor_assistant/core/theme/app_theme.dart';
import 'package:mentor_assistant/core/services/bloc_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await configureDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const MentorAssistant());
}

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
            initialRoute: AppRouter.loginRoute,
          );
        },
      ),
    );
  }
}
