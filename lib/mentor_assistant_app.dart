import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/router/app_router.dart';
import 'package:mentor_assistant/core/theme/app_theme.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/theme/theme_cubit.dart';
import 'package:flutter/services.dart';

import 'dart:io';

class MentorAssistant extends StatelessWidget {
  const MentorAssistant({super.key});

  static const platform = MethodChannel('com.mentor_assistant/native_theme');

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ThemeCubit>(),
      child: BlocListener<ThemeCubit, ThemeMode>(
        listener: (context, mode) => _syncNativeTheme(mode),
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _syncNativeTheme(themeMode);
            });
            return MaterialApp(
              title: 'Mentor Assistant',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              onGenerateRoute: AppRouter.onGenerateRoute,
              initialRoute: AppRouter.splashRoute,
            );
          },
        ),
      ),
    );
  }

  Future<void> _syncNativeTheme(ThemeMode mode) async {
    final isDark = mode == ThemeMode.dark;
    final color = isDark ? const Color(0xFF1b1d1e) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : Colors.black;

    try {
      if (Platform.isWindows || Platform.isMacOS) {
        await platform.invokeMethod('updateTitleBarColor', {
          'backgroundColor': color.toARGB32(),
          'textColor': textColor.toARGB32(),
        });
      }
    } on PlatformException catch (e) {
      log("Failed to update native title bar color: '${e.message}'.");
    }
  }
}
