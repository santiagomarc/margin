import 'package:flutter/material.dart';

/// Margin's palette: paper-first, with one ink-blue accent.
abstract final class MarginColors {
  static const ink = Color(0xFF2B4C7E);
  static const paper = Color(0xFFFFFFFF);
  static const desk = Color(0xFFF4F2EE);
  static const sidebar = Color(0xFFEAE6DF);
  static const divider = Color(0xFFD9D4CB);
  static const textMuted = Color(0xFF6B675F);
}

ThemeData buildMarginTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: MarginColors.ink,
    primary: MarginColors.ink,
    surface: MarginColors.desk,
  );
  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: MarginColors.desk,
    dividerColor: MarginColors.divider,
    // No splash ripples: cheaper to draw on slow GPUs and calmer to look at.
    splashFactory: NoSplash.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: MarginColors.desk,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
