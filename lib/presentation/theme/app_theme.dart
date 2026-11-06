import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Atelier Luxury Design System for Tafaddal Marketplace (تفضّل)
/// Inspired by high-end Middle Eastern fashion houses & luxury European ateliers.
class AtelierColors {
  AtelierColors._();

  // Canvas & Surfaces
  static const Color bg = Color(0xFFFBF9F5); // Warm Alabaster Silk
  static const Color surface = Color(0xFFFFFFFF); // Pure Porcelain
  static const Color surfaceElevated = Color(0xFFF6F3EC); // Warm Linen
  static const Color surfaceSubtle = Color(0xFFF0EBE1); // Soft Cashmere

  // Primary Brand Identity (Imperial Emerald)
  static const Color primary = Color(0xFF132E27); // Deep Imperial Emerald
  static const Color primaryLight = Color(0xFF1D473B); // Forest Velvet
  static const Color primaryTint = Color(0xFFEEF5F2); // Soft Emerald Mist
  static const Color primaryBorder = Color(0xFFD2E3DB); // Delicate Sage Border

  // Noble Accents (Champagne Gold & Bronze)
  static const Color gold = Color(0xFFB89358); // Antique Champagne Gold
  static const Color goldLight = Color(0xFFD6B582); // Gilded Shimmer
  static const Color goldDark = Color(0xFF8F6D35); // Burnished Bronze
  static const Color goldTint = Color(0xFFFAF5EC); // Warm Silk Gold
  static const Color goldBorder = Color(0xFFEBDDC5); // Fine Gold Hairline

  // Typography & Inks
  static const Color textPrimary = Color(0xFF191817); // Deep Onyx Ink
  static const Color textSecondary = Color(0xFF6E685F); // Warm Slate
  static const Color textMuted = Color(0xFF9E978C); // Desert Sand Muted
  static const Color textLight = Color(0xFFB8B2A7); // Subtle Whispering Grey

  // Borders & Dividers
  static const Color border = Color(0xFFEAE3D6); // Warm Cashmere Line
  static const Color borderSubtle = Color(0xFFF2ECE1); // Soft Micro-Stroke

  // Semantic Status Shades (Luxury Muted Tones)
  static const Color success = Color(0xFF1B5E43); // Verified Sage Emerald
  static const Color successBg = Color(0xFFEDF7F2); // Soft Mint Silk
  static const Color successBorder = Color(0xFFCCE7DA);

  static const Color warning = Color(0xFF966318); // Warm Amber Ochre
  static const Color warningBg = Color(0xFFFDF6EB); // Soft Sand Apricot
  static const Color warningBorder = Color(0xFFF4E2C5);

  static const Color error = Color(0xFF8D2525); // Velvety Crimson
  static const Color errorBg = Color(0xFFFCF1F1); // Soft Blush Silk
  static const Color errorBorder = Color(0xFFF5D3D3);

  static const Color info = Color(0xFF234B73); // Royal Sapphire
  static const Color infoBg = Color(0xFFF0F5FA);
  static const Color infoBorder = Color(0xFFD0E1F0);
}

class AtelierTheme {
  AtelierTheme._();

  static ThemeData get theme {
    final tajawalFamily = GoogleFonts.tajawal().fontFamily;

    return ThemeData(
      useMaterial3: true,
      fontFamily: tajawalFamily,
      fontFamilyFallback: const ['Tajawal', 'Cairo', 'Almarai', 'sans-serif'],
      scaffoldBackgroundColor: AtelierColors.bg,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AtelierColors.primary,
        onPrimary: Colors.white,
        secondary: AtelierColors.gold,
        onSecondary: Colors.white,
        error: AtelierColors.error,
        onError: Colors.white,
        surface: AtelierColors.surface,
        onSurface: AtelierColors.textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.tajawal(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AtelierColors.textPrimary,
          height: 1.3,
        ),
        displayMedium: GoogleFonts.tajawal(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: AtelierColors.textPrimary,
          height: 1.35,
        ),
        titleLarge: GoogleFonts.tajawal(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AtelierColors.textPrimary,
          height: 1.4,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AtelierColors.textPrimary,
          height: 1.4,
        ),
        titleSmall: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AtelierColors.textPrimary,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AtelierColors.textPrimary,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AtelierColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.tajawal(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AtelierColors.textMuted,
          height: 1.4,
        ),
        labelLarge: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.3,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AtelierColors.bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AtelierColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AtelierColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AtelierColors.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AtelierColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AtelierColors.primary,
        contentTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AtelierColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AtelierColors.textPrimary,
          side: const BorderSide(color: AtelierColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Luxury soft ambient shadow
  static List<BoxShadow> get subtleShadow => [
    BoxShadow(
      color: const Color(0xFF17130E).withValues(alpha: 0.035),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  /// Elevated card shadow
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: const Color(0xFF17130E).withValues(alpha: 0.055),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];
}
