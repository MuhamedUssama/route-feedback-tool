import 'package:equatable/equatable.dart';

class StudentEntity extends Equatable {
  final String name;
  final String email;
  final String status;
  final bool isSelected;
  final String missingAssignmentName;
  final int rowNumber;
  final int? followUpRowNumber;

  const StudentEntity({
    required this.name,
    required this.email,
    required this.status,
    this.isSelected = false,
    required this.missingAssignmentName,
    required this.rowNumber,
    this.followUpRowNumber,
  });

  StudentEntity copyWith({
    String? name,
    String? email,
    String? status,
    bool? isSelected,
    String? missingAssignmentName,
    int? rowNumber,
    int? followUpRowNumber,
  }) {
    return StudentEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      status: status ?? this.status,
      isSelected: isSelected ?? this.isSelected,
      missingAssignmentName:
          missingAssignmentName ?? this.missingAssignmentName,
      rowNumber: rowNumber ?? this.rowNumber,
      followUpRowNumber: followUpRowNumber ?? this.followUpRowNumber,
    );
  }

  @override
  List<Object?> get props => [
    name,
    email,
    status,
    isSelected,
    missingAssignmentName,
    rowNumber,
    followUpRowNumber,
  ];
}
