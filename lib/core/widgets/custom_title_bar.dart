import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class CustomTitleBar extends StatelessWidget {
  const CustomTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine title bar height based on platform
    final double titleBarHeight = Platform.isMacOS ? 38.0 : 32.0;
    final isWindows = Platform.isWindows;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        height: titleBarHeight,
        color:
            Theme.of(context).navigationRailTheme.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        child: isWindows
            ? _buildWindowsLayout(context)
            : _buildMacOSLayout(context),
      ),
    );
  }

  Widget _buildMacOSLayout(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Drag Area covering the whole bar (except where native controls might be, though on macOS they are drawn by OS)
        const Positioned.fill(child: DragToMoveArea(child: SizedBox())),
        // Centered Title
        IgnorePointer(
          child: Text(
            "Route Mentor Assistant",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWindowsLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DragToMoveArea(
            child: Row(
              children: [
                const SizedBox(width: 16),
                // App Logo
                Image.asset(
                  'assets/images/logo.png',
                  height: 16,
                  width: 16,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.apps, size: 16),
                ),
                const SizedBox(width: 12),
                // Left Aligned Title
                Text(
                  "Route Mentor Assistant",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ],
            ),
          ),
        ),
        const WindowButtons(),
      ],
    );
  }
}

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> with WindowListener {
  bool _isMaximized = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _initIsMaximized();
  }

  void _initIsMaximized() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {
      _isMaximized = true;
    });
  }

  @override
  void onWindowUnmaximize() {
    setState(() {
      _isMaximized = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Row(
      children: [
        _WindowButton(
          icon: Icons.remove,
          onPressed: windowManager.minimize,
          iconColor: iconColor,
        ),
        _WindowButton(
          icon: _isMaximized
              ? Icons.filter_none
              : Icons.check_box_outline_blank,
          onPressed: () async {
            if (_isMaximized) {
              windowManager.unmaximize();
            } else {
              windowManager.maximize();
            }
          },
          iconColor: iconColor,
          iconSize: _isMaximized ? 14 : 16,
        ),
        _WindowButton(
          icon: Icons.close,
          onPressed: windowManager.close,
          iconColor: iconColor,
          isCloseButton: true,
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final bool isCloseButton;
  final double iconSize;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    required this.iconColor,
    this.isCloseButton = false,
    this.iconSize = 16,
  });

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final hoverColor = widget.isCloseButton
        ? const Color(0xFFC42B1C)
        : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.1));

    final iconColor = _isHovering && widget.isCloseButton
        ? Colors.white
        : widget.iconColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          width: 46,
          height: 32,
          color: _isHovering ? hoverColor : Colors.transparent,
          alignment: Alignment.center,
          child: Icon(widget.icon, size: widget.iconSize, color: iconColor),
        ),
      ),
    );
  }
}
