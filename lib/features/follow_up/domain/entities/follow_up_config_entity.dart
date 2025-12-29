import 'package:equatable/equatable.dart';

enum FollowUpAction { markedAsDone, sent, noAnswer }

class FollowUpConfigEntity extends Equatable {
  final String assignmentsSheetUrl;
  final String followUpSheetUrl;

  const FollowUpConfigEntity({
    required this.assignmentsSheetUrl,
    required this.followUpSheetUrl,
  });

  @override
  List<Object?> get props => [assignmentsSheetUrl, followUpSheetUrl];
}
