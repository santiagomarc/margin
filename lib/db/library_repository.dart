import 'dart:ui' show Size;

import 'package:drift/drift.dart';

import 'database.dart';
import 'ids.dart';

/// A notebook as the library shows it: the row plus what its card needs.
class NotebookSummary {
  const NotebookSummary({
    required this.notebook,
    required this.firstPage,
    required this.pageCount,
  });

  final Notebook notebook;

  /// Null only for a notebook with no pages (never created by the app).
  final NotebookPage? firstPage;
  final int pageCount;

  String get id => notebook.id;
  String get title => notebook.title;
}

/// What deleting a subject changed, so Undo can put it back.
class SubjectDeletion {
  const SubjectDeletion(this.subject, this.notebookIds);

  final Subject subject;
  final List<String> notebookIds;
}

/// Subjects and notebooks: everything the library screen reads and changes.
class LibraryRepository {
  LibraryRepository(this._db, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final MarginDatabase _db;
  final DateTime Function() _now;

  DateTime _timestamp() => _now().toUtc();

  // Subjects

  Future<List<Subject>> subjects() {
    return (_db.select(_db.subjects)..orderBy([
          (s) => OrderingTerm.asc(s.sortOrder),
          (s) => OrderingTerm.asc(s.name),
        ]))
        .get();
  }

  Future<Subject> createSubject(String name, int color) async {
    final max = _db.subjects.sortOrder.max();
    final last = await (_db.selectOnly(
      _db.subjects,
    )..addColumns([max])).map((r) => r.read(max)).getSingle();
    final subject = Subject(
      id: newId(),
      name: name.trim(),
      color: color,
      sortOrder: (last ?? -1) + 1,
    );
    await _db.into(_db.subjects).insert(subject);
    return subject;
  }

  Future<void> renameSubject(String id, String name) {
    return (_db.update(_db.subjects)..where((s) => s.id.equals(id))).write(
      SubjectsCompanion(name: Value(name.trim())),
    );
  }

  Future<void> recolorSubject(String id, int color) {
    return (_db.update(_db.subjects)..where((s) => s.id.equals(id))).write(
      SubjectsCompanion(color: Value(color)),
    );
  }

  /// Deletes a subject. Its notebooks stay, without a subject.
  Future<SubjectDeletion> deleteSubject(String id) {
    return _db.transaction(() async {
      final subject = await (_db.select(
        _db.subjects,
      )..where((s) => s.id.equals(id))).getSingle();
      final notebookIds =
          await (_db.selectOnly(_db.notebooks)
                ..addColumns([_db.notebooks.id])
                ..where(_db.notebooks.subjectId.equals(id)))
              .map((r) => r.read(_db.notebooks.id)!)
              .get();
      // The foreign key clears notebooks.subjectId.
      await (_db.delete(_db.subjects)..where((s) => s.id.equals(id))).go();
      return SubjectDeletion(subject, notebookIds);
    });
  }

  /// Undoes [deleteSubject].
  Future<void> restoreSubject(SubjectDeletion deletion) {
    return _db.transaction(() async {
      await _db
          .into(_db.subjects)
          .insert(deletion.subject, mode: InsertMode.insertOrReplace);
      await (_db.update(_db.notebooks)
            ..where((n) => n.id.isIn(deletion.notebookIds)))
          .write(NotebooksCompanion(subjectId: Value(deletion.subject.id)));
    });
  }

  // Notebooks

  /// Every notebook with its first page, in no particular order.
  Future<List<NotebookSummary>> notebooks() async {
    final notebooks = await _db.select(_db.notebooks).get();
    final firstIds = [
      for (final n in notebooks)
        if (n.pageIds.isNotEmpty) n.pageIds.first,
    ];
    final pages = firstIds.isEmpty
        ? const <NotebookPage>[]
        : await (_db.select(
            _db.pages,
          )..where((p) => p.id.isIn(firstIds))).get();
    final byId = {for (final p in pages) p.id: p};
    return [
      for (final n in notebooks)
        NotebookSummary(
          notebook: n,
          firstPage: n.pageIds.isEmpty ? null : byId[n.pageIds.first],
          pageCount: n.pageIds.length,
        ),
    ];
  }

  /// A new notes notebook with one blank page of [template].
  Future<Notebook> createNotebook({
    required String title,
    String? subjectId,
    PaperTemplate template = PaperTemplate.lined,
    Size pageSize = PageSizes.a4,
  }) {
    final now = _timestamp();
    final pageId = newId();
    final notebook = Notebook(
      id: newId(),
      subjectId: subjectId,
      title: title.trim(),
      kind: NotebookKind.notes,
      pageIds: [pageId],
      createdAt: now,
      updatedAt: now,
      lastZoom: 1,
    );
    return _db.transaction(() async {
      await _db.into(_db.notebooks).insert(notebook);
      await _db
          .into(_db.pages)
          .insert(
            PagesCompanion.insert(
              id: pageId,
              notebookId: notebook.id,
              width: pageSize.width,
              height: pageSize.height,
              background: TemplateBackground(template),
            ),
          );
      return notebook;
    });
  }

  Future<void> renameNotebook(String id, String title) {
    return (_db.update(_db.notebooks)..where((n) => n.id.equals(id))).write(
      NotebooksCompanion(
        title: Value(title.trim()),
        updatedAt: Value(_timestamp()),
      ),
    );
  }

  /// Moves a notebook into a subject, or out of every subject when null.
  Future<void> moveNotebook(String id, String? subjectId) {
    return (_db.update(_db.notebooks)..where((n) => n.id.equals(id))).write(
      NotebooksCompanion(subjectId: Value(subjectId)),
    );
  }

  /// Copies a notebook with all its pages, strokes and tapes (new ids, same
  /// draw order). Pages that are no longer in its page order are left out.
  Future<Notebook> duplicateNotebook(String id, {required String title}) {
    return _db.transaction(() async {
      final source = await (_db.select(
        _db.notebooks,
      )..where((n) => n.id.equals(id))).getSingle();
      final pages = await (_db.select(
        _db.pages,
      )..where((p) => p.id.isIn(source.pageIds))).get();
      final pageIdMap = {for (final p in pages) p.id: newId()};
      final strokes = await (_db.select(
        _db.strokes,
      )..where((s) => s.pageId.isIn(pageIdMap.keys))).get();
      final tapes = await (_db.select(
        _db.tapes,
      )..where((t) => t.pageId.isIn(pageIdMap.keys))).get();

      final now = _timestamp();
      final copy = source.copyWith(
        id: newId(),
        title: title.trim(),
        pageIds: [for (final pageId in source.pageIds) ?pageIdMap[pageId]],
        createdAt: now,
        updatedAt: now,
        lastPageId: Value(pageIdMap[source.lastPageId]),
      );
      await _db.into(_db.notebooks).insert(copy);
      await _db.batch((b) {
        b.insertAll(_db.pages, [
          for (final p in pages)
            p.copyWith(id: pageIdMap[p.id], notebookId: copy.id),
        ]);
        b.insertAll(_db.strokes, [
          for (final s in strokes)
            s.copyWith(id: newId(), pageId: pageIdMap[s.pageId]),
        ]);
        b.insertAll(_db.tapes, [
          for (final t in tapes)
            t.copyWith(id: newId(), pageId: pageIdMap[t.pageId]),
        ]);
      });
      return copy;
    });
  }

  /// Deletes a notebook with its pages, strokes and tapes.
  Future<void> deleteNotebook(String id) {
    return (_db.delete(_db.notebooks)..where((n) => n.id.equals(id))).go();
  }
}
