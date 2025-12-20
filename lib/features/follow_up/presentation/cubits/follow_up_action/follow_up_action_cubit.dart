import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
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
    required String assignmentSheetId,
    required int assignmentHeaderRowIndex,
    required String followUpSheetId,
    required int followUpHeaderRowIndex,
  }) async {
    emit(const FollowUpActionState.loadingHeaders());

    final results = await Future.wait([
      _getSheetHeadersUseCase(
        GetSheetHeadersParams(
          spreadsheetId: assignmentSheetId,
          sheetIndex: 0,
          headerRowIndex: assignmentHeaderRowIndex,
        ),
      ),
      _getSheetHeadersUseCase(
        GetSheetHeadersParams(
          spreadsheetId: followUpSheetId,
          sheetIndex: 0,
          headerRowIndex: followUpHeaderRowIndex,
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
    required String masterSheetId,
    required int masterSheetIndex,
    required int masterHeaderRowIndex,
    required int localHeaderRowIndex,
    required int gradeColumnIndex,
    required String currentSheetId,
  }) async {
    emit(const FollowUpActionState.loadingStudents());
    final result = await _checkMissingAssignmentsUseCase(
      CheckMissingAssignmentsParams(
        masterSheetId: masterSheetId,
        masterSheetIndex: masterSheetIndex,
        masterHeaderRowIndex: masterHeaderRowIndex,
        localHeaderRowIndex: localHeaderRowIndex,
        gradeColumnIndex: gradeColumnIndex,
        currentSheetId: currentSheetId,
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
    required String spreadsheetId,
    required int statusColumnIndex,
  }) async {
    final failedEmails = <String>[];
    int sentCount = 0;
    final total = students.length;

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
            spreadsheetId: spreadsheetId,
            rowIndex: student.rowNumber,
            statusColumnIndex: statusColumnIndex,
            action: FollowUpAction.sent,
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
