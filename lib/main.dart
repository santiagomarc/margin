import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'app/app_scope.dart';
import 'app/margin_app.dart';
import 'db/database.dart';
import 'diagnostics/app_log.dart';
import 'diagnostics/diagnostics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final log = AppLog()..install();
  final diagnostics = Diagnostics(log: log)..start();
  // The database opens lazily on its own isolate; nothing heavy runs before
  // the first frame.
  final services = AppServices(
    db: MarginDatabase.open(),
    diagnostics: diagnostics,
  );
  runApp(MarginApp(services: services));
  unawaited(
    getApplicationSupportDirectory()
        .then(log.persistErrorsIn)
        .catchError((Object error) => log.add('Error log unavailable: $error')),
  );
}
