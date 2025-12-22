import 'package:equatable/equatable.dart';

class GroupConfigEntity extends Equatable {
  final String groupName;
  final bool isOnline;
  final String? branchName;
  final int assignmentStartRow;
  final int assignmentEndRow;

  const GroupConfigEntity({
    required this.groupName,
    required this.isOnline,
    this.branchName,
    required this.assignmentStartRow,
    required this.assignmentEndRow,
  });

  @override
  List<Object?> get props => [
    groupName,
    isOnline,
    branchName,
    assignmentStartRow,
    assignmentEndRow,
  ];
}
