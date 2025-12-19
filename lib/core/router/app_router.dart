import 'package:flutter/material.dart';
import 'package:mentor_assistant/core/widgets/test_theme_page.dart';

class AppRouter {
  static const String initialRoute = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return MaterialPageRoute(builder: (context) => const TestThemePage());
    }
  }
}
