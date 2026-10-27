import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/library_repository.dart';
import 'package:margin/db/notebook_repository.dart';

void main() {
  late MarginDatabase db;
  late Notebook notebook;
  late NotebookRepository repo;
  final created = DateTime.utc(2026, 10, 27, 9);
  var now = created;

  setUp(() async {
    db = MarginDatabase(NativeDatabase.memory());
    now = created;
    notebook = await LibraryRepository(
      db,
      now: () => created,
    ).createNotebook(title: 'Cell structure');
    repo = NotebookRepository(db, notebook.id, now: () => now);
  });

  tearDown(() => db.close());

  NotebookPage page(String id) => NotebookPage(
    id: id,
    notebookId: notebook.id,
    width: PageSizes.a4.width,
    height: PageSizes.a4.height,
    background: const TemplateBackground(PaperTemplate.dotted),
  );

  Future<List<String>> loadedOrder() async =>
      (await repo.load()).pages.map((p) => p.id).toList();

  test('loads pages in page order, not insertion order', () async {
    final first = notebook.pageIds.single;
    await repo.insertPage(page('b'));
    await repo.insertPage(page('a'));
    await repo.writePageOrder([first, 'a', 'b']);
    expect(await loadedOrder(), [first, 'a', 'b']);

    await repo.writePageOrder(['b', first, 'a']);
    expect(await loadedOrder(), ['b', first, 'a']);
  });

  test('changing the page order marks the notebook edited', () async {
    now = DateTime.utc(2026, 10, 28, 10);
    await repo.insertPage(page('a'));
    await repo.writePageOrder([notebook.pageIds.single, 'a']);
    final row = (await repo.load()).notebook;
    expect(row.updatedAt, now);
    expect(row.pageIds, hasLength(2));
  });

  test('inserting a page twice (redo) is harmless', () async {
    await repo.insertPage(page('a'));
    await repo.insertPage(page('a'));
    expect(await db.select(db.pages).get(), hasLength(2));
  });

  test('pages left out of the order are swept with their strokes', () async {
    final first = notebook.pageIds.single;
    await repo.insertPage(page('a'));
    await db
        .into(db.strokes)
        .insert(
          StrokesCompanion.insert(
            id: 's1',
            pageId: 'a',
            tool: StrokeTool.pen,
            color: 0xFF000000,
            size: 2.5,
            points: Float32List.fromList([1, 2, 0.5]),
            minX: 0,
            minY: 0,
            maxX: 1,
            maxY: 1,
            createdAt: created,
          ),
        );
    await repo.writePageOrder([first]);
    // Still there until the sweep: undo can bring it back.
    expect(await db.select(db.pages).get(), hasLength(2));

    await repo.sweepDeletedPages();
    expect((await db.select(db.pages).get()).map((p) => p.id), [first]);
    expect(await db.select(db.strokes).get(), isEmpty);
  });

  test('opening the notebook sweeps deletes from last time', () async {
    await repo.insertPage(page('a'));
    expect(await db.select(db.pages).get(), hasLength(2));
    expect(await loadedOrder(), [notebook.pageIds.single]);
    expect(await db.select(db.pages).get(), hasLength(1));
  });

  test('rename and the page to reopen at', () async {
    now = DateTime.utc(2026, 10, 28, 10);
    await repo.rename(' Mitosis ');
    await repo.saveLastPage(notebook.pageIds.single, 1);
    final row = (await repo.load()).notebook;
    expect(row.title, 'Mitosis');
    expect(row.lastPageId, notebook.pageIds.single);
    expect(row.lastZoom, 1);
    expect(row.updatedAt, now, reason: 'renaming is an edit');

    now = DateTime.utc(2026, 10, 29, 10);
    await repo.saveLastPage(null, 1);
    final after = (await repo.load()).notebook;
    expect(after.lastPageId, isNull);
    expect(after.updatedAt, DateTime.utc(2026, 10, 28, 10));
  });
}
