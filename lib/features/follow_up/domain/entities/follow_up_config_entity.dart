import 'package:equatable/equatable.dart';

enum FollowUpAction { markedAsDone, sent }

class FollowUpConfigEntity extends Equatable {
  final String assignmentsSheetId;
  final String followUpSheetId;

  const FollowUpConfigEntity({
    required this.assignmentsSheetId,
    required this.followUpSheetId,
  });

  @override
  List<Object?> get props => [assignmentsSheetId, followUpSheetId];
}
