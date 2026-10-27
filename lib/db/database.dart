import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'converters.dart';
import 'database.steps.dart';
import 'page_background.dart';
import 'tables.dart';

export 'page_background.dart';
export 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [Subjects, PdfFiles, Notebooks, Pages, Strokes, Tapes, Settings],
)
class MarginDatabase extends _$MarginDatabase {
  MarginDatabase(super.executor);

  /// The on-device database file.
  MarginDatabase.open() : super(driftDatabase(name: 'margin'));

  // Bump on every schema change, then run `dart run drift_dev make-migrations`.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        await m.addColumn(schema.notebooks, schema.notebooks.lastPageId);
        await m.addColumn(schema.notebooks, schema.notebooks.lastZoom);
        await m.createTable(schema.settings);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
