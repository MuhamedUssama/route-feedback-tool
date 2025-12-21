import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import 'package:mentor_assistant/core/utils/sheet_utils.dart';
import '../../../domain/entities/sheet_column_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/follow_up_config_entity.dart';
import '../../../domain/usecases/analyze_assignment_status_usecase.dart';
import '../../../domain/usecases/get_sheet_headers_usecase.dart';
import '../../../domain/usecases/send_follow_up_email_usecase.dart';
import '../../../domain/usecases/update_student_status_usecase.dart';

part 'follow_up_action_state.dart';
part 'follow_up_action_cubit.freezed.dart';

@injectable
class FollowUpActionCubit extends Cubit<FollowUpActionState> {
  final GetSheetHeadersUseCase _getSheetHeadersUseCase;
  final AnalyzeAssignmentStatusUseCase _analyzeAssignmentStatusUseCase;
  final SendFollowUpEmailUseCase _sendFollowUpEmailUseCase;
  final UpdateStudentStatusUseCase _updateStudentStatusUseCase;

  FollowUpActionCubit(
    this._getSheetHeadersUseCase,
    this._analyzeAssignmentStatusUseCase,
    this._sendFollowUpEmailUseCase,
    this._updateStudentStatusUseCase,
  ) : super(const FollowUpActionState.initial());

  Future<void> fetchSetupData({
    required String assignmentSheetUrl,
    required int assignmentHeaderRowIndex,
    required String assignmentStartColLetter,
    required String followUpSheetUrl,
    required int followUpHeaderRowIndex,
    required String followUpStartColLetter,
  }) async {
    emit(const FollowUpActionState.loadingHeaders());

    final assignmentInfo = GoogleSheetUrlParser.parse(assignmentSheetUrl);
    final followUpInfo = GoogleSheetUrlParser.parse(followUpSheetUrl);

    if (assignmentInfo == null) {
      emit(const FollowUpActionState.error("Invalid Assignment Sheet URL"));
      return;
    }
    if (followUpInfo == null) {
      emit(const FollowUpActionState.error("Invalid Follow-Up Sheet URL"));
      return;
    }

    final results = await Future.wait([
      _getSheetHeadersUseCase(
        GetSheetHeadersParams(
          spreadsheetId: assignmentInfo.spreadsheetId,
          sheetId: assignmentInfo.gid,
          headerRowIndex: assignmentHeaderRowIndex,
          detectMergedHeaders: true, // Enable Smart Fallback
        ),
      ),
      _getSheetHeadersUseCase(
        GetSheetHeadersParams(
          spreadsheetId: followUpInfo.spreadsheetId,
          sheetId: followUpInfo.gid,
          headerRowIndex: followUpHeaderRowIndex,
          detectMergedHeaders: false, // Standard behavior
        ),
      ),
    ]);

    final assignmentResult = results[0];
    final followUpResult = results[1];

    if (assignmentResult.isLeft()) {
      assignmentResult.fold(
        (l) =>
            emit(FollowUpActionState.error("Assignment Sheet: ${l.message}")),
        (r) {},
      );
      return;
    }
    if (followUpResult.isLeft()) {
      followUpResult.fold(
        (l) => emit(FollowUpActionState.error("Follow-Up Sheet: ${l.message}")),
        (r) {},
      );
      return;
    }

    // Filter Headers
    final minAssignmentIndex = SheetUtils.columnLetterToIndex(
      assignmentStartColLetter,
    );
    final minFollowUpIndex = SheetUtils.columnLetterToIndex(
      followUpStartColLetter,
    );

    final assignmentHeaders = assignmentResult
        .getOrElse(() => [])
        .where((col) => col.index >= minAssignmentIndex)
        .toList();

    final followUpHeaders = followUpResult
        .getOrElse(() => [])
        .where((col) => col.index >= minFollowUpIndex)
        .toList();

    emit(
      FollowUpActionState.headersLoaded(
        assignmentHeaders: assignmentHeaders,
        followUpHeaders: followUpHeaders,
      ),
    );
  }

  Future<void> checkAssignments({
    required String masterSheetUrl,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetUrl,
  }) async {
    emit(const FollowUpActionState.loadingStudents());

    final masterInfo = GoogleSheetUrlParser.parse(masterSheetUrl);
    final currentInfo = GoogleSheetUrlParser.parse(currentSheetUrl);

    if (masterInfo == null) {
      emit(const FollowUpActionState.error("Invalid Master Sheet URL"));
      return;
    }
    if (currentInfo == null) {
      emit(const FollowUpActionState.error("Invalid Current Sheet URL"));
      return;
    }

    final result = await _analyzeAssignmentStatusUseCase(
      AnalyzeAssignmentStatusParams(
        masterSheetId: masterInfo.spreadsheetId,
        masterSheetIdGid: masterInfo.gid,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentInfo.spreadsheetId,
        currentSheetIdGid: currentInfo.gid,
      ),
    );

    result.fold(
      (failure) => emit(FollowUpActionState.error(failure.message)),
      (analysis) => emit(
        FollowUpActionState.studentsLoaded(
          missingStudents: analysis.missingStudents,
          submittedStudents: analysis.submittedStudents,
        ),
      ),
    );
  }

  Future<void> sendToSelectedStudents({
    required List<StudentEntity> students,
    required List<StudentEntity> submittedStudents,
    required String assignmentName,
    required String spreadsheetUrl,
    required int statusColumnIndex,
    required bool markSubmittedAsDone,
  }) async {
    final failedEmails = <String>[];
    int sentCount = 0;
    int markedDoneCount = 0;
    final total =
        students.length + (markSubmittedAsDone ? submittedStudents.length : 0);
    int currentProgress = 0;

    final sheetInfo = GoogleSheetUrlParser.parse(spreadsheetUrl);
    if (sheetInfo == null) {
      emit(const FollowUpActionState.error("Invalid Spreadsheet URL"));
      return;
    }

    // 1. Send Emails to Missing Students
    for (int i = 0; i < students.length; i++) {
      currentProgress++;
      final student = students[i];

      // Update progress
      emit(
        FollowUpActionState.sendingProgress(
          total: total,
          current: currentProgress,
          failedEmails: List.from(failedEmails),
        ),
      );

      // Throttling
      if (i > 0) {
        await Future.delayed(const Duration(milliseconds: 1500));
      }

      // Send Email
      final emailResult = await _sendFollowUpEmailUseCase(
        SendFollowUpEmailParams(
          student: student,
          assignmentName: assignmentName,
        ),
      );

      bool emailSent = false;
      emailResult.fold(
        (failure) {
          failedEmails.add(student.email);
        },
        (_) {
          emailSent = true;
          sentCount++;
        },
      );

      // Status Update (Only if email sent successfully)
      if (emailSent) {
        if (student.followUpRowNumber != null) {
          await _updateStudentStatusUseCase(
            UpdateStudentStatusParams(
              spreadsheetId: sheetInfo.spreadsheetId,
              rowIndex: student.followUpRowNumber!,
              statusColumnIndex: statusColumnIndex,
              action: FollowUpAction.sent,
              sheetId: sheetInfo.gid,
            ),
          );
        } else {
          failedEmails.add(
            '${student.email} (Status Update Failed: Row Unknown)',
          );
        }
      }
    }

    // 2. Batch Mark Submitted Students as Done
    if (markSubmittedAsDone) {
      for (int i = 0; i < submittedStudents.length; i++) {
        currentProgress++;
        final student = submittedStudents[i];
        // Update progress
        emit(
          FollowUpActionState.sendingProgress(
            total: total,
            current: currentProgress,
            failedEmails: List.from(failedEmails),
          ),
        );

        if (student.followUpRowNumber != null) {
          // We can optimize this by doing batch updates if the API supports it,
          // but for now reusing the usecase row by row is safer and easier to implement.
          // We might want to throttle this slightly too if it's too fast,
          // but usually sheet updates are okay.
          await _updateStudentStatusUseCase(
            UpdateStudentStatusParams(
              spreadsheetId: sheetInfo.spreadsheetId,
              rowIndex: student.followUpRowNumber!,
              statusColumnIndex: statusColumnIndex,
              action: FollowUpAction.markedAsDone,
              sheetId: sheetInfo.gid,
            ),
          );
          markedDoneCount++;
        }
      }
    }

    emit(
      FollowUpActionState.success(
        'Sent: $sentCount, Marked Done: $markedDoneCount, Failed: ${failedEmails.length}',
      ),
    );
  }
}
