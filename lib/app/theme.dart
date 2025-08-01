import 'package:flutter/material.dart';

class AppTheme {
  // Кольори
  static const Color primary = Color(0xFF06B6D4); 
  static const Color secondary = Color(0xFFF59E0B); 
  static const Color background = Color(0xFFF8FAFC); 
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1E293B); 
  static const Color textLight = Color(0xFF64748B); 
  static const Color error = Color(0xFFF87171); 
  //static const Color success = Color(0xFF34D399); 

  // Єдина тема для всього додатка
  static ThemeData get theme {
    return ThemeData(
      // Основна кольорова схема
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        onSurface: background,
        surface: surface,
      ),

      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Поля вводу
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: error, width: 2.5),
        ),
        contentPadding: const EdgeInsets.all(16),
        hoverColor: Colors.grey.shade100,
      ),

      // Картки
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      // Текст
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textDark, fontSize: 16),
        bodyMedium: TextStyle(color: textLight, fontSize: 14),
      ),
    );
  }
}
