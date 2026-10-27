import 'package:drift/drift.dart';

import 'database.dart';

/// An open notebook and its pages in order.
class LoadedNotebook {
  const LoadedNotebook(this.notebook, this.pages);

  final Notebook notebook;
  final List<NotebookPage> pages;
}

/// Reads and writes one notebook's own row and its pages (strokes go through
/// [InkRepository]).
///
/// A deleted page only leaves the notebook's page order, so undo can put it
/// back with one write. Pages left out of the order are swept when the
/// notebook opens or closes, once nothing can undo their deletion.
class NotebookRepository {
  NotebookRepository(this._db, this.notebookId, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final MarginDatabase _db;
  final String notebookId;
  final DateTime Function() _now;

  /// Loads the notebook and its pages in page order, sweeping pages left
  /// over from deletes in an earlier session.
  Future<LoadedNotebook> load() async {
    await sweepDeletedPages();
    final notebook = await (_db.select(
      _db.notebooks,
    )..where((n) => n.id.equals(notebookId))).getSingle();
    final rows = await (_db.select(
      _db.pages,
    )..where((p) => p.notebookId.equals(notebookId))).get();
    final byId = {for (final p in rows) p.id: p};
    return LoadedNotebook(notebook, [
      for (final id in notebook.pageIds) ?byId[id],
    ]);
  }

  /// Adds a page row. Safe to call again for the same page (redo).
  Future<void> insertPage(NotebookPage page) {
    return _db.into(_db.pages).insert(page, mode: InsertMode.insertOrIgnore);
  }

  /// Saves the page order: adding, deleting and moving a page each rewrite
  /// only this one row.
  Future<void> writePageOrder(List<String> pageIds) {
    return _updateNotebook(
      NotebooksCompanion(
        pageIds: Value(List.of(pageIds)),
        updatedAt: Value(_now().toUtc()),
      ),
    );
  }

  Future<void> rename(String title) {
    return _updateNotebook(
      NotebooksCompanion(
        title: Value(title.trim()),
        updatedAt: Value(_now().toUtc()),
      ),
    );
  }

  /// Remembers where the notebook was left, without touching `updatedAt`
  /// (reading is not editing).
  Future<void> saveLastPage(String? pageId, double zoom) {
    return _updateNotebook(
      NotebooksCompanion(lastPageId: Value(pageId), lastZoom: Value(zoom)),
    );
  }

  /// Deletes pages (with their strokes and tapes) that are no longer in the
  /// page order. Flush pending stroke writes first.
  Future<void> sweepDeletedPages() async {
    final notebook = await (_db.select(
      _db.notebooks,
    )..where((n) => n.id.equals(notebookId))).getSingleOrNull();
    if (notebook == null) return;
    await (_db.delete(_db.pages)..where(
          (p) =>
              p.notebookId.equals(notebookId) & p.id.isNotIn(notebook.pageIds),
        ))
        .go();
  }

  Future<void> _updateNotebook(NotebooksCompanion changes) {
    return (_db.update(
      _db.notebooks,
    )..where((n) => n.id.equals(notebookId))).write(changes);
  }
}
