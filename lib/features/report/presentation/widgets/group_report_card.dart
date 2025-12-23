import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/features/report/presentation/widgets/report_stat_chip.dart';

class GroupReportCard extends StatefulWidget {
  final GroupConfigModel group;
  final Map<String, int>? stats;
  final bool isCalculating;
  final Function(String assignCol, String followUpCol) onCalculateStats;

  const GroupReportCard({
    super.key,
    required this.group,
    this.stats,
    this.isCalculating = false,
    required this.onCalculateStats,
  });

  @override
  State<GroupReportCard> createState() => _GroupReportCardState();
}

class _GroupReportCardState extends State<GroupReportCard> {
  // Controllers
  late final TextEditingController _assignNameController;
  late final TextEditingController _assignNumberController;
  late final TextEditingController _assignColController;
  late final TextEditingController _followUpColController;

  // Local State
  DateTime? _deadline;
  bool _feedbackDone = false;

  @override
  void initState() {
    super.initState();
    _assignNameController = TextEditingController();
    _assignNumberController = TextEditingController();
    _assignColController = TextEditingController();
    _followUpColController = TextEditingController();
  }

  @override
  void dispose() {
    _assignNameController.dispose();
    _assignNumberController.dispose();
    _assignColController.dispose();
    _followUpColController.dispose();
    super.dispose();
  }

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
                    widget.group.groupName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text('Feedback Done?'),
                const SizedBox(width: 8),
                Switch(
                  value: _feedbackDone,
                  onChanged: (val) {
                    setState(() {
                      _feedbackDone = val;
                      // Logic for when feedback is marked done
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Assignment Details Inputs
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _assignNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment No.',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Deadline',
                      isDense: true,
                      suffixIcon: IconButton(
                        tooltip: 'Select Deadline Date',
                        icon: const Icon(Icons.calendar_today, size: 16),
                        onPressed: () async {
                          final now = DateTime.now();
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _deadline ?? now,
                            firstDate: now.subtract(const Duration(days: 30)),
                            lastDate: now.add(const Duration(days: 60)),
                          );
                          if (date != null) {
                            setState(() => _deadline = date);
                          }
                        },
                      ),
                    ),
                    child: Text(
                      _deadline != null
                          ? DateFormat('dd/MM/yyyy').format(_deadline!)
                          : 'Select Deadline Date',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _assignNameController,
              decoration: const InputDecoration(
                labelText: 'Assignment Name',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Automation Inputs
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _assignColController,
                    decoration: const InputDecoration(
                      labelText: 'Assignment Column (ex. H)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _followUpColController,
                    decoration: const InputDecoration(
                      labelText: 'Follow-Up Column (ex. K)',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: widget.isCalculating
                      ? null
                      : () {
                          final assignCol = _assignColController.text.trim();
                          final fupCol = _followUpColController.text.trim();

                          if (assignCol.isEmpty || fupCol.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter both columns'),
                              ),
                            );
                            return;
                          }

                          widget.onCalculateStats(assignCol, fupCol);
                        },
                  icon: widget.isCalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.analytics,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  tooltip: 'Calculate Stats',
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
