import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentor_assistant/core/dialogs/dialogs.dart';
import 'package:mentor_assistant/core/widgets/custom_appbar.dart';
import 'package:mentor_assistant/features/follow_up/domain/entities/student_entity.dart';
import 'package:mentor_assistant/features/follow_up/presentation/cubits/follow_up_action/follow_up_action_cubit.dart';
import 'package:mentor_assistant/features/follow_up/presentation/cubits/follow_up_config/follow_up_config_cubit.dart';
import 'package:mentor_assistant/features/follow_up/presentation/widgets/follow_up_action_footer.dart';
import 'package:mentor_assistant/features/follow_up/presentation/widgets/follow_up_filter_header.dart';
import 'package:mentor_assistant/features/follow_up/presentation/widgets/student_data_table.dart';

class FollowUpScreen extends StatelessWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetIt.I<FollowUpConfigCubit>()),
        BlocProvider(create: (context) => GetIt.I<FollowUpActionCubit>()),
      ],
      child: const _FollowUpView(),
    );
  }
}

class _FollowUpView extends StatefulWidget {
  const _FollowUpView();

  @override
  State<_FollowUpView> createState() => _FollowUpViewState();
}

class _FollowUpViewState extends State<_FollowUpView> {
  // Local State for Filters
  int? _assignmentRow;
  int? _followUpRow;
  int? _assignmentCol;
  int? _statusCol;

  List<StudentEntity> _selectedStudents = [];
  List<StudentEntity> _submittedStudents = [];

  @override
  void initState() {
    super.initState();
    // Gatekeeper Check: Check if config exists
    context.read<FollowUpConfigCubit>().checkConfig();
  }

  void _showSetupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => SetupDialog(
        onSave: (assignmentUrl, followUpUrl) {
          context.read<FollowUpConfigCubit>().saveConfig(
            assignmentsSheetUrl: assignmentUrl,
            followUpSheetUrl: followUpUrl,
          );
          Navigator.of(ctx).pop();
        },
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        title: 'Ready to Send?',
        message:
            'You are about to send follow-up emails to ${_selectedStudents.length} students. This action cannot be undone.',
        isDangerous: true,
        confirmText: 'SEND EMAILS',
        showCheckbox: _submittedStudents.isNotEmpty,
        checkboxLabel:
            'Also mark ${_submittedStudents.length} submitted students as "Done"',
        onConfirm: (markSubmittedAsDone) {
          Navigator.of(ctx).pop();
          _sendEmails(markSubmittedAsDone);
        },
      ),
    );
  }

  Future<void> _sendEmails(bool markSubmittedAsDone) async {
    final configState = context.read<FollowUpConfigCubit>().state;
    final spreadsheetUrl = configState.maybeWhen(
      configLoaded: (config) => config.followUpSheetUrl,
      orElse: () => null,
    );

    if (spreadsheetUrl == null || _statusCol == null) {
      _showMessenger(
        context,
        MessengerType.error,
        'Configuration Error',
        'Missing sheet configuration or status column selection.',
      );
      return;
    }

    context.read<FollowUpActionCubit>().sendToSelectedStudents(
      students: _selectedStudents,
      submittedStudents: _submittedStudents,
      assignmentName: _selectedStudents.isNotEmpty
          ? _selectedStudents.first.missingAssignmentName
          : (_submittedStudents.isNotEmpty
                ? _submittedStudents.first.missingAssignmentName
                : 'Assignment'),
      spreadsheetUrl: spreadsheetUrl,
      statusColumnIndex: _statusCol!,
      markSubmittedAsDone: markSubmittedAsDone,
    );
  }

  void _showMessenger(
    BuildContext context,
    MessengerType type,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (ctx) =>
          MessengerDialog(type: type, title: title, message: message),
    );
  }

  void _triggerCheckAssignments() {
    final configState = context.read<FollowUpConfigCubit>().state;
    final currentAssignmentSheetUrl = configState.maybeWhen(
      configLoaded: (config) => config.assignmentsSheetUrl,
      orElse: () => null,
    );

    final followUpSheetUrl = configState.maybeWhen(
      configLoaded: (config) => config.followUpSheetUrl,
      orElse: () => null,
    );

    // Validate all inputs
    if (currentAssignmentSheetUrl == null ||
        followUpSheetUrl == null ||
        _assignmentRow == null ||
        _followUpRow == null ||
        _assignmentCol == null || // Grade column in master
        _statusCol == null) {
      _showMessenger(
        context,
        MessengerType.error,
        'Invalid Selection',
        'Please ensure all fields (Rows & Columns) are selected.',
      );
      return;
    }

    context.read<FollowUpActionCubit>().checkAssignments(
      masterSheetUrl: currentAssignmentSheetUrl,
      masterHeaderRowIndex: _assignmentRow!,
      localHeaderRowIndex: _followUpRow!,
      gradeColumnIndex: _assignmentCol!,
      currentSheetUrl: followUpSheetUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Config Listener (Gatekeeper)
        BlocListener<FollowUpConfigCubit, FollowUpConfigState>(
          listener: (context, state) {
            state.whenOrNull(
              configMissing: () => _showSetupDialog(context),
              error: (msg) => _showMessenger(
                context,
                MessengerType.error,
                'Config Error',
                msg,
              ),
            );
          },
        ),
        // Action Listener (Feedback)
        BlocListener<FollowUpActionCubit, FollowUpActionState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (msg) => _showMessenger(
                context,
                MessengerType.success,
                'Success',
                msg,
              ),
              error: (msg) => _showMessenger(
                context,
                MessengerType.error,
                'Operation Failed',
                msg,
              ),
              studentsLoaded: (missing, submitted) {
                // Determine if mounted check needed
                setState(() {
                  _submittedStudents = submitted;
                });
              },
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Follow Up Dashboard'),
        body: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: FollowUpFilterHeader(
                onLoadColumns:
                    (assignRow, fUpRow, assignStartCol, fUpStartCol) {
                      setState(() {
                        _assignmentRow = assignRow;
                        _followUpRow = fUpRow;
                      });

                      final configState = context
                          .read<FollowUpConfigCubit>()
                          .state;

                      // Extract URLs
                      String? assignUrl;
                      String? fUpUrl;

                      configState.maybeWhen(
                        configLoaded: (config) {
                          assignUrl = config.assignmentsSheetUrl;
                          fUpUrl = config.followUpSheetUrl;
                        },
                        orElse: () {},
                      );

                      if (assignUrl != null && fUpUrl != null) {
                        context.read<FollowUpActionCubit>().fetchSetupData(
                          assignmentSheetUrl: assignUrl!,
                          assignmentHeaderRowIndex: assignRow,
                          assignmentStartColLetter: assignStartCol,
                          followUpSheetUrl: fUpUrl!,
                          followUpHeaderRowIndex: fUpRow,
                          followUpStartColLetter: fUpStartCol,
                        );
                      } else {
                        _showMessenger(
                          context,
                          MessengerType.error,
                          'Config Error',
                          'Sheet Configurations not found.',
                        );
                      }
                    },
                onFiltersChanged: (assignCol, statusCol) {
                  setState(() {
                    _assignmentCol = assignCol;
                    _statusCol = statusCol;
                  });
                },
              ),
            ),

            // Action Button (Animated)
            if (_assignmentRow != null &&
                _followUpRow != null &&
                _assignmentCol != null &&
                _statusCol != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: _triggerCheckAssignments,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 24,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: Size(
                      MediaQuery.of(context).size.width * 0.46,
                      56,
                    ),
                  ),
                  icon: const Icon(Icons.search_rounded, size: 28),
                  label: Text(
                    'CHECK FOR MISSING ASSIGNMENTS',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            // Data Table / Loading
            Expanded(
              child: BlocBuilder<FollowUpActionCubit, FollowUpActionState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loadingStudents: () => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Analyzing Sheets...',
                            style: GoogleFonts.inter(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    studentsLoaded: (missing, submitted) {
                      // Schedule store update if needed (avoiding setstate during build)
                      // Ideally we should use a Listener for side effects like updating local variables
                      // But for now, we can just use the provided list for the table.

                      // NOTE: Storing submitted in variable here is unsafe during build.
                      // Moving side effect to BlocListener or just using state data.
                      // Since we use _submittedStudents in dialog, we need to capture it.
                      // Best practice: Use BlocListener for side effects.
                      return StudentDataTable(
                        students: missing,
                        onSelectionChanged: (selected) {
                          setState(() {
                            _selectedStudents = selected;
                          });
                        },
                      );
                    },
                    // If sending, we could ideally keep the list visible.
                    // For now, we return empty or could potentially store state differently.
                    // Given strict requirements, shrinking is safe to avoid state loss crashes
                    // if we don't have the students list in this state.
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Footer
            FollowUpActionFooter(
              selectedCount: _selectedStudents.length,
              submittedCount: _submittedStudents.length,
              onSendPressed: () => _showConfirmationDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
