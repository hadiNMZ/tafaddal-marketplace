import 'package:flutter/material.dart';

import 'presentation/screens/main_navigation_screen.dart';

void main() {
  runApp(const TafaddalApp());
}

class TafaddalApp extends StatelessWidget {
  const TafaddalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tafaddal Marketplace - تفضّل',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          primary: const Color(0xFF1B4D3E),
          secondary: const Color(0xFF047857),
          surface: const Color(0xFFF9F9F8),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9F9F8),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF9F9F8),
          elevation: 0,
          centerTitle: true,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
