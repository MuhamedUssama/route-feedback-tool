import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../presentation/cubits/follow_up_action/follow_up_action_cubit.dart';

class FollowUpActionFooter extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onSendPressed;

  const FollowUpActionFooter({
    super.key,
    required this.selectedCount,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color:
                theme.dividerTheme.color ?? Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BlocBuilder<FollowUpActionCubit, FollowUpActionState>(
        builder: (context, state) {
          return AnimatedSwitcher(
            duration: 300.ms,
            child: state.maybeWhen(
              sendingProgress: (total, current, failedEmails) {
                final progress = total > 0 ? current / total : 0.0;
                return _buildProgressIndicator(
                  context,
                  current: current,
                  total: total,
                  progress: progress,
                );
              },
              orElse: () => _buildSendButton(context),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = selectedCount > 0;

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEnabled)
            Text(
              '$selectedCount students selected',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ).animate().fadeIn().slideX(begin: 0.2, end: 0),
          const SizedBox(width: 24),
          ElevatedButton.icon(
            onPressed: isEnabled ? onSendPressed : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 56), // Override infinite width
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: isEnabled ? 4 : 0,
              disabledBackgroundColor: theme.disabledColor,
              disabledForegroundColor: Colors.grey[600],
            ),
            icon: const Icon(Icons.send_rounded, size: 20),
            label: Text(
              'SEND FOLLOW-UP EMAILS',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context, {
    required int current,
    required int total,
    required double progress,
  }) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sending emails...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                '$current / $total',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
