import 'package:flutter/material.dart';

/// Matches the web app: near-black ground, white text, blue for actions, green and red for
/// money that is or is not there.
abstract final class SpendableColors {
  static const background = Color(0xFF0B0E14);
  static const surface = Color(0xFF141922);
  static const accent = Color(0xFF60A5FA);
  static const positive = Color(0xFF4ADE80);
  static const negative = Color(0xFFF87171);
  static const muted = Color(0xFF9CA3AF);
}

ThemeData spendableTheme() {
  final base = ThemeData.dark(useMaterial3: true);

  return base.copyWith(
    scaffoldBackgroundColor: SpendableColors.background,
    colorScheme: base.colorScheme.copyWith(
      surface: SpendableColors.surface,
      primary: SpendableColors.accent,
      error: SpendableColors.negative,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SpendableColors.background,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
    ),
    dividerTheme: const DividerThemeData(color: Colors.white12, space: 1, thickness: 1),
  );
}
