import '../../domain/entities/student_entity.dart';

class StudentModel extends StudentEntity {
  const StudentModel({
    required super.name,
    required super.email,
    required super.status,
    super.isSelected,
    required super.missingAssignmentName,
    required super.rowNumber,
  });

  factory StudentModel.fromRow({
    required List<dynamic> row,
    required int rowIndex,
    required Map<String, int> headersMap,
    required int gradeColumnIndex,
    required String assignmentName,
  }) {
    // Helper function to safely get cell value
    String getCell(int index) {
      if (index >= row.length) return '';
      return row[index]?.toString().trim() ?? '';
    }

    final emailIndex = headersMap['email'] ?? headersMap['email address'] ?? -1;
    final nameIndex = headersMap['name'] ?? headersMap['student name'] ?? -1;

    final email = emailIndex != -1 ? getCell(emailIndex).toLowerCase() : '';
    final name = nameIndex != -1 ? getCell(nameIndex) : 'Unknown Student';

    final grade = getCell(gradeColumnIndex);
    final isMissing = grade.isEmpty;

    return StudentModel(
      name: name,
      email: email,
      status: isMissing ? 'Missing' : 'Submitted',
      isSelected: isMissing,
      missingAssignmentName: assignmentName,
      rowNumber: rowIndex,
    );
  }
}
