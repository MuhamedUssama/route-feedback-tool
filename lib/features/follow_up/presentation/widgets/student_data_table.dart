import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/entities/student_entity.dart';

class StudentDataTable extends StatefulWidget {
  final List<StudentEntity> students;
  final Function(List<StudentEntity> selected) onSelectionChanged;

  const StudentDataTable({
    super.key,
    required this.students,
    required this.onSelectionChanged,
  });

  @override
  State<StudentDataTable> createState() => _StudentDataTableState();
}

class _StudentDataTableState extends State<StudentDataTable> {
  final Set<int> _selectedIndices =
      {}; // Use indices for now, or student email/id if unique

  @override
  void didUpdateWidget(covariant StudentDataTable oldWidget) {
    if (widget.students != oldWidget.students) {
      // Logic to handle external updates if needed, e.g. clearing selection
      // For now, let's keep selection if indices match, or clear it.
      // A safer bet for a new list is usually to clear.
      _selectedIndices.clear();
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onRowSelected(bool? selected, int index) {
    setState(() {
      if (selected == true) {
        _selectedIndices.add(index);
      } else {
        _selectedIndices.remove(index);
      }
    });

    _notifySelection();
  }

  void _onAllSelected(bool? selected) {
    setState(() {
      if (selected == true) {
        for (var i = 0; i < widget.students.length; i++) {
          _selectedIndices.add(i);
        }
      } else {
        _selectedIndices.clear();
      }
    });
    _notifySelection();
  }

  void _notifySelection() {
    final selectedStudents = widget.students
        .asMap()
        .entries
        .where((entry) => _selectedIndices.contains(entry.key))
        .map((entry) => entry.value)
        .toList();
    widget.onSelectionChanged(selectedStudents);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No missing students found',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ).animate().fadeIn().scale(),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerTheme.color ?? Colors.grey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Scrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Scrollbar(
              thumbVisibility: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 800),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                    ),
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    showCheckboxColumn: true,
                    checkboxHorizontalMargin: 16,
                    onSelectAll: _onAllSelected,
                    columns: [
                      const DataColumn(label: Text('#')),
                      const DataColumn(label: Text('Name')),
                      const DataColumn(label: Text('Email')),
                      const DataColumn(label: Text('Missing Assignment')),
                      const DataColumn(label: Text('Status')),
                    ],
                    rows: List<DataRow>.generate(widget.students.length, (
                      index,
                    ) {
                      final student = widget.students[index];
                      final isSelected = _selectedIndices.contains(index);

                      Color? rowColor;

                      // Status Coloring Logic
                      final statusLower = student.status.toLowerCase();
                      if (statusLower.contains('sent')) {
                        rowColor = isDark
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.05);
                      } else if (statusLower.contains('done')) {
                        rowColor = isDark
                            ? Colors.green.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.05);
                      }

                      return DataRow(
                        selected: isSelected,
                        onSelectChanged: (val) => _onRowSelected(val, index),
                        color: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return theme.colorScheme.primary.withValues(
                              alpha: 0.12,
                            );
                          }
                          if (states.contains(WidgetState.hovered)) {
                            return theme.colorScheme.primary.withValues(
                              alpha: 0.04,
                            );
                          }
                          return rowColor;
                        }),
                        cells: [
                          DataCell(Text(student.rowNumber.toString())),
                          DataCell(
                            Text(
                              student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(Text(student.email)),
                          DataCell(
                            Text(
                              student.missingAssignmentName,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          DataCell(_buildStatusBadge(context, student.status)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0);
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    Color textColor;

    final statusLower = status.toLowerCase();
    if (statusLower.contains('sent')) {
      color = Colors.orange.withValues(alpha: 0.2);
      textColor = Colors.orange;
    } else if (statusLower.contains('done')) {
      color = Colors.green.withValues(alpha: 0.2);
      textColor = Colors.green;
    } else {
      color = Colors.grey.withValues(alpha: 0.2);
      textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.inter(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
