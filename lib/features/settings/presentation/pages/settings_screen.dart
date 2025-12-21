import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/settings/presentation/cubits/settings/settings_cubit.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/settings_footer.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/sheet_config_section.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/theme_selector.dart';
import 'package:mentor_assistant/features/settings/presentation/widgets/user_profile_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<SettingsCubit>()..loadSettings(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  final _assignmentController = TextEditingController();
  final _followUpController = TextEditingController();

  @override
  void dispose() {
    _assignmentController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  void _updateControllers(String? assignmentUrl, String? followUpUrl) {
    if (assignmentUrl != null && _assignmentController.text != assignmentUrl) {
      _assignmentController.text = assignmentUrl;
    }
    if (followUpUrl != null && _followUpController.text != followUpUrl) {
      _followUpController.text = followUpUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        state.maybeWhen(
          success: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                margin: const EdgeInsets.all(24),
              ),
            );
          },
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Theme.of(context).colorScheme.error,
                margin: const EdgeInsets.all(24),
              ),
            );
          },
          loaded: (user, config, _, _, _) {
            if (config != null) {
              _updateControllers(
                config.assignmentsSheetUrl,
                config.followUpSheetUrl,
              );
            }
          },
          orElse: () {},
        );
      },
      child: Scaffold(
        appBar: CustomAppBar(title: 'Settings Dashboard'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                children: [
                  // User Profile Section
                  BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (p, c) =>
                        p.maybeMap(
                          loaded: (s1) => s1.user,
                          orElse: () => null,
                        ) !=
                        c.maybeMap(loaded: (s2) => s2.user, orElse: () => null),
                    builder: (context, state) {
                      final user = state.maybeWhen(
                        loaded: (user, _, _, _, _) => user,
                        orElse: () => null,
                      );
                      return UserProfileCard(user: user);
                    },
                  ),
                  const SizedBox(height: 48),

                  // Theme Settings
                  _SectionHeader(
                    title: 'Appearance',
                    icon: Icons.palette_outlined,
                  ),
                  const SizedBox(height: 16),
                  const ThemeSelector(),
                  const SizedBox(height: 48),

                  // Sheet Config
                  _SectionHeader(
                    title: 'Integrations',
                    icon: Icons.link_rounded,
                  ),
                  const SizedBox(height: 16),
                  SheetConfigSection(
                    assignmentController: _assignmentController,
                    followUpController: _followUpController,
                  ),

                  const SizedBox(height: 64),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Footer
                  const SettingsFooter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
