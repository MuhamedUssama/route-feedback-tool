import 'package:dartz/dartz.dart';
import 'package:mentor_assistant/core/errors/failures.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';

abstract interface class ReportRepository {
  Future<Either<Failure, Map<String, int>>> calculateGroupStats({
    required GroupConfigEntity group,
    required String assignmentSheetUrl,
    required String followUpSheetUrl,
    required String assignmentColumn,
    required String followUpColumn,
    required String assignmentEmailAnchorColumn,
    required String followUpEmailAnchorColumn,
  });
}
