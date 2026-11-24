import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF17324D);
  static const red = Color(0xFFD94A4A);
  static const surface = Color(0xFFF7F9FC);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: red,
      surface: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: navy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE0E6ED)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
