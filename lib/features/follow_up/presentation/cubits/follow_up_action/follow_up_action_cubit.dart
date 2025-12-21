import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:mentor_assistant/core/utils/google_sheet_url_parser.dart';
import '../../../domain/entities/sheet_column_entity.dart';
import '../../../domain/entities/student_entity.dart';
import '../../../domain/entities/follow_up_config_entity.dart';
import '../../../domain/usecases/check_missing_assignments_usecase.dart';
import '../../../domain/usecases/get_sheet_headers_usecase.dart';
import '../../../domain/usecases/send_follow_up_email_usecase.dart';
import '../../../domain/usecases/update_student_status_usecase.dart';

part 'follow_up_action_state.dart';
part 'follow_up_action_cubit.freezed.dart';

@injectable
class FollowUpActionCubit extends Cubit<FollowUpActionState> {
  final GetSheetHeadersUseCase _getSheetHeadersUseCase;
  final CheckMissingAssignmentsUseCase _checkMissingAssignmentsUseCase;
  final SendFollowUpEmailUseCase _sendFollowUpEmailUseCase;
  final UpdateStudentStatusUseCase _updateStudentStatusUseCase;

  FollowUpActionCubit(
    this._getSheetHeadersUseCase,
    this._checkMissingAssignmentsUseCase,
    this._sendFollowUpEmailUseCase,
    this._updateStudentStatusUseCase,
  ) : super(const FollowUpActionState.initial());

  Future<void> fetchSetupData({
    required String assignmentSheetUrl,
    required int assignmentHeaderRowIndex,
    required String followUpSheetUrl,
    required int followUpHeaderRowIndex,
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

    final assignmentHeaders = assignmentResult.getOrElse(() => []);
    final followUpHeaders = followUpResult.getOrElse(() => []);

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

    final result = await _checkMissingAssignmentsUseCase(
      CheckMissingAssignmentsParams(
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
      (students) => emit(FollowUpActionState.studentsLoaded(students)),
    );
  }

  Future<void> sendToSelectedStudents({
    required List<StudentEntity> students,
    required String assignmentName,
    required String spreadsheetUrl,
    required int statusColumnIndex,
  }) async {
    final failedEmails = <String>[];
    int sentCount = 0;
    final total = students.length;

    final sheetInfo = GoogleSheetUrlParser.parse(spreadsheetUrl);
    if (sheetInfo == null) {
      emit(const FollowUpActionState.error("Invalid Spreadsheet URL"));
      return;
    }

    for (int i = 0; i < total; i++) {
      final student = students[i];

      // Update progress
      emit(
        FollowUpActionState.sendingProgress(
          total: total,
          current: i + 1,
          failedEmails: List.from(failedEmails),
        ),
      );

      // Throttling
      if (i > 0) {
        await Future.delayed(const Duration(seconds: 2));
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
        // Fire and forget status update to not block the loop too much,
        // or await if we want strict consistency. Let's await to be safe.
        await _updateStudentStatusUseCase(
          UpdateStudentStatusParams(
            spreadsheetId: sheetInfo.spreadsheetId,
            rowIndex: student.rowNumber,
            statusColumnIndex: statusColumnIndex,
            action: FollowUpAction.sent,
            sheetId: sheetInfo.gid,
          ),
        );
      }
    }

    emit(
      FollowUpActionState.success(
        'Sent: $sentCount, Failed: ${failedEmails.length}',
      ),
    );
  }
}
