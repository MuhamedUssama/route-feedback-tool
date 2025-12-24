import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/core/services/pdf_generator_service.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_cubit.dart';
import 'package:mentor_assistant/features/report/presentation/cubits/report_state.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_empty_state_widget.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_form_widget.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:printing/printing.dart';

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
  final _formKey = GlobalKey<FormState>();
  // DTO to hold harvested data
  final WeeklyReportDto _dto = WeeklyReportDto();

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
            ready: (config, stats, loadingGroupNames, _) => Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: () {
                setState(() {}); // specific rebuild to check _dto.isValid
              },
              child: ReportFormWidget(
                groups: config.groups,
                stats: stats,
                loadingGroupNames: loadingGroupNames.toList(),
                dto: _dto,
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
          floatingActionButton: state.maybeWhen(
            noConfig: () => null,
            orElse: () => _buildFab(context, _dto.isValid, state),
          ),
        );
      },
    );
  }

  Widget _buildFab(BuildContext context, bool isValid, ReportState state) {
    final fab = FloatingActionButton.extended(
      onPressed: isValid ? () => _generatePdf(context, state) : null,
      label: const Text('Generate PDF'),
      icon: const Icon(Icons.picture_as_pdf),
      backgroundColor: isValid ? null : Theme.of(context).disabledColor,
    );

    if (isValid) return fab;

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: AbsorbPointer(child: fab),
    );
  }

  void _generatePdf(BuildContext context, ReportState state) {
    // if (_formKey.currentState?.validate() ?? false) {
    _formKey.currentState!.save();

    // Verification: Print harvested data
    debugPrint('Harvesting Complete:');
    debugPrint('Refactoring: Workshop Topic: ${_dto.workshop.topic}');

    state.whenOrNull(
      ready: (config, stats, _, __) {
        // This is where we will combine DTO + Config + Stats to create WeeklyReportModel
        // and call PdfGeneratorService.
        _createAndPrintModel(config.groups, stats);
      },
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Processing Report... (Check Debug Console)'),
      ),
    );
    // }
    // else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text('Please fill all fields first'),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    // }
  }

  Future<void> _createAndPrintModel(
    List<GroupConfigModel> groups,
    Map<String, Map<String, int>> stats,
  ) async {
    try {
      final report = WeeklyReportModel(
        reportDate: DateTime.now(),
        workshop: WorkshopInfoModel(
          topic: _dto.workshop.topic ?? 'N/A',
          date: _dto.workshop.date ?? DateTime.now(),
        ),
        groups: groups.map((g) {
          final gDto = _dto.getGroup(g.groupName);
          final gStats =
              stats[g.groupName] ?? {'submitted': 0, 'unsubmitted': 0};
          return GroupReportModel(
            groupName: g.groupName,
            assignmentNumber: gDto.assignmentNumber ?? '',
            assignmentName: gDto.assignmentName ?? '',
            deadline: gDto.deadline,
            feedbackDone: gDto.feedbackDone,
            submittedCount: gStats['submitted'] ?? 0,
            missingCount: gStats['unsubmitted'] ?? 0,
            assignmentColumn: gDto.assignmentColumn ?? '',
            followUpColumn: gDto.followUpColumn ?? '',
          );
        }).toList(),
        logistics: groups.where((g) => !g.isOnline).map((g) {
          final lDto = _dto.getLogistics(g.groupName);
          return LogisticsInfoModel(
            groupName: g.groupName,
            visited: lDto.visited,
            exceptionReason: lDto.exceptionReason,
            arrivalTime: lDto.arrivalTime,
            leavingTime: lDto.leavingTime,
          );
        }).toList(),
      );

      final pdfService = PdfGeneratorService();
      final pdfBytes = await pdfService.generateReport(report);

      // Dynamic Filename Logic
      // [MentorName] - [TrackName] ([CycleName]) - [Date].pdf

      String mentorName = "Mohamed Osama";

      String trackName = "Track";

      if (groups.isNotEmpty) {
        trackName = groups.first.groupName;
      }

      final dateStr = DateFormat('d MMMM').format(DateTime.now());
      final fileName = '$mentorName - $trackName - $dateStr.pdf';

      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Report',
          fileName: fileName,
          allowedExtensions: ['pdf'],
          type: FileType.custom,
        );

        if (outputFile != null) {
          String path = outputFile;
          if (!path.endsWith('.pdf')) path += '.pdf';
          final file = File(path);
          await file.writeAsBytes(pdfBytes);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Report saved to $path'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        // Mobile fallback
        await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
      }
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
