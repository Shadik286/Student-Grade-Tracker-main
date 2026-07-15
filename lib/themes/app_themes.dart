import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0F766E),       // Teal 700
      secondary: Color(0xFF14B8A6),     // Teal 500
      tertiary: Color(0xFFF59E0B),      // Amber for accents
      surface: Color(0xFFFFFFFF),
      error: Color(0xFFDC2626),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFFFFFFFF),
      onSurface: Color(0xFF0F172A),
      onError: Color(0xFFFFFFFF),
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0F766E),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFFFF),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFF475569)),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFFFFFFFF),
      selectedItemColor: Color(0xFF0F766E),
      unselectedItemColor: Color(0xFF94A3B8),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFF0F172A), fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFF0F172A), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFF334155), fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE2E8F0),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF0F766E),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0F766E),
      contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF2DD4BF),       // Teal 400
      secondary: Color(0xFF14B8A6),
      tertiary: Color(0xFFFBBF24),
      surface: Color(0xFF1E293B),
      error: Color(0xFFF87171),
      onPrimary: Color(0xFF0F172A),
      onSecondary: Color(0xFF0F172A),
      onSurface: Color(0xFFF1F5F9),
      onError: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF134E4A),
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFFFFFFF),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1E293B),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF334155)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2DD4BF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF87171), width: 2),
      ),
      labelStyle: const TextStyle(color: Color(0xFFCBD5E1)),
      hintStyle: const TextStyle(color: Color(0xFF64748B)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2DD4BF),
        foregroundColor: const Color(0xFF0F172A),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1E293B),
      selectedItemColor: Color(0xFF2DD4BF),
      unselectedItemColor: Color(0xFF64748B),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: Color(0xFFF1F5F9), fontSize: 28, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: Color(0xFFF1F5F9), fontSize: 22, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: Color(0xFFF1F5F9), fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: Color(0xFFF1F5F9), fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: Color(0xFFF1F5F9), fontSize: 16),
      bodyMedium: TextStyle(color: Color(0xFFCBD5E1), fontSize: 14),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF334155),
      thickness: 1,
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF2DD4BF),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF134E4A),
      contentTextStyle: const TextStyle(color: Color(0xFFF1F5F9)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

