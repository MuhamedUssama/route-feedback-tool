import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class FollowUpActionButtons extends StatelessWidget {
  final VoidCallback onCheckAssignments;
  final VoidCallback onCheckReplies;

  const FollowUpActionButtons({
    super.key,
    required this.onCheckAssignments,
    required this.onCheckReplies,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
      child:
          Row(
                children: [
                  // Check Assignments Button
                  Expanded(
                    child: _ActionCard(
                      title: 'Check Assignments',
                      icon: Icons.sync_problem_rounded,
                      color: theme.colorScheme.primary,
                      onTap: onCheckAssignments,
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Check Replies Button
                  Expanded(
                    child: _ActionCard(
                      title: 'Check Replies',
                      icon: Icons.mark_email_unread_rounded,
                      color: theme.colorScheme.secondary,
                      onTap: onCheckReplies,
                      isPrimary: false,
                    ),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 600.ms, curve: Curves.easeOut)
              .slideY(begin: 0.2, end: 0, curve: Curves.easeOutBack),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isPrimary,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dynamic styling based on hover and primary status
    final backgroundColor = widget.isPrimary
        ? widget.color.withValues(alpha: _isHovered ? 1.0 : 0.85)
        : theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: _isHovered ? 1.0 : 0.6,
          );

    final foregroundColor = widget.isPrimary
        ? theme.colorScheme.onPrimary
        : _isHovered
        ? widget.color
        : theme.colorScheme.onSurfaceVariant;

    final border = widget.isPrimary
        ? null
        : Border.all(
            color: _isHovered ? widget.color : theme.colorScheme.outlineVariant,
            width: _isHovered ? 2 : 1.5,
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 200.ms,
          curve: Curves.easeOutCubic,
          height: 64,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: border,
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: foregroundColor, size: 26)
                  .animate(target: _isHovered ? 1 : 0)
                  .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1))
                  .rotate(begin: 0, end: 0.05),

              const SizedBox(width: 12),

              Text(
                widget.title.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
