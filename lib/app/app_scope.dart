import 'package:flutter/widgets.dart';

import '../db/database.dart';
import '../diagnostics/diagnostics.dart';

/// App-wide services, created once in main() (or by a test).
class AppServices {
  AppServices({required this.db, required this.diagnostics});

  final MarginDatabase db;
  final Diagnostics diagnostics;
}

class AppScope extends InheritedWidget {
  const AppScope({super.key, required this.services, required super.child});

  final AppServices services;

  static AppServices of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.services;

  @override
  bool updateShouldNotify(AppScope oldWidget) => oldWidget.services != services;
}
