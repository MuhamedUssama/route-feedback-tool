import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

class WorkshopCard extends StatefulWidget {
  const WorkshopCard({super.key});

  @override
  State<WorkshopCard> createState() => _WorkshopCardState();
}

class _WorkshopCardState extends State<WorkshopCard> {
  late final TextEditingController _topicController;
  DateTime? _workshopDate;

  @override
  void initState() {
    super.initState();
    _topicController = TextEditingController();
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _topicController,
              decoration: const InputDecoration(labelText: 'Workshop Topic'),
            ),
            const SizedBox(height: 12),
            InputDecorator(
              decoration: InputDecoration(
                labelText: 'Date',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _workshopDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _workshopDate = date);
                    }
                  },
                ),
              ),
              child: Text(
                _workshopDate == null
                    ? 'Select Workshop Date'
                    : DateFormat('dd/MM/yyyy').format(_workshopDate!),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0, delay: 200.ms);
  }
}
