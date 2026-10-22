import 'package:flutter/material.dart';

/// Clears any stuck SnackBars and displays a clean, auto-dismissing SnackBar
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
      backgroundColor: backgroundColor ?? const Color(0xFF1B4D3E),
      behavior: SnackBarBehavior.floating,
      content: Text(
        formatBidi(message),
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
