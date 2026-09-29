import 'package:flutter/material.dart';

const accent = Color(0xFFE6B975);
ThemeData get appTheme => ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF0C0D10),
  colorScheme: const ColorScheme.dark(
    primary: accent,
    secondary: accent,
    surface: Color(0xFF181A20),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0C0D10),
    surfaceTintColor: Colors.transparent,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF101115),
    indicatorColor: Color(0xFF302A21),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: accent,
      foregroundColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1A1C22),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  ),
);
