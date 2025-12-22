import 'package:hive_ce/hive.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/features/settings/domain/entities/cycle_config_entity.dart';

part 'cycle_config_model.g.dart';

@HiveType(typeId: 1)
class CycleConfigModel {
  @HiveField(0)
  final int cycleNumber;

  @HiveField(1)
  final String trackName;

  @HiveField(2)
  final List<GroupConfigModel> groups;

  CycleConfigModel({
    required this.cycleNumber,
    required this.trackName,
    required this.groups,
  });

  factory CycleConfigModel.fromEntity(CycleConfigEntity entity) {
    return CycleConfigModel(
      cycleNumber: entity.cycleNumber,
      trackName: entity.trackName,
      groups: entity.groups.map((e) => GroupConfigModel.fromEntity(e)).toList(),
    );
  }

  CycleConfigEntity toEntity() {
    return CycleConfigEntity(
      cycleNumber: cycleNumber,
      trackName: trackName,
      groups: groups.map((e) => e.toEntity()).toList(),
    );
  }
}
