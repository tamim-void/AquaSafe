import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Core Palette ── Arctic Blue ───────────────────────────────────────────
  static const Color iceWhite      = Color(0xFFF0F7FF);
  static const Color snowSurface   = Color(0xFFFFFFFF);
  static const Color frostCard     = Color(0xFFEBF3FD);
  static const Color frostCardMid  = Color(0xFFE0EDFC);
  static const Color frostCardDeep = Color(0xFFD0E4FA);
  static const Color glacierDeep   = Color(0xFF0A1F44);

  // ── Legacy aliases (keep other files compiling) ───────────────────────────
  static const Color deepVoid      = glacierDeep;
  static const Color darkBase      = iceWhite;
  static const Color nightCore     = snowSurface;
  static const Color cardDark      = frostCard;
  static const Color cardMid       = frostCardMid;
  static const Color surfaceLight  = frostCardDeep;
  static const Color elevated      = Color(0xFFD6E8FF);

  // ── Electric Blue Accents ─────────────────────────────────────────────────
  static const Color electricBlue  = Color(0xFF1A6EE6);
  static const Color skyBlue       = Color(0xFF60AEFF);
  static const Color deepBlue      = Color(0xFF0F52C4);
  static const Color iceBlue       = Color(0xFFD6EAFF);
  static const Color frostBlue     = Color(0xFFEBF4FF);

  // ── Legacy accent aliases ─────────────────────────────────────────────────
  static const Color neonCyan      = electricBlue;
  static const Color neonGreen     = electricBlue;
  static const Color aqua          = electricBlue;
  static const Color tealGlow      = skyBlue;
  static const Color mintGlow      = skyBlue;
  static const Color lavender      = Color(0xFF4A6FA5);
  static const Color pinkFlare     = Color(0xFFD92B2B);
  static const Color terminal      = skyBlue;
  static const Color greenDim      = skyBlue;
  static const Color greenTrace    = frostBlue;
  static const Color borderGlow    = Color(0x331A6EE6);

  // ── Status Colors ─────────────────────────────────────────────────────────
  static const Color safeGreen     = Color(0xFF00A86B);
  static const Color warnAmber     = Color(0xFFE07B00);
  static const Color dangerRed     = Color(0xFFD92B2B);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0A1F44);
  static const Color textSecondary = Color(0xFF4A6FA5);
  static const Color textMuted     = Color(0xFF8AABCE);
  static const Color textCode      = Color(0xFF1A6EE6);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color borderDim     = Color(0xFFC8DEFF);
  static const Color borderActive  = Color(0xFF1A6EE6);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, deepBlue],
  );

  static LinearGradient get accentGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricBlue, skyBlue],
  );

  static LinearGradient get bgGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [iceWhite, Color(0xFFE8F2FF)],
  );

  static LinearGradient get cardGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [snowSurface, frostCard],
  );

  static LinearGradient get glowGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x141A6EE6), Colors.transparent],
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get blueShadow => [
    BoxShadow(
      color: const Color(0x201A6EE6),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0x140A1F44),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Theme Data ────────────────────────────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: iceWhite,
        colorScheme: const ColorScheme.light(
          primary: electricBlue,
          secondary: skyBlue,
          surface: snowSurface,
          onPrimary: snowSurface,
          onSecondary: snowSurface,
          onSurface: textPrimary,
        ),

        // ── AppBar ──────────────────────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: snowSurface,
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
          ),
          iconTheme: const IconThemeData(color: electricBlue),
          actionsIconTheme: const IconThemeData(color: textSecondary),
        ),

        // ── Elevated Button ──────────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: electricBlue,
            foregroundColor: snowSurface,
            elevation: 0,
            padding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
        ),

        // ── Text Button ───────────────────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: electricBlue,
            textStyle: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ── Input Decoration ─────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: snowSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderDim, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: borderDim, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: electricBlue, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: dangerRed, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: dangerRed, width: 1.5),
          ),
          labelStyle:
              GoogleFonts.outfit(color: textSecondary, fontSize: 13),
          hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 13),
          suffixStyle:
              GoogleFonts.outfit(color: textMuted, fontSize: 12),
          prefixIconColor: textMuted,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),

        // ── Bottom Navigation ────────────────────────────────────────────
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: snowSurface,
          selectedItemColor: electricBlue,
          unselectedItemColor: textMuted,
          showUnselectedLabels: true,
          selectedLabelStyle: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.outfit(fontSize: 10),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // ── Dialog ───────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: snowSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: borderDim),
          ),
          titleTextStyle: GoogleFonts.outfit(
            color: textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: GoogleFonts.outfit(
            color: textSecondary,
            fontSize: 13,
          ),
        ),

        // ── SnackBar ─────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: glacierDeep,
          contentTextStyle: GoogleFonts.outfit(
            color: snowSurface,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Divider ──────────────────────────────────────────────────────
        dividerTheme: const DividerThemeData(
          color: borderDim,
          thickness: 1,
          space: 0,
        ),

        // ── Text Theme ───────────────────────────────────────────────────
        textTheme: TextTheme(
          displayLarge: GoogleFonts.outfit(
              color: textPrimary, fontWeight: FontWeight.w700),
          displayMedium: GoogleFonts.outfit(
              color: textPrimary, fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.outfit(
              color: textPrimary, fontWeight: FontWeight.w700),
          titleMedium: GoogleFonts.outfit(
              color: textPrimary, fontWeight: FontWeight.w600),
          bodyLarge:
              GoogleFonts.outfit(color: textSecondary, fontSize: 14),
          bodyMedium:
              GoogleFonts.outfit(color: textSecondary, fontSize: 13),
          bodySmall: GoogleFonts.outfit(color: textMuted, fontSize: 11),
          labelSmall: GoogleFonts.outfit(
              color: textMuted, fontSize: 10, letterSpacing: 1.5),
        ),
      );
}
