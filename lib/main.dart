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
      title: 'Tafaddal Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B4D3E),
          primary: const Color(0xFF1B4D3E),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F7F5),
      ),
      home: const MainNavigationScreen(),
    );
  }
}
