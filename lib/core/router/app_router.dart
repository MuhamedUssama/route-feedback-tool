import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/widgets/test_theme_page.dart';
import 'package:mentor_assistant/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mentor_assistant/features/auth/presentation/pages/login_page.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => GetIt.I<AuthCubit>(),
            child: const LoginPage(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (context) => const TestThemePage());
    }
  }
}
