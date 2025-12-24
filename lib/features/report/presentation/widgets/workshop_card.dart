import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:mentor_assistant/features/report/data/models/weekly_report_model.dart';

class WorkshopCard extends StatefulWidget {
  final WorkshopInfoDto dto;
  const WorkshopCard({super.key, required this.dto});

  @override
  State<WorkshopCard> createState() => _WorkshopCardState();
}

class _WorkshopCardState extends State<WorkshopCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              initialValue: widget.dto.topic,
              decoration: const InputDecoration(
                labelText: 'Workshop Topic / Title',
                hintText: 'e.g., State Management, API Integration',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a topic';
                }
                return null;
              },
              onSaved: (value) => widget.dto.topic = value,
              onChanged: (value) => widget.dto.topic = value,
            ),
            const SizedBox(height: 16),
            FormField<DateTime>(
              initialValue: widget.dto.date,
              validator: (value) {
                if (value == null) {
                  return 'Please select a date';
                }
                return null;
              },
              onSaved: (value) => widget.dto.date = value,
              builder: (state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        state.value == null
                            ? 'Select Workshop Date'
                            : 'Date: ${DateFormat('dd-MM-yyyy').format(state.value!)}',
                      ),
                      leading: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: state.hasError ? Colors.red : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.value ?? DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2026),
                        );
                        if (picked != null) {
                          state.didChange(picked);
                          widget.dto.date = picked;
                        }
                      },
                    ),
                    if (state.hasError)
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 4),
                        child: Text(
                          state.errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms);
  }
}
