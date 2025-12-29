import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/usecases/usecase.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import 'package:mentor_assistant/core/utils/sheet_utils.dart';
import '../../../domain/entities/sheet_column_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/follow_up_config_entity.dart';
import '../../../domain/usecases/analyze_assignment_status_usecase.dart';
import '../../../domain/usecases/get_sheet_headers_usecase.dart';
import '../../../domain/usecases/send_follow_up_email_usecase.dart';
import '../../../domain/usecases/update_student_status_usecase.dart';
import '../../../domain/usecases/batch_update_student_status_usecase.dart';
import '../../../domain/usecases/check_student_replies_usecase.dart';
import '../../../domain/usecases/get_current_user_email_usecase.dart';
import '../../../data/models/student_status_update_model.dart';

part 'follow_up_action_state.dart';
part 'follow_up_action_cubit.freezed.dart';

@injectable
class FollowUpActionCubit extends Cubit<FollowUpActionState> {
  final GetSheetHeadersUseCase _getSheetHeadersUseCase;
  final AnalyzeAssignmentStatusUseCase _analyzeAssignmentStatusUseCase;
  final SendFollowUpEmailUseCase _sendFollowUpEmailUseCase;
  final UpdateStudentStatusUseCase _updateStudentStatusUseCase;
  final BatchUpdateStudentStatusUseCase _batchUpdateStudentStatusUseCase;
  final CheckStudentRepliesUseCase _checkStudentRepliesUseCase;
  final GetCurrentUserEmailUseCase _getCurrentUserEmailUseCase;

  FollowUpActionCubit(
    this._getSheetHeadersUseCase,
    this._analyzeAssignmentStatusUseCase,
    this._sendFollowUpEmailUseCase,
    this._updateStudentStatusUseCase,
    this._batchUpdateStudentStatusUseCase,
    this._checkStudentRepliesUseCase,
    this._getCurrentUserEmailUseCase,
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

    // 0. Fetch Current User Email (for link generation)
    String currentUserEmail = '';
    final emailResult = await _getCurrentUserEmailUseCase(NoParams());
    emailResult.fold(
      // Ignore error, just default to empty/generic link behavior if needed
      (failure) => null,
      (email) => currentUserEmail = email,
    );

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

      String? threadId;
      bool emailSent = false;

      emailResult.fold(
        (failure) {
          failedEmails.add(student.email);
        },
        (tId) {
          emailSent = true;
          threadId = tId;
          sentCount++;
        },
      );

      if (emailSent && threadId != null) {
        if (student.followUpRowNumber != null) {
          final authUserParam = currentUserEmail.isNotEmpty
              ? '?authuser=$currentUserEmail'
              : '';
          final formula =
              '=HYPERLINK("https://mail.google.com/mail/u/$authUserParam#inbox/$threadId", "Email Sent")';

          await _updateStudentStatusUseCase(
            UpdateStudentStatusParams(
              spreadsheetId: sheetInfo.spreadsheetId,
              rowIndex: student.followUpRowNumber!,
              statusColumnIndex: statusColumnIndex,
              action: FollowUpAction.sent,
              sheetId: sheetInfo.gid,
              formula: formula,
            ),
          );
        } else {
          failedEmails.add(
            '${student.email} (Status Update Failed: Row Unknown)',
          );
        }
      } else if (emailSent) {
        failedEmails.add('${student.email} (No Thread ID returned)');
      }
    }

    if (markSubmittedAsDone) {
      final validSubmitted = submittedStudents
          .where((s) => s.followUpRowNumber != null)
          .toList();

      final skippedCount = submittedStudents.length - validSubmitted.length;
      if (skippedCount > 0) {
        currentProgress += skippedCount;
        failedEmails.add('$skippedCount students skipped (Missing Row Number)');
      }

      const chunkSize = 50;
      for (int i = 0; i < validSubmitted.length; i += chunkSize) {
        final end = (i + chunkSize < validSubmitted.length)
            ? i + chunkSize
            : validSubmitted.length;
        final chunk = validSubmitted.sublist(i, end);

        final updates = chunk.map((student) {
          return StudentStatusUpdateModel(
            rowIndex: student.followUpRowNumber!,
            statusColumnIndex: statusColumnIndex,
            action: FollowUpAction.markedAsDone,
            sheetId: sheetInfo.gid,
          );
        }).toList();

        final result = await _batchUpdateStudentStatusUseCase(
          BatchUpdateStudentStatusParams(
            spreadsheetId: sheetInfo.spreadsheetId,
            updates: updates,
          ),
        );

        result.fold(
          (failure) {
            failedEmails.add(
              'Batch Update Failed for ${chunk.length} students: ${failure.message}',
            );
          },
          (_) {
            markedDoneCount += chunk.length;
          },
        );

        currentProgress += chunk.length;
        emit(
          FollowUpActionState.sendingProgress(
            total: total,
            current: currentProgress,
            failedEmails: List.from(failedEmails),
          ),
        );
      }
    }

    emit(
      FollowUpActionState.success(
        'Sent: $sentCount, Marked Done: $markedDoneCount, Failed: ${failedEmails.length}',
      ),
    );
  }

  Future<void> checkReplies({
    required String spreadsheetUrl,
    required int statusColumnIndex,
    required int followUpHeaderRowIndex,
    required String masterSheetUrl,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
  }) async {
    emit(const FollowUpActionState.loadingStudents());

    final sheetInfo = GoogleSheetUrlParser.parse(spreadsheetUrl);
    if (sheetInfo == null) {
      emit(const FollowUpActionState.error("Invalid Spreadsheet URL"));
      return;
    }

    final result = await _checkStudentRepliesUseCase(
      CheckStudentRepliesParams(
        spreadsheetId: sheetInfo.spreadsheetId,
        sheetId: sheetInfo.gid,
        statusColumnIndex: statusColumnIndex,
        followUpHeaderRowIndex: followUpHeaderRowIndex,
      ),
    );

    await result.fold(
      (failure) async {
        emit(FollowUpActionState.error(failure.message));
      },
      (_) async {
        emit(const FollowUpActionState.success('Replies Checked Successfully'));

        await checkAssignments(
          masterSheetUrl: masterSheetUrl,
          masterHeaderRowIndex: masterHeaderRowIndex,
          localHeaderRowIndex: localHeaderRowIndex,
          gradeColumnIndex: gradeColumnIndex,
          currentSheetUrl: spreadsheetUrl,
        );
      },
    );
  }
}
