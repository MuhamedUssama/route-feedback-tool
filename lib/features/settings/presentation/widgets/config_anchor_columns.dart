import 'package:flutter/material.dart';

class ConfigAnchorColumns extends StatelessWidget {
  final TextEditingController assignmentEmailColController;
  final TextEditingController followUpEmailColController;

  const ConfigAnchorColumns({
    super.key,
    required this.assignmentEmailColController,
    required this.followUpEmailColController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: assignmentEmailColController,
                decoration: const InputDecoration(
                  labelText: 'Assignment Email Column',
                  hintText: 'e.g. C',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Letters only';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: followUpEmailColController,
                decoration: const InputDecoration(
                  labelText: 'Follow-up Email Column',
                  hintText: 'e.g. D',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                    return 'Letters only';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
