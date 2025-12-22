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
                    validator: (value) => value == null || value.isEmpty
                        ? 'Cycle number is required'
                        : null,
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
                        .map(
                          (track) => DropdownMenuItem(
                            value: track,
                            child: Text(track),
                          ),
                        )
                        .toList(),
                    onChanged: (track) {
                      setState(() => widget.selectedTrack = track);
                    },
                    validator: (value) =>
                        value == null ? 'Select a track' : null,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 600.ms, curve: Curves.easeOutQuad)
        .slideY(
          begin: 0.1,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutQuad,
        );
  }
}
