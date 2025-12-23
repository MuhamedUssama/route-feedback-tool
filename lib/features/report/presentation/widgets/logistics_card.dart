import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';

class LogisticsCard extends StatefulWidget {
  final GroupConfigModel group;

  const LogisticsCard({super.key, required this.group});

  @override
  State<LogisticsCard> createState() => _LogisticsCardState();
}

class _LogisticsCardState extends State<LogisticsCard> {
  late final TextEditingController _exceptionController;
  bool _isVisited = true;
  TimeOfDay? _arrivalTime;
  TimeOfDay? _departureTime;

  @override
  void initState() {
    super.initState();
    _exceptionController = TextEditingController();
  }

  @override
  void dispose() {
    _exceptionController.dispose();
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
            Text(
              '${widget.group.branchName ?? "Unknown Branch"} - ${widget.group.groupName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isVisited,
                  onChanged: (val) {
                    setState(() => _isVisited = val!);
                  },
                ),
                const Text('Visited this week?'),
              ],
            ),
            const SizedBox(height: 8),
            if (_isVisited)
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'Arrival',
                      _arrivalTime,
                      (t) => setState(() => _arrivalTime = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      context,
                      'Departure',
                      _departureTime,
                      (t) => setState(() => _departureTime = t),
                    ),
                  ),
                ],
              )
            else
              TextField(
                controller: _exceptionController,
                decoration: const InputDecoration(
                  labelText: 'Exception Reason',
                ),
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 300.ms);
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay? time,
    ValueChanged<TimeOfDay> onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final TimeOfDay? timeOfDay = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (timeOfDay != null) onChanged(timeOfDay);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time?.format(context) ?? 'Select Time'),
      ),
    );
  }
}
