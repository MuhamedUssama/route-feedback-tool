import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_cubit.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_state.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_empty_state_widget.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_form_widget.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.I<ReportCubit>(),
      child: const _ReportScreenView(),
    );
  }
}

class _ReportScreenView extends StatefulWidget {
  const _ReportScreenView();

  @override
  State<_ReportScreenView> createState() => _ReportScreenViewState();
}

class _ReportScreenViewState extends State<_ReportScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportCubit>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReportCubit, ReportState>(
      listener: (context, state) {
        state.whenOrNull(
          error: (msg) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          },
          ready: (_, _, _, errorMessage) {
            if (errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
      builder: (context, state) {
        return Scaffold(
          appBar: const CustomAppBar(
            title: 'Weekly Report Dashboard',
            withBackButton: false,
          ),
          body: state.maybeWhen(
            loading: () => const Center(child: CircularProgressIndicator()),
            noConfig: () => const ReportEmptyStateWidget(),
            ready: (config, stats, loadingGroupNames, _) => ReportFormWidget(
              groups: config.groups,
              stats: stats,
              loadingGroupNames: loadingGroupNames.toList(),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          floatingActionButton: state.maybeWhen(
            noConfig: () => null,
            orElse: () => FloatingActionButton.extended(
              onPressed: () => _showPdfPlaceholder(context),
              label: const Text('Generate PDF'),
              icon: const Icon(Icons.picture_as_pdf),
            ),
          ),
        );
      },
    );
  }

  void _showPdfPlaceholder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'PDF Generation is pending refactoring for new state management.',
        ),
      ),
    );
  }
}
