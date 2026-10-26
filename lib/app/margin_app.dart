import 'package:flutter/material.dart';

import '../ui/theme.dart';
import 'library_screen.dart';

class MarginApp extends StatelessWidget {
  const MarginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Margin',
      debugShowCheckedModeBanner: false,
      theme: buildMarginTheme(),
      home: const LibraryScreen(),
    );
  }
}
