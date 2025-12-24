import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/features/settings/data/models/group_config_model.dart';
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';

class LogisticsCard extends StatefulWidget {
  final GroupConfigModel group;
  final LogisticsInfoDto dto;

  const LogisticsCard({super.key, required this.group, required this.dto});

  @override
  State<LogisticsCard> createState() => _LogisticsCardState();
}

class _LogisticsCardState extends State<LogisticsCard> {
  late bool _isVisited;
  TimeOfDay? _arrivalTime;
  TimeOfDay? _leavingTime;

  @override
  void initState() {
    super.initState();
    _isVisited = widget.dto.visited;
    _arrivalTime = widget.dto.arrivalTime;
    _leavingTime = widget.dto.leavingTime;
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
                    widget.dto.visited = val!;
                  },
                ),
                const SizedBox(width: 8),
                const Text('Visited this week?'),
              ],
            ),
            const SizedBox(height: 8),
            if (_isVisited)
              Row(
                children: [
                  Expanded(
                    child: FormField<TimeOfDay>(
                      initialValue: _arrivalTime,
                      onSaved: (val) => widget.dto.arrivalTime = val,
                      validator: (val) {
                        if (_isVisited && val == null) {
                          return 'Required';
                        }
                        return null;
                      },
                      builder: (state) {
                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: _arrivalTime ?? TimeOfDay.now(),
                            );
                            if (timeOfDay != null) {
                              setState(() => _arrivalTime = timeOfDay);
                              state.didChange(timeOfDay);
                              widget.dto.arrivalTime = timeOfDay;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Arrival',
                              border: const OutlineInputBorder(),
                              errorText: state.errorText,
                            ),
                            child: Text(
                              _arrivalTime?.format(context) ?? '--:--',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FormField<TimeOfDay>(
                      initialValue: _leavingTime,
                      onSaved: (val) => widget.dto.leavingTime = val,
                      validator: (val) {
                        if (_isVisited && val == null) {
                          return 'Required';
                        }
                        return null;
                      },
                      builder: (state) {
                        return InkWell(
                          onTap: () async {
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: _leavingTime ?? TimeOfDay.now(),
                            );
                            if (timeOfDay != null) {
                              setState(() => _leavingTime = timeOfDay);
                              state.didChange(timeOfDay);
                              widget.dto.leavingTime = timeOfDay;
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Departure',
                              border: const OutlineInputBorder(),
                              errorText: state.errorText,
                            ),
                            child: Text(
                              _leavingTime?.format(context) ?? '--:--',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            else
              TextFormField(
                initialValue: widget.dto.exceptionReason,
                decoration: const InputDecoration(
                  labelText: 'Exception Reason',
                ),
                onSaved: (val) => widget.dto.exceptionReason = val,
                onChanged: (val) => widget.dto.exceptionReason = val,
                validator: (val) {
                  if (!_isVisited && (val == null || val.isEmpty)) {
                    return 'Reason required';
                  }
                  return null;
                },
              ).animate().fadeIn(),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 300.ms);
  }
}
