import 'package:equatable/equatable.dart';
import 'student_entity.dart';

class AssignmentAnalysisResult extends Equatable {
  final List<StudentEntity> missingStudents;
  final List<StudentEntity> submittedStudents;

  const AssignmentAnalysisResult({
    required this.missingStudents,
    required this.submittedStudents,
  });

  @override
  List<Object?> get props => [missingStudents, submittedStudents];
}
