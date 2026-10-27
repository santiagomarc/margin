import '../canvas/ink_layer.dart';
import '../canvas/ink_stroke.dart';
import '../db/ink_repository.dart';

class _PageInk {
  final InkLayerController layer = InkLayerController();
  int users = 0;
  bool loaded = false;

  /// Changes made while the strokes were still loading, replayed after.
  final List<void Function(InkLayerController layer)> pending = [];
}

/// Ink of the pages near the screen, loaded when a page is built and
/// released (strokes and cached picture) when it scrolls away, so a long
/// notebook only holds a few pages in memory.
///
/// Every change goes to the repository whether or not its page is loaded,
/// so undo still works for a page that has scrolled away.
class PageInkStore {
  PageInkStore(this.repository, {this.onError});

  final InkRepository repository;
  final void Function(Object error, StackTrace stack)? onError;

  final Map<String, _PageInk> _pages = {};

  /// Ink layer for a page being built. Call [release] when it goes away.
  InkLayerController attach(String pageId) {
    final existing = _pages[pageId];
    if (existing != null) {
      existing.users++;
      return existing.layer;
    }
    final page = _PageInk()..users = 1;
    _pages[pageId] = page;
    repository
        .loadStrokes(pageId)
        .then(
          (strokes) {
            if (!identical(_pages[pageId], page)) return;
            page.layer.setAll(strokes);
            page.loaded = true;
            for (final change in page.pending) {
              change(page.layer);
            }
            page.pending.clear();
          },
          onError: (Object error, StackTrace stack) {
            onError?.call(error, stack);
          },
        );
    return page.layer;
  }

  void release(String pageId) {
    final page = _pages[pageId];
    if (page == null || --page.users > 0) return;
    _pages.remove(pageId);
    page.layer.dispose();
  }

  /// Whether a page's strokes are in memory (strokes can start on it).
  bool isLoaded(String pageId) => _pages[pageId]?.loaded ?? false;

  /// The loaded layer of a page, if it is near the screen.
  InkLayerController? layerOf(String pageId) => _pages[pageId]?.layer;

  /// Number of pages holding ink in memory.
  int get loadedPageCount => _pages.length;

  void addStroke(String pageId, InkStroke stroke) {
    _change(pageId, (layer) => layer.add(stroke));
    repository.saveStroke(pageId, stroke);
  }

  void removeStroke(String pageId, String strokeId) {
    _change(pageId, (layer) => layer.remove(strokeId));
    repository.deleteStroke(strokeId);
  }

  void _change(String pageId, void Function(InkLayerController) change) {
    final page = _pages[pageId];
    if (page == null) return;
    if (page.loaded) {
      change(page.layer);
    } else {
      page.pending.add(change);
    }
  }

  void dispose() {
    for (final page in _pages.values) {
      page.layer.dispose();
    }
    _pages.clear();
  }
}
