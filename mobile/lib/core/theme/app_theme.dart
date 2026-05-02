import 'package:flutter/material.dart';

const _bg = Color(0xFF0A0A0A);
const _surface = Color(0xFF111111);
const neonGreen = Color(0xFF00FF88);
const neonCyan = Color(0xFF00FFFF);
const neonPink = Color(0xFFFF0066);
const neonYellow = Color(0xFFFFFF00);
const dimGray = Color(0xFF333333);

final appTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _bg,
  colorScheme: const ColorScheme.dark(
    surface: _surface,
    primary: neonGreen,
    secondary: neonCyan,
    error: neonPink,
  ),
  fontFamily: 'monospace',
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: neonGreen, fontFamily: 'monospace'),
    bodySmall: TextStyle(color: neonCyan, fontFamily: 'monospace'),
    titleLarge: TextStyle(color: neonGreen, fontFamily: 'monospace', fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _bg,
    foregroundColor: neonGreen,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: neonGreen,
      fontFamily: 'monospace',
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _surface,
      foregroundColor: neonGreen,
      side: const BorderSide(color: neonGreen),
      textStyle: const TextStyle(fontFamily: 'monospace'),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: _surface,
    border: OutlineInputBorder(borderSide: BorderSide(color: dimGray)),
    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: dimGray)),
    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: neonGreen)),
    labelStyle: TextStyle(color: neonGreen, fontFamily: 'monospace'),
    hintStyle: TextStyle(color: dimGray, fontFamily: 'monospace'),
  ),
);
