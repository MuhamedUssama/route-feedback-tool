import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_stat_chip.dart';
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';

class GroupReportCard extends StatefulWidget {
  final GroupConfigEntity group;
  final GroupReportDto dto;
  final Map<String, int>? stats;
  final bool isCalculating;
  final Function(String assignCol, String followUpCol) onCalculateStats;

  const GroupReportCard({
    super.key,
    required this.group,
    required this.dto,
    this.stats,
    this.isCalculating = false,
    required this.onCalculateStats,
  });

  @override
  State<GroupReportCard> createState() => _GroupReportCardState();
}

class _GroupReportCardState extends State<GroupReportCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${widget.group.groupName} - ${widget.group.branchName ?? 'Online'}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // 2. Assignment Details (Row 1)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.dto.assignmentNumber,
                    decoration: const InputDecoration(
                      labelText: 'Assignment No.',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => widget.dto.assignmentNumber = val,
                    onChanged: (val) => widget.dto.assignmentNumber = val,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: widget.dto.assignmentName,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Name',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (val) => widget.dto.assignmentName = val,
                    onChanged: (val) => widget.dto.assignmentName = val,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 3. Deadline Picker
            FormField<DateTime>(
              initialValue: widget.dto.deadline,
              onSaved: (val) => widget.dto.deadline = val,
              validator: (val) => val == null ? 'Required' : null,
              builder: (state) {
                return InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    border: const OutlineInputBorder(),
                    errorText: state.errorText,
                  ),
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.value ?? DateTime.now(),
                        firstDate: DateTime(2023),
                        lastDate: DateTime(2026),
                      );
                      if (picked != null) {
                        state.didChange(picked);
                        widget.dto.deadline = picked;
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.value == null
                              ? 'Select Deadline'
                              : DateFormat('yyyy-MM-dd').format(state.value!),
                        ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // 4. Columns (Row 2)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.dto.assignmentColumn,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Column',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., H',
                    ),
                    onSaved: (val) => widget.dto.assignmentColumn = val,
                    onChanged: (val) => widget.dto.assignmentColumn = val,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.dto.followUpColumn,
                    decoration: const InputDecoration(
                      labelText: 'Follow-Up Column',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., D',
                    ),
                    onSaved: (val) => widget.dto.followUpColumn = val,
                    onChanged: (val) => widget.dto.followUpColumn = val,
                    validator: (val) =>
                        (val == null || val.isEmpty) ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 5. Stats & Feedback Switch
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.isCalculating
                        ? null
                        : () {
                            if (widget.dto.assignmentColumn != null &&
                                widget.dto.followUpColumn != null) {
                              widget.onCalculateStats(
                                widget.dto.assignmentColumn!,
                                widget.dto.followUpColumn!,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter column names'),
                                ),
                              );
                            }
                          },
                    icon: widget.isCalculating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.calculate),
                    label: const Text('Calculate Stats'),
                  ),
                ),
                const SizedBox(width: 24),
                Row(
                  spacing: 8,
                  children: [
                    const Text('Feedback Done?'),
                    Switch(
                      value: widget.dto.feedbackDone,
                      onChanged: (val) {
                        setState(() {
                          widget.dto.feedbackDone = val;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Stats Display
            if (widget.stats != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ReportStatChip(
                    label: 'Submitted',
                    value: widget.stats!['submitted']!,
                    color: Colors.green,
                  ),
                  ReportStatChip(
                    label: 'Missing',
                    value: widget.stats!['unsubmitted']!,
                    color: Colors.orange,
                  ),
                  ReportStatChip(
                    label: 'Followed Up',
                    value: widget.stats!['followUp']!,
                    color: Colors.blue,
                  ),
                ],
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 100.ms);
  }
}
