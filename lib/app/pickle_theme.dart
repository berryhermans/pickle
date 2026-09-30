import 'package:flutter/material.dart';

abstract final class PickleColors {
  static const forest = Color(0xFF164B37);
  static const leaf = Color(0xFF3D9364);
  static const lime = Color(0xFFD8F36A);
  static const paper = Color(0xFFF5F7EF);
}

final pickleTheme = ThemeData(
  colorScheme:
      ColorScheme.fromSeed(
        seedColor: PickleColors.leaf,
        brightness: Brightness.light,
      ).copyWith(
        primary: PickleColors.forest,
        secondary: PickleColors.leaf,
        tertiary: PickleColors.lime,
        surface: PickleColors.paper,
      ),
  scaffoldBackgroundColor: PickleColors.paper,
  appBarTheme: const AppBarTheme(
    backgroundColor: PickleColors.paper,
    foregroundColor: PickleColors.forest,
    elevation: 0,
    centerTitle: false,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  ),
  useMaterial3: true,
);
