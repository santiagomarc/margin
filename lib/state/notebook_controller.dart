import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../canvas/ink_stroke.dart';
import '../canvas/live_layer.dart';
import '../canvas/page_layout.dart';
import '../db/database.dart';
import '../db/ids.dart';
import '../db/ink_repository.dart';
import '../db/notebook_repository.dart';
import '../diagnostics/diagnostics.dart';
import '../history/history.dart';
import '../history/page_commands.dart';
import '../history/stroke_commands.dart';
import '../input/input_router.dart';
import '../tools/pen_tool.dart';
import 'feedback_controller.dart';
import 'page_ink_store.dart';

/// State of the open notebook and the bridge from classified input to tools,
/// history and storage.
///
/// Notifies listeners only when the notebook's structure changes (title,
/// pages). Writing, scrolling and ink changes never rebuild widgets: painters
/// listen to their own layers.
class NotebookController extends ChangeNotifier
    implements InputHandler, PageList {
  NotebookController({
    required this.notebooks,
    required this.inkRepository,
    this.diagnostics,
    this.lastPageSaveDelay = const Duration(seconds: 1),
  }) {
    router = InputRouter(this, stats: diagnostics?.touch);
    pen = PenTool(live: live, onCommit: _commit);
    ink = PageInkStore(inkRepository, onError: _logError);
  }

  final NotebookRepository notebooks;
  final InkRepository inkRepository;
  final Diagnostics? diagnostics;

  /// How long the current page must stay put before it is saved as the
  /// page to reopen at.
  final Duration lastPageSaveDelay;

  late final PageInkStore ink;
  final LiveStroke live = LiveStroke();
  final History history = History();
  final FeedbackController feedback = FeedbackController();

  /// Index of the page under the top third of the screen.
  final ValueNotifier<int> currentPage = ValueNotifier(0);

  late final InputRouter router;
  late final PenTool pen;

  Notebook? _notebook;
  Notebook? get notebook => _notebook;
  String get title => _notebook?.title ?? '';

  List<NotebookPage> _pages = const [];
  List<NotebookPage> get pages => _pages;

  /// Set by the page view on every layout.
  PageLayout _layout = PageLayout.empty;
  PageLayout get layout => _layout;

  ScrollController? _scroll;
  String? _revealPageId;
  String? _savedLastPageId;
  Timer? _lastPageTimer;

  // The page a stroke is being written on, and its origin in content
  // coordinates: set at stroke start, read for every sample.
  int _strokePage = -1;
  double _strokeLeft = 0;
  double _strokeTop = 0;
  double _strokeScale = 1;
  double _strokeScroll = 0;

  bool get isLoaded => _notebook != null;

  Future<void> load() async {
    final loaded = await notebooks.load();
    _notebook = loaded.notebook;
    _pages = loaded.pages;
    _savedLastPageId = loaded.notebook.lastPageId;
    final last = _pages.indexWhere((p) => p.id == _savedLastPageId);
    currentPage.value = last < 0 ? 0 : last;
    notifyListeners();
  }

  /// Page sizes in points, in page order.
  List<Size> get pageSizes => [for (final p in _pages) Size(p.width, p.height)];

  /// The list's scroll controller, created on the first layout so the
  /// notebook opens at the page it was left at.
  ScrollController scrollController() {
    return _scroll ??= ScrollController(
      initialScrollOffset: _layout.length == 0
          ? 0
          : _layout.scrollToPage(
              currentPage.value.clamp(0, _layout.length - 1),
            ),
    )..addListener(_onScroll);
  }

  double get _offset =>
      _scroll?.hasClients ?? false ? _scroll!.position.pixels : 0;

  /// Called by the page view whenever it lays out.
  void updateLayout(PageLayout layout) {
    final old = _layout;
    _layout = layout;
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients || layout.length == 0) return;

    final reveal = _revealPageId;
    double? target;
    if (reveal != null) {
      _revealPageId = null;
      final index = _pages.indexWhere((p) => p.id == reveal);
      if (index >= 0) target = layout.scrollToPage(index);
    } else if (old.viewport.width != layout.viewport.width && old.length > 0) {
      // Rotated: keep the same spot of the same page at the top.
      final offset = _offset;
      final index = old.pageAt(offset).clamp(0, layout.length - 1);
      final fraction = (offset - old.topOf(index)) / old.extentOf(index);
      target = layout.clampScroll(
        layout.topOf(index) + fraction * layout.extentOf(index),
      );
    }
    if (target != null) {
      final offset = target;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_scroll?.hasClients ?? false) _scroll!.jumpTo(offset);
      });
    }
  }

  void _onScroll() {
    if (_layout.length == 0) return;
    final index = _layout.currentPage(_offset).clamp(0, _layout.length - 1);
    if (index == currentPage.value) return;
    currentPage.value = index;
    _lastPageTimer?.cancel();
    _lastPageTimer = Timer(lastPageSaveDelay, saveLastPage);
  }

  /// Saves the current page as the one to reopen at.
  Future<void> saveLastPage() async {
    _lastPageTimer?.cancel();
    _lastPageTimer = null;
    if (_pages.isEmpty) return;
    final pageId = _pages[currentPage.value.clamp(0, _pages.length - 1)].id;
    if (pageId == _savedLastPageId) return;
    _savedLastPageId = pageId;
    await notebooks.saveLastPage(pageId, 1).catchError(_logError);
  }

  void undo() {
    feedback.show(history.undo() ? 'Undo' : 'Nothing to undo');
  }

  void redo() {
    feedback.show(history.redo() ? 'Redo' : 'Nothing to redo');
  }

  /// Saves everything pending: strokes and the page to reopen at.
  Future<void> flush() async {
    await saveLastPage();
    await inkRepository.flush();
  }

  // Notebook and page changes

  Future<void> rename(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty || _notebook == null) return;
    _notebook = _notebook!.copyWith(title: trimmed);
    notifyListeners();
    await notebooks.rename(trimmed).catchError(_logError);
  }

  /// Adds a blank page after the last one, with the last page's size and
  /// paper, and scrolls to it.
  void addPage() {
    final last = _pages.isEmpty ? null : _pages.last;
    final page = NotebookPage(
      id: newId(),
      notebookId: _notebook!.id,
      width: last?.width ?? PageSizes.a4.width,
      height: last?.height ?? PageSizes.a4.height,
      background: last?.background is TemplateBackground
          ? last!.background
          : const TemplateBackground(PaperTemplate.lined),
    );
    history.execute(AddPageCommand(this, page, _pages.length));
  }

  /// Deletes the page at [index]. Returns the command, for a snackbar Undo.
  Command? deletePage(int index) {
    if (_pages.length <= 1 || index < 0 || index >= _pages.length) {
      return null;
    }
    final command = DeletePageCommand(this, _pages[index], index);
    history.execute(command);
    return command;
  }

  /// Moves the page at [index] by [delta] places.
  void movePageBy(int index, int delta) {
    final to = index + delta;
    if (index < 0 || index >= _pages.length || to < 0 || to >= _pages.length) {
      return;
    }
    history.execute(MovePageCommand(this, _pages[index].id, index, to));
  }

  @override
  void insertPage(int index, NotebookPage page) {
    _pages = List.of(_pages)..insert(index.clamp(0, _pages.length), page);
    _revealPageId = page.id;
    _savePages(insert: page);
  }

  @override
  void removePage(String pageId) {
    final index = _pages.indexWhere((p) => p.id == pageId);
    if (index < 0) return;
    _pages = List.of(_pages)..removeAt(index);
    if (_pages.isNotEmpty) {
      _revealPageId = _pages[index.clamp(0, _pages.length - 1)].id;
    }
    _savePages();
  }

  @override
  void movePage(String pageId, int index) {
    final from = _pages.indexWhere((p) => p.id == pageId);
    if (from < 0) return;
    final page = _pages[from];
    _pages = List.of(_pages)
      ..removeAt(from)
      ..insert(index.clamp(0, _pages.length - 1), page);
    _revealPageId = pageId;
    _savePages();
  }

  void _savePages({NotebookPage? insert}) {
    notifyListeners();
    final order = [for (final p in _pages) p.id];
    // Issued in order on the database's single connection: the page row
    // exists before any stroke on it is flushed.
    if (insert != null) {
      unawaited(notebooks.insertPage(insert).catchError(_logError));
    }
    unawaited(notebooks.writePageOrder(order).catchError(_logError));
  }

  void _commit(InkStroke stroke) {
    if (_strokePage < 0 || _strokePage >= _pages.length) return;
    history.execute(
      AddStrokeCommand(
        ink: ink,
        pageId: _pages[_strokePage].id,
        stroke: stroke,
      ),
    );
  }

  void _logError(Object error, [StackTrace? stack]) {
    diagnostics?.log.error(error, stack);
  }

  // Input. Positions are in the page view's coordinates.

  // Page coordinates without allocating: called for every pointer sample.
  double _pageX(Offset p) => (p.dx - _strokeLeft) / _strokeScale;
  double _pageY(Offset p) => (p.dy + _strokeScroll - _strokeTop) / _strokeScale;

  @override
  bool canStartStroke(Offset position) {
    final scroll = _scroll;
    if (scroll != null &&
        scroll.hasClients &&
        scroll.position.isScrollingNotifier.value) {
      // A finger landing stops a fling.
      scroll.jumpTo(scroll.position.pixels);
    }
    final offset = _offset;
    final index = _layout.pageContaining(position.dx, position.dy + offset);
    if (index < 0 || index >= _pages.length) return false;
    if (!ink.isLoaded(_pages[index].id)) return false;
    final rect = _layout.rectOf(index);
    _strokePage = index;
    _strokeLeft = rect.left;
    _strokeTop = rect.top;
    _strokeScale = _layout.scaleOf(index);
    _strokeScroll = offset;
    live.place(Offset(rect.left, rect.top - offset), rect.size, _strokeScale);
    return true;
  }

  @override
  void strokeStart(Offset position, Duration time) =>
      pen.start(_pageX(position), _pageY(position), time.inMicroseconds);

  @override
  void strokeUpdate(Offset position, Duration time) =>
      pen.update(_pageX(position), _pageY(position), time.inMicroseconds);

  @override
  void strokeEnd(Duration time, {required bool isTap}) => pen.end();

  @override
  void strokeCancel() => pen.cancel();

  @override
  void multiFingerTap(int fingers) {
    if (fingers == 2) {
      undo();
    } else if (fingers == 3) {
      redo();
    }
  }

  @override
  void scrollBy(Offset delta) {
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients) return;
    final position = scroll.position;
    final target = (position.pixels - delta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != position.pixels) position.jumpTo(target);
  }

  @override
  void scrollEnd(Offset velocity) {
    final scroll = _scroll;
    if (scroll == null || !scroll.hasClients || velocity.dy == 0) return;
    final position = scroll.position;
    if (position is ScrollPositionWithSingleContext) {
      position.goBallistic(-velocity.dy);
    }
  }

  /// Saves pending writes, removes pages deleted this session (nothing can
  /// undo them any more) and releases everything.
  Future<void> close() async {
    // Starts the write while the current page is still known.
    final savingLastPage = saveLastPage();
    _scroll?.dispose();
    _scroll = null;
    ink.dispose();
    feedback.dispose();
    live.dispose();
    history.dispose();
    currentPage.dispose();
    dispose();
    try {
      await savingLastPage;
      await inkRepository.flush();
      await notebooks.sweepDeletedPages();
    } finally {
      inkRepository.dispose();
    }
  }
}
