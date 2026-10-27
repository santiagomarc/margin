import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/library_repository.dart';
import 'package:margin/db/settings_repository.dart';
import 'package:margin/state/library_controller.dart';

void main() {
  late MarginDatabase db;
  late LibraryController controller;
  final now = DateTime.utc(2026, 10, 27, 12);

  LibraryController newController() => LibraryController(
    repository: LibraryRepository(db, now: () => now),
    settings: SettingsRepository(db),
    now: () => now,
  );

  setUp(() async {
    db = MarginDatabase(NativeDatabase.memory());
    controller = newController();
    await controller.load();
  });

  tearDown(() async {
    controller.dispose();
    await db.close();
  });

  Future<Notebook> notebook(
    String title, {
    String? subject,
    int day = 27,
  }) async {
    final n = await controller.createNotebook(
      title: title,
      subjectId: subject,
      template: PaperTemplate.lined,
    );
    await (db.update(db.notebooks)..where((r) => r.id.equals(n.id))).write(
      NotebooksCompanion(updatedAt: Value(DateTime.utc(2026, 10, day))),
    );
    return n;
  }

  List<String> titles() => [for (final n in controller.visible) n.title];

  test('filters by subject and counts per subject', () async {
    final bio = await controller.createSubject('Biology', 0xFF2E7D32);
    await notebook('Cells', subject: bio.id);
    await notebook('Genes', subject: bio.id);
    await notebook('Loose');
    await controller.refresh();

    expect(controller.totalCount, 3);
    expect(controller.countFor(bio.id), 2);
    controller.setFilter(SubjectNotebooks(bio.id));
    expect(controller.heading, 'Biology');
    expect(controller.currentSubjectId, bio.id);
    expect(titles(), unorderedEquals(['Cells', 'Genes']));
  });

  test('deleting the shown subject goes back to all notebooks', () async {
    final bio = await controller.createSubject('Biology', 0xFF2E7D32);
    controller.setFilter(SubjectNotebooks(bio.id));
    final deletion = await controller.deleteSubject(bio.id);
    expect(controller.filter, const AllNotebooks());
    await controller.restoreSubject(deletion);
    expect(controller.subjects.single.name, 'Biology');
  });

  test('sorts by recent or title and remembers the choice', () async {
    await notebook('banana', day: 20);
    await notebook('Apple', day: 10);
    await notebook('cherry', day: 25);
    await controller.refresh();
    expect(titles(), ['cherry', 'banana', 'Apple']);

    await controller.setSort(LibrarySort.title);
    expect(titles(), ['Apple', 'banana', 'cherry']);

    final reopened = newController();
    await reopened.load();
    expect(reopened.sort, LibrarySort.title);
    reopened.dispose();
  });

  test('Recent keeps the last two weeks', () async {
    await notebook('Old', day: 1);
    await notebook('New', day: 20);
    await controller.refresh();
    controller.setFilter(const RecentNotebooks());
    expect(titles(), ['New']);
  });

  test('search matches titles, ignoring case', () async {
    await notebook('Cell structure');
    await notebook('Photosynthesis');
    await controller.refresh();
    controller.setQuery('STRUC');
    expect(titles(), ['Cell structure']);
    controller.setQuery('  ');
    expect(titles(), hasLength(2));
  });

  test('a deleted notebook hides at once and goes when committed', () async {
    final a = await notebook('A');
    await notebook('B');
    await controller.refresh();

    controller.deleteNotebook(a.id);
    expect(titles(), ['B']);
    expect(controller.totalCount, 1);
    controller.undoDelete(a.id);
    expect(titles(), hasLength(2));

    controller.deleteNotebook(a.id);
    await controller.commitDelete(a.id);
    expect(titles(), ['B']);
    expect(await db.select(db.notebooks).get(), hasLength(1));
  });

  test('pending deletes are committed when the library goes away', () async {
    final a = await notebook('A');
    controller.deleteNotebook(a.id);
    await controller.commitAllDeletes();
    expect(await db.select(db.notebooks).get(), isEmpty);
  });

  test('new notebooks remember the paper picked last', () async {
    expect(controller.defaultTemplate, PaperTemplate.lined);
    await controller.createNotebook(title: 'X', template: PaperTemplate.dotted);
    final reopened = newController();
    await reopened.load();
    expect(reopened.defaultTemplate, PaperTemplate.dotted);
    reopened.dispose();
  });

  test('duplicate names the copy after the original', () async {
    final a = await notebook('Cells');
    await controller.refresh();
    final copy = await controller.duplicateNotebook(a.id);
    expect(copy.title, 'Cells copy');
    expect(controller.totalCount, 2);
  });
}
