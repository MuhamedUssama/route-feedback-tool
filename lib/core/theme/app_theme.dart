import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  // Private Colors
  static const Color _primary = Color(0xFF006D77); // Deep Teal
  static const Color _secondary = Color(0xFF83C5BE); // Lighter Teal
  static const Color _surfaceLight = Color(0xFFF8FAFC); // Off-white
  static const Color _surfaceDark = Color(0xFF1b1d1e); // Dark Slate
  // static const Color _cardDark = Color(0xFF242626);
  static const Color _cardDark = Color(0xFF1b1d1e);

  static const Color _scaffoldDark = Color(0xFF121212);

  // Semantic Colors
  static const Color _success = Color(0xFF10B981);
  static const Color _error = Color(0xFFEF4444);
  static const Color _warning = Color(0xFFF59E0B);

  // Text Colors
  static const Color _textPrimaryLight = Color(0xFF1E293B);
  static const Color _textSecondaryLight = Color(0xFF64748B);
  static const Color _textPrimaryDark = Color(0xFFF1F5F9);
  static const Color _textSecondaryDark = Color(0xFF94A3B8);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? _scaffoldDark : _surfaceLight;
    final primaryText = isDark ? _textPrimaryDark : _textPrimaryLight;
    final secondaryText = isDark ? _textSecondaryDark : _textSecondaryLight;
    final disabledBackgroundColor = isDark ? _surfaceDark : Colors.grey[600];
    final disabledForegroundColor = isDark
        ? Colors.grey[600]
        : Colors.grey[300];

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: baseColor,
      disabledColor: disabledBackgroundColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primary,
        brightness: brightness,
        primary: _primary,
        secondary: _secondary,
        error: _error,
        surface: baseColor,
        tertiary: _success,
        tertiaryContainer: _warning,
        onPrimary: _textPrimaryDark,
      ),
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: baseColor,
        foregroundColor: primaryText,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        iconTheme: IconThemeData(color: primaryText),
        actionsIconTheme: IconThemeData(color: primaryText),
        titleTextStyle: GoogleFonts.outfit(
          color: primaryText,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),

      // Typography
      textTheme: TextTheme(
        displayLarge: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.poppins(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: GoogleFonts.inter(color: primaryText),
        bodyMedium: GoogleFonts.inter(color: primaryText),
        bodySmall: GoogleFonts.inter(color: secondaryText),
        labelLarge: GoogleFonts.inter(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.inter(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
        labelSmall: GoogleFonts.inter(
          color: primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? _cardDark : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[700]!),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledBackgroundColor;
            }
            return _primary;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return disabledForegroundColor;
            }
            return Colors.white;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.2);
            }
            return null;
          }),
          elevation: WidgetStateProperty.all(2),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.0,
            ),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return isDark ? Colors.grey[600] : Colors.grey[500];
            }
            return _primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return _primary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.pressed)) {
              return _primary.withValues(alpha: 0.2);
            }
            return null;
          }),
          elevation: WidgetStateProperty.all(2),
          side: WidgetStateProperty.all(BorderSide(color: _primary, width: 1)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          textStyle: WidgetStateProperty.all(
            GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 1.0,
            ),
          ),
          minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: _textPrimaryDark,
        elevation: 8,
        extendedPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            return _primary;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return _primary.withValues(alpha: 0.08);
            }
            return null;
          }),
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? _cardDark : Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(0),
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[700] : Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.inter(color: Colors.white, fontSize: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // Scrollbar
      scrollbarTheme: ScrollbarThemeData(
        thumbVisibility: WidgetStateProperty.all(true),
        thickness: WidgetStateProperty.all(8),
        radius: const Radius.circular(8),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.dragged)) {
            return isDark ? Colors.grey[500] : Colors.grey[400];
          }
          if (states.contains(WidgetState.hovered)) {
            return isDark ? Colors.grey[600] : Colors.grey[400];
          }
          return isDark ? Colors.grey[700] : Colors.grey[300];
        }),
      ),

      // NavigationRail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark ? _surfaceDark : _surfaceLight,
        elevation: 0,
        indicatorColor: _secondary.withValues(alpha: isDark ? 0.2 : 0.3),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        groupAlignment: -0.9, // Align to top
        labelType: NavigationRailLabelType.all,

        // Icons
        selectedIconTheme: IconThemeData(
          color: isDark ? _secondary : _primary,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(color: secondaryText, size: 24),

        // Labels
        selectedLabelTextStyle: GoogleFonts.outfit(
          color: isDark ? _secondary : _primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
        unselectedLabelTextStyle: GoogleFonts.outfit(
          color: secondaryText,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),

      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: isDark
            ? _cardDark
            : Colors.grey[300]?.withValues(alpha: 0.7),
        collapsedBackgroundColor: isDark
            ? _cardDark
            : Colors.grey[300]?.withValues(alpha: 0.7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        expansionAnimationStyle: AnimationStyle(
          curve: Curves.easeInOut,
          duration: const Duration(milliseconds: 200),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey[800] : Colors.grey[400],
        thickness: 1,
        space: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? _textPrimaryDark : _textPrimaryLight,
        contentTextStyle: GoogleFonts.inter(
          color: isDark ? _textPrimaryLight : _textPrimaryDark,
        ),
        width: 400,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Platform Density
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
