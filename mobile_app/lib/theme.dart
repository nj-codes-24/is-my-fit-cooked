import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF111111);
  static const Color surface = Color(0xFF1C1C1E);
  static const Color glassBackground = Color(0xBF141414); // rgba(20,20,20,0.75)
  static const Color glassBorder = Color(0x1AFFFFFF); // rgba(255,255,255,0.1)
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: Colors.white,
      textTheme: ThemeData.dark().textTheme.copyWith(
        displayLarge: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500),
        displayMedium: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500),
        displaySmall: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500),
        headlineMedium: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500),
        titleLarge: const TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white38,
      ),
      useMaterial3: true,
    );
  }

  static BoxDecoration glassDecoration = BoxDecoration(
    color: glassBackground,
    borderRadius: BorderRadius.circular(32),
    border: Border.all(color: glassBorder),
    boxShadow: const [
      BoxShadow(
        color: Colors.black45,
        blurRadius: 40,
        offset: Offset(0, 16),
      )
    ],
  );
}
