import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';

void main() {
  late MarginDatabase db;
  final now = DateTime.utc(2026, 10, 26, 9, 30, 15, 123);

  setUp(() {
    db = MarginDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertNotebookWithPage({String? pdfFileId}) async {
    await db
        .into(db.subjects)
        .insert(
          SubjectsCompanion.insert(
            id: 's1',
            name: 'Biology',
            color: 0xFF2E7D32,
            sortOrder: 0,
          ),
        );
    await db
        .into(db.notebooks)
        .insert(
          NotebooksCompanion.insert(
            id: 'n1',
            subjectId: const Value('s1'),
            title: 'Cell structure',
            kind: pdfFileId == null ? NotebookKind.notes : NotebookKind.pdf,
            pdfFileId: Value(pdfFileId),
            pageIds: ['p1'],
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.pages)
        .insert(
          PagesCompanion.insert(
            id: 'p1',
            notebookId: 'n1',
            width: 612,
            height: 792,
            background: const TemplateBackground(PaperTemplate.lined),
          ),
        );
  }

  test('subjects round-trip', () async {
    await insertNotebookWithPage();
    final subject = await db.select(db.subjects).getSingle();
    expect(subject.name, 'Biology');
    expect(subject.color, 0xFF2E7D32);
    expect(subject.sortOrder, 0);
  });

  test('pdf files round-trip and sha256 is unique', () async {
    final file = PdfFilesCompanion.insert(
      id: 'f1',
      path: '/data/pdfs/f1.pdf',
      pageCount: 200,
      sha256: 'abc123',
    );
    await db.into(db.pdfFiles).insert(file);
    final row = await db.select(db.pdfFiles).getSingle();
    expect(row.pageCount, 200);
    expect(row.path, '/data/pdfs/f1.pdf');

    await expectLater(
      db.into(db.pdfFiles).insert(file.copyWith(id: const Value('f2'))),
      throwsA(isA<SqliteException>()),
    );
  });

  test('notebooks round-trip page order and millisecond timestamps', () async {
    await db
        .into(db.pdfFiles)
        .insert(
          PdfFilesCompanion.insert(
            id: 'f1',
            path: '/data/pdfs/f1.pdf',
            pageCount: 3,
            sha256: 'abc123',
          ),
        );
    await insertNotebookWithPage(pdfFileId: 'f1');
    await (db.update(db.notebooks)..where((n) => n.id.equals('n1'))).write(
      const NotebooksCompanion(pageIds: Value(['p3', 'p1', 'p2'])),
    );

    final notebook = await db.select(db.notebooks).getSingle();
    expect(notebook.pageIds, ['p3', 'p1', 'p2']);
    expect(notebook.kind, NotebookKind.pdf);
    expect(notebook.pdfFileId, 'f1');
    expect(notebook.subjectId, 's1');
    expect(notebook.createdAt, now);
    expect(notebook.updatedAt.millisecond, 123);
  });

  test('pages round-trip both background kinds', () async {
    await insertNotebookWithPage();
    await db
        .into(db.pages)
        .insert(
          PagesCompanion.insert(
            id: 'p2',
            notebookId: 'n1',
            width: 595,
            height: 842,
            background: const PdfBackground(4),
          ),
        );

    final pages = await (db.select(
      db.pages,
    )..orderBy([(p) => OrderingTerm.asc(p.id)])).get();
    expect(pages[0].background, const TemplateBackground(PaperTemplate.lined));
    expect(pages[1].background, const PdfBackground(4));
    expect(pages[1].width, 595);
  });

  test('strokes round-trip points and bounding box', () async {
    await insertNotebookWithPage();
    final points = Float32List.fromList([10, 20, 0.5, 11.25, 21.5, 0.75]);
    await db
        .into(db.strokes)
        .insert(
          StrokesCompanion.insert(
            id: 'k1',
            pageId: 'p1',
            tool: StrokeTool.highlighter,
            color: 0x80FFEB3B,
            size: 12,
            points: points,
            minX: 10,
            minY: 20,
            maxX: 11.25,
            maxY: 21.5,
            createdAt: now,
          ),
        );

    final stroke = await db.select(db.strokes).getSingle();
    expect(stroke.points, points);
    expect(stroke.tool, StrokeTool.highlighter);
    expect(stroke.color, 0x80FFEB3B);
    expect(
      [stroke.minX, stroke.minY, stroke.maxX, stroke.maxY],
      [10, 20, 11.25, 21.5],
    );
    expect(stroke.createdAt, now);
  });

  test('tapes round-trip with defaults and study fields', () async {
    await insertNotebookWithPage();
    final points = Float32List.fromList([50, 60, 0.5, 150, 60, 0.5]);
    await db
        .into(db.tapes)
        .insert(
          TapesCompanion.insert(
            id: 't1',
            pageId: 'p1',
            points: points,
            width: 18,
            minX: 41,
            minY: 51,
            maxX: 159,
            maxY: 69,
            createdAt: now,
          ),
        );

    var tape = await db.select(db.tapes).getSingle();
    expect(tape.points, points);
    expect(tape.hidden, isTrue);
    expect(tape.style, 'solid');
    expect(tape.studyLastResult, isNull);
    expect(tape.studyDueAt, isNull);

    await db
        .update(db.tapes)
        .write(
          TapesCompanion(
            hidden: const Value(false),
            studyLastResult: const Value(StudyResult.missed),
            studyDueAt: Value(now.add(const Duration(days: 1))),
          ),
        );
    tape = await db.select(db.tapes).getSingle();
    expect(tape.hidden, isFalse);
    expect(tape.studyLastResult, StudyResult.missed);
    expect(tape.studyDueAt, now.add(const Duration(days: 1)));
  });

  test('deleting a notebook removes its pages, strokes and tapes', () async {
    await insertNotebookWithPage();
    final points = Float32List.fromList([0, 0, 0.5]);
    await db
        .into(db.strokes)
        .insert(
          StrokesCompanion.insert(
            id: 'k1',
            pageId: 'p1',
            tool: StrokeTool.pen,
            color: 0xFF000000,
            size: 2,
            points: points,
            minX: 0,
            minY: 0,
            maxX: 0,
            maxY: 0,
            createdAt: now,
          ),
        );
    await db
        .into(db.tapes)
        .insert(
          TapesCompanion.insert(
            id: 't1',
            pageId: 'p1',
            points: points,
            width: 18,
            minX: 0,
            minY: 0,
            maxX: 0,
            maxY: 0,
            createdAt: now,
          ),
        );

    await (db.delete(db.notebooks)..where((n) => n.id.equals('n1'))).go();

    expect(await db.select(db.pages).get(), isEmpty);
    expect(await db.select(db.strokes).get(), isEmpty);
    expect(await db.select(db.tapes).get(), isEmpty);
    expect(await db.select(db.subjects).get(), hasLength(1));
  });
}
