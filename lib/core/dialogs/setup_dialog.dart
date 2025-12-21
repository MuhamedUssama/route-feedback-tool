import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentor_assistant/core/dialogs/base_dialog_container.dart';

class SetupDialog extends StatefulWidget {
  final Function(String assignmentSheetId, String followUpSheetId) onSave;

  const SetupDialog({super.key, required this.onSave});

  @override
  State<SetupDialog> createState() => _SetupDialogState();
}

class _SetupDialogState extends State<SetupDialog> {
  final _assignmentController = TextEditingController();
  final _followUpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _assignmentController.dispose();
    _followUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseDialogContainer(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              'System Initialization',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please enter your Google Sheet URLs (Links) to connect the assistant.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Fields
            TextFormField(
              controller: _assignmentController,
              decoration: const InputDecoration(
                labelText: 'Assignment Sheet URL',
                prefixIcon: Icon(Icons.link),
                hintText: 'e.g., https://docs.google.com/spreadsheets/d/...',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _followUpController,
              decoration: const InputDecoration(
                labelText: 'Follow-Up Sheet URL',
                prefixIcon: Icon(Icons.link),
                hintText: 'e.g., https://docs.google.com/spreadsheets/d/...',
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 48),

            // Action Button
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  widget.onSave(
                    _assignmentController.text.trim(),
                    _followUpController.text.trim(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              child: Text(
                'SAVE & INITIALIZE',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
