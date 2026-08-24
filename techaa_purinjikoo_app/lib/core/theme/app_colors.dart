import 'package:flutter/material.dart';

class AppColors {
  // True Crimson Red Brand Colors
  static const Color primary = Color(0xFFE11D48); // True Crimson Red
  static const Color primaryAccent = Color(0xFFFF2E54); // Radiant Crimson Glow
  static const Color primaryContainer = Color(0xFF27050A); // Deep Crimson Obsidian
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFD9DD);

  // Status & Gamification Colors
  static const Color success = Color(0xFF10B981);
  static const Color xpViolet = Color(0xFFE11D48); // Harmonized Crimson
  static const Color streakOrange = Color(0xFFFF6B00);
  static const Color tertiary = Color(0xFFFF4D6D);
  static const Color tertiaryContainer = Color(0xFF3B0B13);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Pure AMOLED 0-Nit Black & Obsidian Surfaces
  static const Color background = Color(0xFF000000); // Pure 0-nit AMOLED Black
  static const Color onBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFF0A0A0E); // Deep Obsidian
  static const Color surfaceCard = Color(0xFF0F0F15); // Elevated Obsidian Card
  static const Color onSurface = Color(0xFFFFFFFF);
  static const Color onSurfaceVariant = Color(0xFFA1A1AA);

  // Surface Hierarchy
  static const Color surfaceContainerLowest = Color(0xFF050508);
  static const Color surfaceContainerLow = Color(0xFF0D0D12);
  static const Color surfaceContainer = Color(0xFF14141A);
  static const Color surfaceContainerHigh = Color(0xFF1A1A22);
  static const Color surfaceContainerHighest = Color(0xFF22222C);

  // Borders & Specular Accents
  static const Color borderMuted = Color(0xFF27272A);
  static const Color borderSubtle = Color(0xFF1A1A22);
  static const Color borderRed = Color(0x38E11D48); // Subtle Crimson Specular Rim
  static const Color outline = Color(0xFF3F3F46);
  static const Color outlineVariant = Color(0xFF27272A);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFFF2E54)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient xpGradient = LinearGradient(
    colors: [Color(0xFFE11D48), Color(0xFFFF6B00)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glowGradient = LinearGradient(
    colors: [Color(0x33E11D48), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1AE11D48), Colors.transparent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
