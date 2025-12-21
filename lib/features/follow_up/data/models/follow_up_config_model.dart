import '../../domain/entities/follow_up_config_entity.dart';

class FollowUpConfigModel extends FollowUpConfigEntity {
  const FollowUpConfigModel({
    required super.assignmentsSheetUrl,
    required super.followUpSheetUrl,
  });

  factory FollowUpConfigModel.fromJson(Map<String, dynamic> json) {
    return FollowUpConfigModel(
      assignmentsSheetUrl: json['assignmentsSheetUrl'] as String? ?? '',
      followUpSheetUrl: json['followUpSheetUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assignmentsSheetUrl': assignmentsSheetUrl,
      'followUpSheetUrl': followUpSheetUrl,
    };
  }
}
