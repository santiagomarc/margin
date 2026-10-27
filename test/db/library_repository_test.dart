import 'dart:typed_data';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/library_repository.dart';
import 'package:margin/db/settings_repository.dart';

void main() {
  late MarginDatabase db;
  late LibraryRepository repo;
  var now = DateTime.utc(2026, 10, 27, 9);

  setUp(() {
    db = MarginDatabase(NativeDatabase.memory());
    repo = LibraryRepository(db, now: () => now);
  });

  tearDown(() => db.close());

  Future<void> addStroke(String pageId, String id) {
    return db
        .into(db.strokes)
        .insert(
          StrokesCompanion.insert(
            id: id,
            pageId: pageId,
            tool: StrokeTool.pen,
            color: 0xFF1F2328,
            size: 2.5,
            points: Float32List.fromList([1, 2, 0.5]),
            minX: 0,
            minY: 0,
            maxX: 3,
            maxY: 4,
            createdAt: DateTime.utc(2026, 10, 27, 9, 0, 1),
          ),
        );
  }

  group('subjects', () {
    test('create in order, rename and recolour', () async {
      final bio = await repo.createSubject('  Biology ', 0xFF2E7D32);
      final history = await repo.createSubject('History', 0xFF1F5FBF);
      expect(bio.name, 'Biology');
      expect(history.sortOrder, bio.sortOrder + 1);

      await repo.renameSubject(bio.id, 'Cell biology');
      await repo.recolorSubject(history.id, 0xFFC62828);
      final subjects = await repo.subjects();
      expect(subjects.map((s) => s.name), ['Cell biology', 'History']);
      expect(subjects.last.color, 0xFFC62828);
    });

    test('delete keeps its notebooks, and restore puts them back', () async {
      final bio = await repo.createSubject('Biology', 0xFF2E7D32);
      final a = await repo.createNotebook(title: 'A', subjectId: bio.id);
      final b = await repo.createNotebook(title: 'B', subjectId: bio.id);
      final c = await repo.createNotebook(title: 'C');

      final deletion = await repo.deleteSubject(bio.id);
      expect(deletion.notebookIds, unorderedEquals([a.id, b.id]));
      expect(await repo.subjects(), isEmpty);
      final notebooks = await repo.notebooks();
      expect(notebooks, hasLength(3));
      expect(notebooks.every((n) => n.notebook.subjectId == null), isTrue);

      await repo.restoreSubject(deletion);
      expect((await repo.subjects()).single.name, 'Biology');
      final restored = {
        for (final n in await repo.notebooks()) n.id: n.notebook.subjectId,
      };
      expect(restored, {a.id: bio.id, b.id: bio.id, c.id: null});
    });
  });

  group('notebooks', () {
    test('create makes one page of the chosen paper', () async {
      final notebook = await repo.createNotebook(
        title: 'Cell structure',
        template: PaperTemplate.grid,
      );
      expect(notebook.kind, NotebookKind.notes);
      expect(notebook.createdAt, now);
      final summary = (await repo.notebooks()).single;
      expect(summary.pageCount, 1);
      expect(summary.firstPage!.id, notebook.pageIds.single);
      expect(
        summary.firstPage!.background,
        const TemplateBackground(PaperTemplate.grid),
      );
      expect(summary.firstPage!.width, PageSizes.a4.width);
    });

    test('rename marks it edited; move does not', () async {
      final notebook = await repo.createNotebook(title: 'Draft');
      final bio = await repo.createSubject('Biology', 0xFF2E7D32);
      now = DateTime.utc(2026, 10, 28, 9);
      await repo.renameNotebook(notebook.id, 'Final');
      var row = (await repo.notebooks()).single.notebook;
      expect(row.title, 'Final');
      expect(row.updatedAt, now);

      now = DateTime.utc(2026, 10, 29, 9);
      await repo.moveNotebook(notebook.id, bio.id);
      row = (await repo.notebooks()).single.notebook;
      expect(row.subjectId, bio.id);
      expect(row.updatedAt, DateTime.utc(2026, 10, 28, 9));

      await repo.moveNotebook(notebook.id, null);
      expect((await repo.notebooks()).single.notebook.subjectId, isNull);
    });

    test('duplicate copies pages and strokes with new ids', () async {
      final source = await repo.createNotebook(title: 'Original');
      final pageId = source.pageIds.single;
      await addStroke(pageId, 's1');
      await addStroke(pageId, 's2');
      await (db.update(db.notebooks)..where((n) => n.id.equals(source.id)))
          .write(NotebooksCompanion(lastPageId: Value(pageId)));

      final copy = await repo.duplicateNotebook(
        source.id,
        title: 'Original copy',
      );
      expect(copy.id, isNot(source.id));
      expect(copy.title, 'Original copy');
      expect(copy.pageIds, hasLength(1));
      expect(copy.pageIds.single, isNot(pageId));
      expect(copy.lastPageId, copy.pageIds.single);

      final copiedStrokes = await (db.select(
        db.strokes,
      )..where((s) => s.pageId.equals(copy.pageIds.single))).get();
      expect(copiedStrokes, hasLength(2));
      expect(copiedStrokes.map((s) => s.id), isNot(contains('s1')));
      expect(await db.select(db.strokes).get(), hasLength(4));
    });

    test('delete removes pages and strokes', () async {
      final keep = await repo.createNotebook(title: 'Keep');
      final gone = await repo.createNotebook(title: 'Gone');
      await addStroke(gone.pageIds.single, 's1');
      await repo.deleteNotebook(gone.id);
      expect((await repo.notebooks()).map((n) => n.id), [keep.id]);
      expect(await db.select(db.pages).get(), hasLength(1));
      expect(await db.select(db.strokes).get(), isEmpty);
    });
  });

  group('settings', () {
    test('store strings and enums, with fallbacks', () async {
      final settings = SettingsRepository(db);
      expect(await settings.get(SettingKeys.librarySort), isNull);
      expect(
        await settings.getEnum(
          SettingKeys.paperTemplate,
          PaperTemplate.values,
          PaperTemplate.lined,
        ),
        PaperTemplate.lined,
      );
      await settings.set(SettingKeys.paperTemplate, 'dotted');
      await settings.set(SettingKeys.paperTemplate, 'grid');
      expect(
        await settings.getEnum(
          SettingKeys.paperTemplate,
          PaperTemplate.values,
          PaperTemplate.lined,
        ),
        PaperTemplate.grid,
      );
      await settings.set(SettingKeys.librarySort, 'no-such-value');
      expect(
        await settings.getEnum(
          SettingKeys.librarySort,
          PaperTemplate.values,
          PaperTemplate.blank,
        ),
        PaperTemplate.blank,
      );
    });
  });
}
