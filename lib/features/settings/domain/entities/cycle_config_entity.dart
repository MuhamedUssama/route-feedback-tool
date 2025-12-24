import 'package:equatable/equatable.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';

class CycleConfigEntity extends Equatable {
  final int cycleNumber;
  final String trackName;
  final String assignmentEmailColumn;
  final String followUpEmailColumn;
  final List<GroupConfigEntity> groups;

  const CycleConfigEntity({
    required this.cycleNumber,
    required this.trackName,
    required this.assignmentEmailColumn,
    required this.followUpEmailColumn,
    required this.groups,
  });

  @override
  List<Object?> get props => [
    cycleNumber,
    trackName,
    assignmentEmailColumn,
    followUpEmailColumn,
    groups,
  ];
}
