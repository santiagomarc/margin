import 'package:flutter/foundation.dart';

import '../db/database.dart';
import '../db/library_repository.dart';
import '../db/settings_repository.dart';

enum LibrarySort { recent, title }

/// Which notebooks the grid shows.
sealed class LibraryFilter {
  const LibraryFilter();
}

final class AllNotebooks extends LibraryFilter {
  const AllNotebooks();

  @override
  bool operator ==(Object other) => other is AllNotebooks;

  @override
  int get hashCode => 0;
}

/// Notebooks edited within [LibraryController.recentWindow].
final class RecentNotebooks extends LibraryFilter {
  const RecentNotebooks();

  @override
  bool operator ==(Object other) => other is RecentNotebooks;

  @override
  int get hashCode => 1;
}

final class SubjectNotebooks extends LibraryFilter {
  const SubjectNotebooks(this.subjectId);

  final String subjectId;

  @override
  bool operator ==(Object other) =>
      other is SubjectNotebooks && other.subjectId == subjectId;

  @override
  int get hashCode => subjectId.hashCode;
}

/// The library screen's state: subjects, notebooks, filter, sort and search.
///
/// Reloads from the database after each change it makes (the library holds
/// at most a few hundred small rows), and when the screen comes back from a
/// notebook.
class LibraryController extends ChangeNotifier {
  LibraryController({
    required this.repository,
    required this.settings,
    DateTime Function()? now,
    this.recentWindow = const Duration(days: 14),
  }) : _now = now ?? DateTime.now;

  final LibraryRepository repository;
  final SettingsRepository settings;
  final DateTime Function() _now;
  final Duration recentWindow;

  bool _loaded = false;
  bool get isLoaded => _loaded;
  bool _disposed = false;

  List<Subject> _subjects = const [];
  List<Subject> get subjects => _subjects;

  List<NotebookSummary> _notebooks = const [];

  /// Notebooks deleted but still undoable: hidden now, removed for good when
  /// their snackbar closes.
  final Set<String> _pendingDeletes = {};

  LibraryFilter _filter = const AllNotebooks();
  LibraryFilter get filter => _filter;

  LibrarySort _sort = LibrarySort.recent;
  LibrarySort get sort => _sort;

  String _query = '';
  String get query => _query;

  PaperTemplate _defaultTemplate = PaperTemplate.lined;

  /// The paper last picked for a new notebook.
  PaperTemplate get defaultTemplate => _defaultTemplate;

  Future<void> load() async {
    _sort = await settings.getEnum(
      SettingKeys.librarySort,
      LibrarySort.values,
      LibrarySort.recent,
    );
    _defaultTemplate = await settings.getEnum(
      SettingKeys.paperTemplate,
      PaperTemplate.values,
      PaperTemplate.lined,
    );
    await refresh();
  }

  Future<void> refresh() async {
    _subjects = await repository.subjects();
    _notebooks = await repository.notebooks();
    if (_filter case SubjectNotebooks(:final subjectId)
        when subjectOf(subjectId) == null) {
      _filter = const AllNotebooks();
    }
    _loaded = true;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    // Writes can finish after the library screen has gone.
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Iterable<NotebookSummary> get _live =>
      _notebooks.where((n) => !_pendingDeletes.contains(n.id));

  /// Notebooks shown for the current filter, search and sort.
  List<NotebookSummary> get visible {
    final cutoff = _now().toUtc().subtract(recentWindow);
    final query = _query.trim().toLowerCase();
    final shown = _live.where((n) {
      final matchesFilter = switch (_filter) {
        AllNotebooks() => true,
        RecentNotebooks() => n.notebook.updatedAt.isAfter(cutoff),
        SubjectNotebooks(:final subjectId) => n.notebook.subjectId == subjectId,
      };
      return matchesFilter &&
          (query.isEmpty || n.title.toLowerCase().contains(query));
    }).toList();
    switch (_sort) {
      case LibrarySort.recent:
        shown.sort(
          (a, b) => b.notebook.updatedAt.compareTo(a.notebook.updatedAt),
        );
      case LibrarySort.title:
        shown.sort((a, b) {
          final byTitle = a.title.toLowerCase().compareTo(
            b.title.toLowerCase(),
          );
          return byTitle != 0 ? byTitle : a.title.compareTo(b.title);
        });
    }
    return shown;
  }

  /// Whether there are any notebooks at all (for the empty state).
  bool get hasNotebooks => _live.isNotEmpty;

  int get totalCount => _live.length;

  int countFor(String subjectId) =>
      _live.where((n) => n.notebook.subjectId == subjectId).length;

  Subject? subjectOf(String? id) {
    if (id == null) return null;
    for (final s in _subjects) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// The grid's heading.
  String get heading => switch (_filter) {
    AllNotebooks() => 'All notebooks',
    RecentNotebooks() => 'Recent',
    SubjectNotebooks(:final subjectId) =>
      subjectOf(subjectId)?.name ?? 'All notebooks',
  };

  /// The subject new notebooks go into from the current view.
  String? get currentSubjectId => switch (_filter) {
    SubjectNotebooks(:final subjectId) => subjectId,
    _ => null,
  };

  void setFilter(LibraryFilter filter) {
    if (filter == _filter) return;
    _filter = filter;
    notifyListeners();
  }

  Future<void> setSort(LibrarySort sort) async {
    if (sort == _sort) return;
    _sort = sort;
    notifyListeners();
    await settings.set(SettingKeys.librarySort, sort.name);
  }

  void setQuery(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }

  // Subjects

  Future<Subject> createSubject(String name, int color) async {
    final subject = await repository.createSubject(name, color);
    await refresh();
    return subject;
  }

  Future<void> renameSubject(String id, String name) async {
    await repository.renameSubject(id, name);
    await refresh();
  }

  Future<void> recolorSubject(String id, int color) async {
    await repository.recolorSubject(id, color);
    await refresh();
  }

  Future<SubjectDeletion> deleteSubject(String id) async {
    final deletion = await repository.deleteSubject(id);
    await refresh();
    return deletion;
  }

  Future<void> restoreSubject(SubjectDeletion deletion) async {
    await repository.restoreSubject(deletion);
    await refresh();
  }

  // Notebooks

  Future<Notebook> createNotebook({
    required String title,
    String? subjectId,
    required PaperTemplate template,
  }) async {
    final notebook = await repository.createNotebook(
      title: title,
      subjectId: subjectId,
      template: template,
    );
    if (template != _defaultTemplate) {
      _defaultTemplate = template;
      await settings.set(SettingKeys.paperTemplate, template.name);
    }
    await refresh();
    return notebook;
  }

  Future<void> renameNotebook(String id, String title) async {
    await repository.renameNotebook(id, title);
    await refresh();
  }

  Future<void> moveNotebook(String id, String? subjectId) async {
    await repository.moveNotebook(id, subjectId);
    await refresh();
  }

  Future<Notebook> duplicateNotebook(String id) async {
    final source = _notebooks.firstWhere((n) => n.id == id);
    final copy = await repository.duplicateNotebook(
      id,
      title: '${source.title} copy',
    );
    await refresh();
    return copy;
  }

  /// Hides a notebook at once; [commitDelete] removes it for good and
  /// [undoDelete] brings it back.
  void deleteNotebook(String id) {
    _pendingDeletes.add(id);
    notifyListeners();
  }

  void undoDelete(String id) {
    if (_pendingDeletes.remove(id)) notifyListeners();
  }

  Future<void> commitDelete(String id) async {
    if (!_pendingDeletes.contains(id)) return;
    await repository.deleteNotebook(id);
    _pendingDeletes.remove(id);
    _notebooks = [
      for (final n in _notebooks)
        if (n.id != id) n,
    ];
    notifyListeners();
  }

  /// Removes every notebook still waiting for its Undo to expire.
  Future<void> commitAllDeletes() async {
    for (final id in List.of(_pendingDeletes)) {
      await repository.deleteNotebook(id);
    }
    _pendingDeletes.clear();
  }
}
