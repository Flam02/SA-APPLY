
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Color Palette ──────────────────────────────────────────────────────────
  static const Color primaryDeep  = Color(0xFF0D1B2A); // Deep navy
  static const Color primaryMid   = Color(0xFF1B2E45); // Mid navy
  static const Color primaryLight = Color(0xFF2A4466); // Light navy
  static const Color accentGold   = Color(0xFFE8A020); // Warm gold
  static const Color accentTeal   = Color(0xFF00B4D8); // Bright teal
  static const Color successGreen = Color(0xFF2DC653); // Success
  static const Color errorRed     = Color(0xFFE63946); // Error
  static const Color warningAmber = Color(0xFFFB8500); // Warning
  static const Color surfaceLight = Color(0xFFF8F9FB); // Light surface
  static const Color cardBorder   = Color(0xFFE2E8F0); // Card border
  static const Color textPrimary  = Color(0xFF0D1B2A); // Dark text
  static const Color textSecondary= Color(0xFF64748B); // Muted text

  // ─── Light Theme ────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDeep,
        brightness: Brightness.light,
        primary: primaryDeep,
        secondary: accentGold,
        tertiary: accentTeal,
        surface: surfaceLight,
        error: errorRed,
      ),
      scaffoldBackgroundColor: surfaceLight,
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryDeep,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          color: Colors.white,
          letterSpacing: 0.3,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: accentGold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDeep,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDeep,
          side: const BorderSide(color: primaryDeep, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDeep, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: GoogleFonts.dmSans(color: textSecondary, fontSize: 14),
        // ignore: deprecated_member_use
        hintStyle: GoogleFonts.dmSans(color: textSecondary.withOpacity(0.6), fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryDeep,
        labelStyle: GoogleFonts.dmSans(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(
        color: cardBorder,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: primaryDeep,
        contentTextStyle: GoogleFonts.dmSans(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Dark Theme ─────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDeep,
        brightness: Brightness.dark,
        primary: accentGold,
        secondary: accentTeal,
        surface: const Color(0xFF111827),
        error: errorRed,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: _buildTextTheme(Brightness.dark),
    );
  }

  // ─── Text Theme ─────────────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color base = isDark ? Colors.white : textPrimary;

    return TextTheme(
      displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 48, color: base, letterSpacing: -0.5),
      displayMedium: GoogleFonts.dmSerifDisplay(fontSize: 36, color: base),
      displaySmall: GoogleFonts.dmSerifDisplay(fontSize: 28, color: base),
      headlineLarge: GoogleFonts.dmSerifDisplay(fontSize: 24, color: base),
      headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 20, color: base),
      headlineSmall: GoogleFonts.dmSerifDisplay(fontSize: 18, color: base),
      titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: base),
      titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: base),
      titleSmall: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: base),
      bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: base),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: base),
      bodySmall: GoogleFonts.dmSans(fontSize: 12, color: isDark ? Colors.white54 : textSecondary),
      labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
  }
}
