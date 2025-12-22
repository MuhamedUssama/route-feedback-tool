import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mentor_assistant/core/constants/app_constants.dart';

// ignore: must_be_immutable
class ConfigGeneralInfoCard extends StatefulWidget {
  final TextEditingController cycleNumberController;
  String? selectedTrack;

  ConfigGeneralInfoCard({
    super.key,
    required this.cycleNumberController,
    required this.selectedTrack,
  });

  @override
  State<ConfigGeneralInfoCard> createState() => _ConfigGeneralInfoCardState();
}

class _ConfigGeneralInfoCardState extends State<ConfigGeneralInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.cycleNumberController,
                decoration: const InputDecoration(
                  labelText: 'Cycle Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: widget.selectedTrack,
                decoration: const InputDecoration(
                  labelText: 'Track',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.kTracks
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => widget.selectedTrack = val),
                validator: (value) => value == null ? 'Required' : null,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideX();
  }
}
