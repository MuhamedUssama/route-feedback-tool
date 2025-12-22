import 'package:hive_ce/hive.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';

part 'group_config_model.g.dart';

@HiveType(typeId: 0)
class GroupConfigModel {
  @HiveField(0)
  final String groupName;

  @HiveField(1)
  final bool isOnline;

  @HiveField(2)
  final String? branchName;

  @HiveField(3)
  final int assignmentStartRow;

  @HiveField(4)
  final int assignmentEndRow;

  @HiveField(5)
  final int followUpStartRow;

  @HiveField(6)
  final int followUpEndRow;

  GroupConfigModel({
    required this.groupName,
    required this.isOnline,
    this.branchName,
    required this.assignmentStartRow,
    required this.assignmentEndRow,
    required this.followUpStartRow,
    required this.followUpEndRow,
  });

  factory GroupConfigModel.fromEntity(GroupConfigEntity entity) {
    return GroupConfigModel(
      groupName: entity.groupName,
      isOnline: entity.isOnline,
      branchName: entity.branchName,
      assignmentStartRow: entity.assignmentStartRow,
      assignmentEndRow: entity.assignmentEndRow,
      followUpStartRow: entity.followUpStartRow,
      followUpEndRow: entity.followUpEndRow,
    );
  }

  GroupConfigEntity toEntity() {
    return GroupConfigEntity(
      groupName: groupName,
      isOnline: isOnline,
      branchName: branchName,
      assignmentStartRow: assignmentStartRow,
      assignmentEndRow: assignmentEndRow,
      followUpStartRow: followUpStartRow,
      followUpEndRow: followUpEndRow,
    );
  }
}
