import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
import 'page_background.dart';
import 'tables.dart';

export 'page_background.dart';
export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Subjects, PdfFiles, Notebooks, Pages, Strokes, Tapes])
class MarginDatabase extends _$MarginDatabase {
  MarginDatabase(super.executor);

  /// The on-device database file.
  MarginDatabase.open() : super(driftDatabase(name: 'margin'));

  // Bump on every schema change, then run `dart run drift_dev make-migrations`.
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
