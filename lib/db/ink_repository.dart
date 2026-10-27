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
    this.notebookId,
    this.flushDelay = const Duration(milliseconds: 400),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final MarginDatabase _db;

  /// When set, every flush also marks this notebook as edited.
  final String? notebookId;
  final Duration flushDelay;
  final DateTime Function() _now;

  /// Latest pending change per stroke id: a row to write, or null to delete.
  final Map<String, StrokesCompanion?> _pending = {};
  Timer? _timer;
  Future<void> _flushing = Future.value();

  /// Strokes of a page in draw order, including every change queued so far.
  Future<List<InkStroke>> loadStrokes(String pageId) async {
    try {
      await flush();
    } catch (_) {
      // The changes stay queued for the next flush; load what is saved.
    }
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
        if (notebookId case final id?) {
          b.update(
            _db.notebooks,
            NotebooksCompanion(updatedAt: Value(_now().toUtc())),
            where: (n) => n.id.equals(id),
          );
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
