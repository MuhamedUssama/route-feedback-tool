import 'package:equatable/equatable.dart';
import '../../domain/entities/follow_up_config_entity.dart';

class StudentStatusUpdateModel extends Equatable {
  final int rowIndex;
  final int statusColumnIndex;
  final FollowUpAction action;
  final int? sheetId;
  final String? note;

  const StudentStatusUpdateModel({
    required this.rowIndex,
    required this.statusColumnIndex,
    required this.action,
    this.sheetId,
    this.note,
  });

  @override
  List<Object?> get props => [
    rowIndex,
    statusColumnIndex,
    action,
    sheetId,
    note,
  ];
}
