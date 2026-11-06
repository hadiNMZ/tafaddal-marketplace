import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../presentation/theme/app_theme.dart';

/// Clears any stuck SnackBars and displays a clean, auto-dismissing luxury SnackBar
void showCleanSnackBar(
  BuildContext context,
  String message, {
  Color? backgroundColor,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      backgroundColor: backgroundColor ?? AtelierColors.primary,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AtelierColors.gold.withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      content: Text(
        formatBidi(message),
        textDirection: TextDirection.rtl,
        style: GoogleFonts.tajawal(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1.4,
        ),
      ),
      action: action,
    ),
  );
}

/// Wraps embedded English text blocks, codes, or alphanumeric tokens with LTR unicode marks (\u200E)
/// so that sentence structure in Arabic RTL remains aligned without word scrambling.
String formatBidi(String text) {
  return text.replaceAllMapped(
    RegExp(r'([A-Za-z0-9_\-#]+(\s+[A-Za-z0-9_\-#]+)*)'),
    (match) => '\u200E${match.group(1)}\u200E',
  );
}
