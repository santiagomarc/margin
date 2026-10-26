import 'dart:async';
import 'dart:ui';

import 'package:drift/drift.dart';

import '../canvas/ink_stroke.dart';
import 'database.dart';

/// Loads and saves strokes. Writes are queued and flushed together shortly
/// after the finger lifts, in one transaction, never mid-stroke.
class InkRepository {
  InkRepository(
    this._db, {
    this.flushDelay = const Duration(milliseconds: 400),
  });

  final MarginDatabase _db;
  final Duration flushDelay;

  /// Latest pending change per stroke id: a row to write, or null to delete.
  final Map<String, StrokesCompanion?> _pending = {};
  Timer? _timer;
  Future<void> _flushing = Future.value();

  static const scratchNotebookId = 'scratch';
  static const scratchPageId = 'scratch-page-1';

  /// A4 portrait, in points.
  static const a4 = Size(595.28, 841.89);

  /// The built-in scratch notebook's only page, created on first use.
  Future<NotebookPage> ensureScratchPage() async {
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      await _db
          .into(_db.notebooks)
          .insert(
            NotebooksCompanion.insert(
              id: scratchNotebookId,
              title: 'Scratch page',
              kind: NotebookKind.notes,
              pageIds: const [scratchPageId],
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      await _db
          .into(_db.pages)
          .insert(
            PagesCompanion.insert(
              id: scratchPageId,
              notebookId: scratchNotebookId,
              width: a4.width,
              height: a4.height,
              background: const TemplateBackground(PaperTemplate.lined),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    });
    return (_db.select(
      _db.pages,
    )..where((p) => p.id.equals(scratchPageId))).getSingle();
  }

  /// Strokes of a page in draw order.
  Future<List<InkStroke>> loadStrokes(String pageId) async {
    final rows =
        await (_db.select(_db.strokes)
              ..where((s) => s.pageId.equals(pageId))
              ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
            .get();
    return [
      for (final row in rows)
        InkStroke(
          id: row.id,
          tool: row.tool,
          color: row.color,
          size: row.size,
          points: row.points,
          bounds: Rect.fromLTRB(row.minX, row.minY, row.maxX, row.maxY),
          createdAt: row.createdAt,
        ),
    ];
  }

  void saveStroke(String pageId, InkStroke stroke) {
    _pending[stroke.id] = StrokesCompanion.insert(
      id: stroke.id,
      pageId: pageId,
      tool: stroke.tool,
      color: stroke.color,
      size: stroke.size,
      points: stroke.points,
      minX: stroke.bounds.left,
      minY: stroke.bounds.top,
      maxX: stroke.bounds.right,
      maxY: stroke.bounds.bottom,
      createdAt: stroke.createdAt,
    );
    _schedule();
  }

  void deleteStroke(String id) {
    _pending[id] = null;
    _schedule();
  }

  bool get hasPendingWrites => _pending.isNotEmpty;

  /// Writes everything queued so far. Safe to call at any time.
  Future<void> flush() {
    _timer?.cancel();
    _timer = null;
    // A failed earlier flush must not block this one.
    return _flushing = _flushing
        .catchError((Object _) {})
        .then((_) => _write());
  }

  /// Stops the timer. Call [flush] first to keep pending writes.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(flushDelay, flush);
  }

  Future<void> _write() async {
    if (_pending.isEmpty) return;
    final batch = Map.of(_pending);
    _pending.clear();
    final upserts = [for (final row in batch.values) ?row];
    final deletes = [
      for (final entry in batch.entries)
        if (entry.value == null) entry.key,
    ];
    try {
      await _db.batch((b) {
        if (upserts.isNotEmpty) {
          b.insertAll(_db.strokes, upserts, mode: InsertMode.insertOrReplace);
        }
        if (deletes.isNotEmpty) {
          b.deleteWhere(_db.strokes, (s) => s.id.isIn(deletes));
        }
      });
    } catch (_) {
      // Keep the changes for the next flush, unless newer ones replaced them.
      for (final entry in batch.entries) {
        _pending.putIfAbsent(entry.key, () => entry.value);
      }
      rethrow;
    }
  }
}
