import 'package:drift/native.dart';
import 'package:margin/app/app_scope.dart';
import 'package:margin/db/database.dart';
import 'package:margin/diagnostics/diagnostics.dart';

/// App services backed by an in-memory database.
AppServices testServices() => AppServices(
  db: MarginDatabase(NativeDatabase.memory()),
  diagnostics: Diagnostics(),
);
