import 'package:flutter/material.dart';

// ----------------------
// Mutable DTOs (For Form Harvesting)
// ----------------------

class WeeklyReportDto {
  final WorkshopInfoDto workshop = WorkshopInfoDto();
  final Map<String, GroupReportDto> _groups = {};
  final Map<String, LogisticsInfoDto> _logistics = {};

  GroupReportDto getGroup(String groupName) {
    if (!_groups.containsKey(groupName)) {
      _groups[groupName] = GroupReportDto();
    }
    return _groups[groupName]!;
  }

  LogisticsInfoDto getLogistics(String groupName) {
    if (!_logistics.containsKey(groupName)) {
      _logistics[groupName] = LogisticsInfoDto();
    }
    return _logistics[groupName]!;
  }

  // Validation Logic
  bool get isValid {
    // 1. Workshop Valid
    if (!workshop.isValid) return false;

    // 2. Groups Valid
    if (_groups.isEmpty) return false;
    if (_groups.values.any((g) => !g.isValid)) return false;

    // 3. Logistics Valid
    if (_logistics.values.any((l) => !l.isValid)) return false;

    return true;
  }
}

class WorkshopInfoDto {
  String? topic;
  DateTime? date;

  bool get isValid => (topic != null && topic!.isNotEmpty) && date != null;
}

class GroupReportDto {
  String? assignmentNumber;
  String? assignmentName;
  DateTime? deadline;
  bool feedbackDone = false;
  String? assignmentColumn;
  String? followUpColumn;

  GroupReportDto();

  bool get isValid =>
      (assignmentNumber != null && assignmentNumber!.isNotEmpty) &&
      (assignmentName != null && assignmentName!.isNotEmpty) &&
      (assignmentColumn != null && assignmentColumn!.isNotEmpty) &&
      (followUpColumn != null && followUpColumn!.isNotEmpty) &&
      deadline != null;
}

class LogisticsInfoDto {
  bool visited = false;
  String? exceptionReason;
  TimeOfDay? arrivalTime;
  TimeOfDay? leavingTime;

  LogisticsInfoDto();

  bool get isValid {
    if (visited) {
      return arrivalTime != null && leavingTime != null;
    } else {
      return exceptionReason != null && exceptionReason!.isNotEmpty;
    }
  }
}

// ----------------------
// Final Immutable Models (For PDF Generation)
// ----------------------

class WeeklyReportModel {
  final DateTime reportDate;
  final WorkshopInfoModel workshop;
  final List<GroupReportModel> groups;
  final List<LogisticsInfoModel> logistics;

  WeeklyReportModel({
    required this.reportDate,
    required this.workshop,
    required this.groups,
    required this.logistics,
  });
}

class WorkshopInfoModel {
  final String topic;
  final DateTime date;

  WorkshopInfoModel({required this.topic, required this.date});
}

class GroupReportModel {
  final String groupName;
  final String assignmentNumber;
  final String assignmentName;
  final DateTime? deadline;
  final bool feedbackDone;
  final int submittedCount;
  final int missingCount;
  final String assignmentColumn;
  final String followUpColumn;

  GroupReportModel({
    required this.groupName,
    required this.assignmentNumber,
    required this.assignmentName,
    this.deadline,
    required this.feedbackDone,
    required this.submittedCount,
    required this.missingCount,
    required this.assignmentColumn,
    required this.followUpColumn,
  });
}

class LogisticsInfoModel {
  final String groupName;
  final bool visited;
  final String? exceptionReason;
  final TimeOfDay? arrivalTime;
  final TimeOfDay? leavingTime;

  LogisticsInfoModel({
    required this.groupName,
    required this.visited,
    this.exceptionReason,
    this.arrivalTime,
    this.leavingTime,
  });
}
