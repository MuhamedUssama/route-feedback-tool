import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mentor_assistant/core/dialogs/base_dialog_container.dart';

enum MessengerType { success, error, info }

class MessengerDialog extends StatelessWidget {
  final String title;
  final String message;
  final MessengerType type;
  final String buttonText;
  final VoidCallback? onDismiss;

  const MessengerDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = MessengerType.info,
    this.buttonText = 'OKAY',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color iconColor;
    IconData iconData;

    switch (type) {
      case MessengerType.success:
        iconColor = Colors.greenAccent[400]!;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case MessengerType.error:
        iconColor = theme.colorScheme.error;
        iconData = Icons.error_outline_rounded;
        break;
      case MessengerType.info:
        iconColor = theme.colorScheme.primary;
        iconData = Icons.info_outline;
        break;
    }

    return BaseDialogContainer(
      width: 400,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 64, color: iconColor),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDismiss ?? () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor.withValues(alpha: 0.1),
                foregroundColor: iconColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: iconColor.withValues(alpha: 0.5)),
                ),
                elevation: 0,
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
