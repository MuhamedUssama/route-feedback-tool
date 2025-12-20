part of 'follow_up_action_cubit.dart';

@freezed
class FollowUpActionState with _$FollowUpActionState {
  const factory FollowUpActionState.initial() = _Initial;
  const factory FollowUpActionState.loadingHeaders() = _LoadingHeaders;
  const factory FollowUpActionState.headersLoaded({
    required List<SheetColumnEntity> assignmentHeaders,
    required List<SheetColumnEntity> followUpHeaders,
  }) = _HeadersLoaded;
  const factory FollowUpActionState.loadingStudents() = _LoadingStudents;
  const factory FollowUpActionState.studentsLoaded(
    List<StudentEntity> students,
  ) = _StudentsLoaded;
  const factory FollowUpActionState.sendingProgress({
    required int total,
    required int current,
    required List<String> failedEmails,
  }) = _SendingProgress;
  const factory FollowUpActionState.success(String message) = _Success;
  const factory FollowUpActionState.error(String message) = _Error;
}
