import '../../domain/entities/follow_up_config_entity.dart';

class FollowUpConfigModel extends FollowUpConfigEntity {
  const FollowUpConfigModel({
    required super.assignmentsSheetId,
    required super.followUpSheetId,
  });

  factory FollowUpConfigModel.fromJson(Map<String, dynamic> json) {
    return FollowUpConfigModel(
      assignmentsSheetId: json['assignmentsSheetId'] as String,
      followUpSheetId: json['followUpSheetId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentsSheetId': assignmentsSheetId,
      'followUpSheetId': followUpSheetId,
    };
  }
}
