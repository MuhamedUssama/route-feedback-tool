import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:mentor_assistant/core/di/injection.dart';
import 'package:mentor_assistant/core/services/bloc_observer.dart';
import 'package:mentor_assistant/features/settings/data/models/cycle_config_model.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/mentor_assistant_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Hive.initFlutter();
  Hive.registerAdapter(GroupConfigModelAdapter());
  Hive.registerAdapter(CycleConfigModelAdapter());

  await configureDependencies();
  Bloc.observer = MyBlocObserver();
  runApp(const MentorAssistant());
}
