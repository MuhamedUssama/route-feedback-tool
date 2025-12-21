import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/widgets/test_theme_page.dart';
import 'package:mentor_assistant/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:mentor_assistant/features/auth/presentation/pages/login_page.dart';
import 'package:mentor_assistant/features/main_layout/cubit/navigation_cubit.dart';
import 'package:mentor_assistant/features/main_layout/pages/main_layout_screen.dart';

class AppRouter {
  static const String initialRoute = '/';
  static const String loginRoute = '/login';
  static const String mainLayoutRoute = '/main_layout';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => GetIt.I<AuthCubit>(),
            child: const LoginPage(),
          ),
        );
      case mainLayoutRoute:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => GetIt.I<NavigationCubit>(),
            child: const MainLayoutScreen(),
          ),
        );
      default:
        return MaterialPageRoute(builder: (context) => const TestThemePage());
    }
  }
}
