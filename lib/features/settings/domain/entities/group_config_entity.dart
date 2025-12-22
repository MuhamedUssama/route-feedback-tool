import 'package:equatable/equatable.dart';

class GroupConfigEntity extends Equatable {
  final String groupName;
  final bool isOnline;
  final String? branchName;
  final int assignmentStartRow;
  final int assignmentEndRow;
  final int followUpStartRow;
  final int followUpEndRow;

  const GroupConfigEntity({
    required this.groupName,
    required this.isOnline,
    this.branchName,
    required this.assignmentStartRow,
    required this.assignmentEndRow,
    required this.followUpStartRow,
    required this.followUpEndRow,
  });

  @override
  List<Object?> get props => [
    groupName,
    isOnline,
    branchName,
    assignmentStartRow,
    assignmentEndRow,
    followUpStartRow,
    followUpEndRow,
  ];
}
