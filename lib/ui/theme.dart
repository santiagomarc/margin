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

/// Subject colours: muted enough to sit next to paper, distinct as dots.
abstract final class SubjectColors {
  static const all = [
    0xFF2E7D32, // green
    0xFF1F5FBF, // blue
    0xFFC62828, // red
    0xFF6A1B9A, // purple
    0xFFEF6C00, // orange
    0xFF00838F, // teal
    0xFFAD1457, // pink
    0xFF5D4037, // brown
  ];

  static const _names = [
    'Green',
    'Blue',
    'Red',
    'Purple',
    'Orange',
    'Teal',
    'Pink',
    'Brown',
  ];

  static String nameOf(int color) {
    final i = all.indexOf(color);
    return i < 0 ? 'Colour' : _names[i];
  }
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
    // Flat: no elevation anywhere.
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      width: 420,
    ),
    popupMenuTheme: const PopupMenuThemeData(
      elevation: 1,
      color: MarginColors.paper,
      surfaceTintColor: Colors.transparent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: MarginColors.desk,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
  );
}
