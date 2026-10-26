import 'package:flutter/material.dart';

import '../ui/theme.dart';
import 'app_scope.dart';
import 'library_screen.dart';

class MarginApp extends StatelessWidget {
  const MarginApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      services: services,
      child: MaterialApp(
        title: 'Margin',
        debugShowCheckedModeBanner: false,
        theme: buildMarginTheme(),
        home: const LibraryScreen(),
      ),
    );
  }
}
