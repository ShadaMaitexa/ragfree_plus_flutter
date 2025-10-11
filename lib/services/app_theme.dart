import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme() {
    const seed = Colors.indigo;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData darkTheme() {
    const seed = Colors.indigo;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
    );
  }
}
