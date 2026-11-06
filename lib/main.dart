import 'package:flutter/material.dart';

import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/theme/app_theme.dart';

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
      theme: AtelierTheme.theme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const MainNavigationScreen(),
    );
  }
}
