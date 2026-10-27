// dart format width=80
import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // Every upgrade path must produce exactly the schema of the target
    // version (checked against the dumps in drift_schemas/).
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = MarginDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('v1 to v2 keeps every row and defaults the new columns', () async {
    final points = Uint8List.fromList(
      Float32List.fromList([10, 20, 0.5, 40, 25, 0.6]).buffer.asUint8List(),
    );
    const subject = v1.SubjectsData(
      id: 's1',
      name: 'Biology',
      color: 0xFF2E7D32,
      sortOrder: 0,
    );
    const pdf = v1.PdfFilesData(
      id: 'f1',
      path: '/data/f1.pdf',
      pageCount: 3,
      sha256: 'abc',
    );
    const notebook = v1.NotebooksData(
      id: 'n1',
      subjectId: 's1',
      title: 'Cell structure',
      kind: 'notes',
      pageIds: '["p1","p2"]',
      createdAt: 1761470000000,
      updatedAt: 1761480000000,
    );
    const pages = [
      v1.PagesData(
        id: 'p1',
        notebookId: 'n1',
        width: 595.28,
        height: 841.89,
        background: '{"type":"template","template":"lined"}',
      ),
      v1.PagesData(
        id: 'p2',
        notebookId: 'n1',
        width: 595.28,
        height: 841.89,
        background: '{"type":"template","template":"grid"}',
      ),
    ];
    final stroke = v1.StrokesData(
      id: 'st1',
      pageId: 'p1',
      tool: 'pen',
      color: 0xFF1F2328,
      size: 2.5,
      points: points,
      minX: 7.5,
      minY: 17.5,
      maxX: 42.5,
      maxY: 27.5,
      createdAt: 1761470001000,
    );
    final tape = v1.TapesData(
      id: 't1',
      pageId: 'p2',
      points: points,
      width: 24,
      style: 'solid',
      hidden: 1,
      minX: 0,
      minY: 0,
      maxX: 50,
      maxY: 40,
      createdAt: 1761470002000,
    );

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: MarginDatabase.new,
      createItems: (batch, oldDb) {
        batch.insert(oldDb.subjects, subject);
        batch.insert(oldDb.pdfFiles, pdf);
        batch.insert(oldDb.notebooks, notebook);
        batch.insertAll(oldDb.pages, pages);
        batch.insert(oldDb.strokes, stroke);
        batch.insert(oldDb.tapes, tape);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.subjects).get(), [
          const v2.SubjectsData(
            id: 's1',
            name: 'Biology',
            color: 0xFF2E7D32,
            sortOrder: 0,
          ),
        ]);
        expect(await newDb.select(newDb.pdfFiles).get(), [
          const v2.PdfFilesData(
            id: 'f1',
            path: '/data/f1.pdf',
            pageCount: 3,
            sha256: 'abc',
          ),
        ]);
        expect(await newDb.select(newDb.notebooks).get(), [
          const v2.NotebooksData(
            id: 'n1',
            subjectId: 's1',
            title: 'Cell structure',
            kind: 'notes',
            pageIds: '["p1","p2"]',
            createdAt: 1761470000000,
            updatedAt: 1761480000000,
            lastPageId: null,
            lastZoom: 1.0,
          ),
        ]);
        final newPages = await newDb.select(newDb.pages).get();
        expect(newPages.map((p) => (p.id, p.background)), [
          ('p1', pages[0].background),
          ('p2', pages[1].background),
        ]);
        final newStroke = await newDb.select(newDb.strokes).getSingle();
        expect(newStroke.points, points);
        expect(newStroke.createdAt, stroke.createdAt);
        final newTape = await newDb.select(newDb.tapes).getSingle();
        expect(newTape.hidden, 1);
        expect(newTape.points, points);
        expect(await newDb.select(newDb.settings).get(), isEmpty);
      },
    );
  });

  test('a migrated v1 database works through the app schema', () async {
    final schema = await verifier.schemaAt(1);
    final old = v1.DatabaseAtV1(schema.newConnection());
    await old
        .into(old.notebooks)
        .insert(
          const v1.NotebooksData(
            id: 'scratch',
            title: 'Scratch page',
            kind: 'notes',
            pageIds: '["scratch-page-1"]',
            createdAt: 1761470000000,
            updatedAt: 1761470000000,
          ),
        );
    await old.close();

    final db = MarginDatabase(schema.newConnection());
    final notebook = await db.select(db.notebooks).getSingle();
    expect(notebook.title, 'Scratch page');
    expect(notebook.pageIds, ['scratch-page-1']);
    expect(notebook.lastPageId, isNull);
    expect(notebook.lastZoom, 1.0);

    await (db.update(db.notebooks)..where((n) => n.id.equals('scratch'))).write(
      const NotebooksCompanion(lastPageId: Value('scratch-page-1')),
    );
    await db
        .into(db.settings)
        .insert(SettingsCompanion.insert(key: 'library.sort', value: 'title'));
    expect(
      (await db.select(db.notebooks).getSingle()).lastPageId,
      'scratch-page-1',
    );
    expect((await db.select(db.settings).getSingle()).value, 'title');
    await db.close();
  });
}
