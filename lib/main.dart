import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mentor_assistant/core/di/injection.dart';
import 'package:mentor_assistant/core/services/bloc_observer.dart';
import 'package:mentor_assistant/features/settings/data/models/cycle_config_model.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/mentor_assistant_app.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions options = const WindowOptions(
    minimumSize: Size(1200, 800),
    size: Size(1200, 800),
    center: true,
    title: "Route Mentor Assistant",
    backgroundColor: Color(0xFF1b1d1e),
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(GroupConfigModelAdapter());
  Hive.registerAdapter(CycleConfigModelAdapter());

  await configureDependencies();
  Bloc.observer = MyBlocObserver();

  if (kReleaseMode) {
    await SentryFlutter.init((options) {
      options.dsn = dotenv.env['SENTRY_DSN'] ?? '';
      options.tracesSampleRate = 1.0;
      options.enablePrintBreadcrumbs = true;
    }, appRunner: () => runApp(const MentorAssistant()));
  } else {
    runApp(const MentorAssistant());
  }
}
