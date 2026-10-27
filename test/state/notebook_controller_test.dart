import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/ink_repository.dart';
import 'package:margin/db/library_repository.dart';
import 'package:margin/db/notebook_repository.dart';
import 'package:margin/state/notebook_controller.dart';

void main() {
  late MarginDatabase db;
  late Notebook notebook;
  late NotebookController controller;

  setUp(() async {
    db = MarginDatabase(NativeDatabase.memory());
    notebook = await LibraryRepository(db)
        .createNotebook(title: 'Cells', template: PaperTemplate.grid);
    controller = NotebookController(
      notebooks: NotebookRepository(db, notebook.id),
      inkRepository: InkRepository(db, notebookId: notebook.id),
    );
    await controller.load();
  });

  tearDown(() async {
    await controller.close();
    await db.close();
  });

  List<String> order() => [for (final p in controller.pages) p.id];

  Future<List<String>> saved() async {
    // Let the fire-and-forget writes land.
    await Future<void>.delayed(Duration.zero);
    return (await NotebookRepository(db, notebook.id).load()).notebook.pageIds;
  }

  test('added pages copy the last page and go at the end', () async {
    controller
      ..addPage()
      ..addPage();
    expect(controller.pages, hasLength(3));
    expect(controller.pages.map((p) => p.background).toSet(), {
      const TemplateBackground(PaperTemplate.grid),
    });
    expect(order().first, notebook.pageIds.single);
    expect(await saved(), order());
  });

  test('moving pages is undoable', () async {
    controller
      ..addPage()
      ..addPage();
    final initial = order();

    controller.movePageBy(0, 1);
    expect(order(), [initial[1], initial[0], initial[2]]);
    controller.movePageBy(2, -2);
    expect(order(), [initial[2], initial[1], initial[0]]);
    expect(await saved(), order());

    controller.history.undo();
    controller.history.undo();
    expect(order(), initial);
    controller.history.redo();
    expect(order(), [initial[1], initial[0], initial[2]]);
    expect(await saved(), order());
  });

  test('moves past either end are ignored', () {
    controller.addPage();
    final before = order();
    controller.movePageBy(0, -1);
    controller.movePageBy(1, 1);
    expect(order(), before);
  });

  test('deleting a page is undoable and keeps its place', () async {
    controller
      ..addPage()
      ..addPage();
    final initial = order();
    final command = controller.deletePage(1)!;
    expect(order(), [initial[0], initial[2]]);

    expect(controller.history.undoIfLast(command), isTrue);
    expect(order(), initial);
    expect(await saved(), initial);
  });

  test('a snackbar Undo never undoes a later change', () {
    controller
      ..addPage()
      ..addPage();
    final command = controller.deletePage(1)!;
    controller.addPage();
    expect(controller.history.undoIfLast(command), isFalse);
    expect(controller.pages, hasLength(3));
  });

  test('the only page cannot be deleted', () {
    expect(controller.deletePage(0), isNull);
    expect(controller.pages, hasLength(1));
  });

  test('closing sweeps deleted pages', () async {
    controller.addPage();
    final kept = order().first;
    controller.deletePage(1);
    await controller.close();
    expect((await db.select(db.pages).get()).map((p) => p.id), [kept]);
    // close() is safe to call again from tearDown.
    controller = NotebookController(
      notebooks: NotebookRepository(db, notebook.id),
      inkRepository: InkRepository(db, notebookId: notebook.id),
    );
  });

  test('rename trims and saves', () async {
    await controller.rename('  Mitosis ');
    expect(controller.title, 'Mitosis');
    expect((await db.select(db.notebooks).getSingle()).title, 'Mitosis');
  });
}
