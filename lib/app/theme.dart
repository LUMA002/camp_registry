import 'package:flutter/material.dart';

class AppTheme {
  // Кольори
  static const Color primary = Color(0xFF06B6D4);
  static const Color secondary = Color(0xFFF59E0B);
  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);

  // Єдина тема для всього додатка
  static ThemeData get theme {
    return ThemeData(
      // Основна кольорова схема
      colorScheme: const ColorScheme.light(
        primary: primary,
        onPrimary: Colors.white,
        secondary: secondary,
        onSecondary: Colors.white,
        surface: surface,
        onSurface: textDark,
        error: error,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: background,

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
          size: 26,
        ),
      ),

      // Кнопки
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 3,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primary,
          iconSize: 26,
        ),
      ),

      // Поля вводу
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(
          color: textDark.withValues(alpha: 0.7),
          fontSize: 16,
        ),
        floatingLabelStyle: const TextStyle(
          color: primary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textLight.withValues(alpha: 0.3), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: error, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hoverColor: textLight.withValues(alpha: 0.1),
        errorStyle: const TextStyle(
          color: error,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(8),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(
          color: textDark,
          fontSize: 16,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(surface),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
      ),

      // Дайлоги
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(
          color: textDark,
          fontSize: 16,
        ),
      ),

      // DatePicker
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        headerBackgroundColor: primary,
        headerForegroundColor: Colors.white,
        headerHeadlineStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headerHelpStyle: const TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        dayStyle: const TextStyle(fontSize: 16),
        yearStyle: const TextStyle(fontSize: 16),
        todayForegroundColor: WidgetStateProperty.all(primary),
        todayBackgroundColor: WidgetStateProperty.all(primary.withValues(alpha: 0.15)),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primary;
          }
          return null;
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),

      // // Dropdown
      // popupMenuTheme: PopupMenuThemeData(
      //   color: surface,
      //   elevation: 8,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      //   textStyle: const TextStyle(
      //     color: textDark,
      //     fontSize: 16,
      //   ),
      // ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        tileColor: surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        subtitleTextStyle: TextStyle(
          color: textLight,
          fontSize: 14,
        ),
        iconColor: primary,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: textLight.withValues(alpha: 0.2),
        thickness: 1.5,
        space: 1.5,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark.withValues(alpha: 0.9),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Текст
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textDark,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textDark,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: textDark, fontSize: 18),
        bodyMedium: TextStyle(color: textLight, fontSize: 16),
      ),
    );
  }
}