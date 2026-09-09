import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/features/settings/domain/entities/group_config_entity.dart';
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';

class LogisticsCard extends StatefulWidget {
  final GroupConfigEntity group;
  final LogisticsInfoDto dto;

  const LogisticsCard({super.key, required this.group, required this.dto});

  @override
  State<LogisticsCard> createState() => _LogisticsCardState();
}

class _LogisticsCardState extends State<LogisticsCard> {
  late bool _isVisited;
  DateTime? _visitDate;
  TimeOfDay? _arrivalTime;
  TimeOfDay? _leavingTime;

  @override
  void initState() {
    super.initState();
    _isVisited = widget.dto.visited;
    _visitDate = widget.dto.visitDate;
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isVisited,
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() => _isVisited = val);
                    widget.dto.visited = val;
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Visited this week?',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isVisited)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 650;

                  final dateField = FormField<DateTime>(
                    initialValue: _visitDate,
                    onSaved: (val) => widget.dto.visitDate = val,
                    validator: (val) {
                      if (_isVisited && val == null) {
                        return 'Date required';
                      }
                      return null;
                    },
                    builder: (state) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _visitDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 365),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 30),
                            ),
                          );
                          if (pickedDate != null) {
                            setState(() => _visitDate = pickedDate);
                            state.didChange(pickedDate);
                            widget.dto.visitDate = pickedDate;
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Visit Date',
                            border: const OutlineInputBorder(),
                            prefixIcon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                            ),
                            errorText: state.errorText,
                          ),
                          child: Text(
                            _visitDate != null
                                ? DateFormat(
                                    'EEE, MMM d, yyyy',
                                  ).format(_visitDate!)
                                : 'Select Date',
                            style: TextStyle(
                              color: _visitDate != null
                                  ? Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color
                                  : Theme.of(context).hintColor,
                            ),
                          ),
                        ),
                      );
                    },
                  );

                  final arrivalField = FormField<TimeOfDay>(
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
                            prefixIcon: const Icon(
                              Icons.access_time_rounded,
                              size: 20,
                            ),
                            errorText: state.errorText,
                          ),
                          child: Text(_arrivalTime?.format(context) ?? '--:--'),
                        ),
                      );
                    },
                  );

                  final departureField = FormField<TimeOfDay>(
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
                        borderRadius: BorderRadius.circular(12),
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
                            prefixIcon: const Icon(
                              Icons.schedule_rounded,
                              size: 20,
                            ),
                            errorText: state.errorText,
                          ),
                          child: Text(_leavingTime?.format(context) ?? '--:--'),
                        ),
                      );
                    },
                  );

                  if (isCompact) {
                    return Column(
                      children: [
                        dateField,
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: arrivalField),
                            const SizedBox(width: 12),
                            Expanded(child: departureField),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(flex: 4, child: dateField),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: arrivalField),
                      const SizedBox(width: 12),
                      Expanded(flex: 3, child: departureField),
                    ],
                  );
                },
              ).animate().fadeIn()
            else
              TextFormField(
                initialValue: widget.dto.exceptionReason,
                decoration: const InputDecoration(
                  labelText: 'Exception Reason',
                  hintText: 'e.g., National holiday, online shift...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info_outline_rounded),
                ),
                onSaved: (val) => widget.dto.exceptionReason = val,
                onChanged: (val) => widget.dto.exceptionReason = val,
                validator: (val) {
                  if (!_isVisited && (val == null || val.trim().isEmpty)) {
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
