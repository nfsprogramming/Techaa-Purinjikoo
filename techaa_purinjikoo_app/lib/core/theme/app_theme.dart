import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.xpViolet,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        displaySmall: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        labelSmall: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05, color: AppColors.onSurfaceVariant),
      ).apply(
        bodyColor: AppColors.onSurface,
        displayColor: AppColors.onSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.borderMuted, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get cyberpunkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF10B981), // Matrix Green
        onPrimary: Colors.black,
        secondary: Color(0xFF38BDF8),
        surface: Color(0xFF000000), // Pitch Black
        onSurface: Color(0xFF10B981), // Green Text
        surfaceContainerLowest: Color(0xFF000000),
        surfaceContainerLow: Color(0xFF021008),
        surfaceContainer: Color(0xFF042010),
        surfaceContainerHigh: Color(0xFF063018),
        surfaceContainerHighest: Color(0xFF084020),
        outline: Color(0xFF10B981),
        outlineVariant: Color(0xFF055A38),
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      fontFamily: GoogleFonts.firaCode().fontFamily, // Hacker font
      textTheme: TextTheme(
        displayLarge: GoogleFonts.firaCode(fontSize: 32, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
        displayMedium: GoogleFonts.firaCode(fontSize: 26, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
        displaySmall: GoogleFonts.firaCode(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFF10B981)),
        bodyLarge: GoogleFonts.firaCode(fontSize: 18, fontWeight: FontWeight.w400, color: const Color(0xFF10B981)),
        bodyMedium: GoogleFonts.firaCode(fontSize: 16, fontWeight: FontWeight.w400, color: const Color(0xFF10B981)),
        labelSmall: GoogleFonts.firaCode(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.05, color: const Color(0xFF10B981)),
      ).apply(
        bodyColor: const Color(0xFF10B981),
        displayColor: const Color(0xFF10B981),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF000000),
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF021008),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Sharp edges
          side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Sharp edges
          ),
          textStyle: GoogleFonts.firaCode(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
