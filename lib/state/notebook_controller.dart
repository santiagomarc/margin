import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../canvas/ink_layer.dart';
import '../canvas/ink_stroke.dart';
import '../canvas/live_layer.dart';
import '../canvas/page_geometry.dart';
import '../db/database.dart';
import '../db/ink_repository.dart';
import '../diagnostics/diagnostics.dart';
import '../history/history.dart';
import '../history/stroke_commands.dart';
import '../input/input_router.dart';
import '../tools/pen_tool.dart';
import 'feedback_controller.dart';

/// State of the open notebook (for now: the scratch page) and the bridge
/// from classified input to tools, history and storage. Plain Dart: nothing
/// here rebuilds widgets while writing.
class NotebookController implements InputHandler {
  NotebookController({required this.repository, this.diagnostics}) {
    router = InputRouter(this, stats: diagnostics?.touch);
    pen = PenTool(live: live, onCommit: _commit);
  }

  final InkRepository repository;
  final Diagnostics? diagnostics;

  final InkLayerController ink = InkLayerController();
  final LiveStroke live = LiveStroke();
  final History history = History();
  final FeedbackController feedback = FeedbackController();

  /// Vertical scroll of the page, in logical pixels.
  final ValueNotifier<double> scroll = ValueNotifier(0);

  /// Set by the page viewport on every layout.
  PageGeometry geometry = PageGeometry.zero;

  late final InputRouter router;
  late final PenTool pen;

  NotebookPage? _page;
  NotebookPage? get page => _page;

  Future<void> load() async {
    final page = await repository.ensureScratchPage();
    final strokes = await repository.loadStrokes(page.id);
    _page = page;
    ink.setAll(strokes);
  }

  Size get pageSize =>
      _page == null ? InkRepository.a4 : Size(_page!.width, _page!.height);

  void undo() {
    feedback.show(history.undo() ? 'Undo' : 'Nothing to undo');
  }

  void redo() {
    feedback.show(history.redo() ? 'Redo' : 'Nothing to redo');
  }

  Future<void> flush() => repository.flush();

  void _commit(InkStroke stroke) {
    final page = _page;
    if (page == null) return;
    history.execute(
      AddStrokeCommand(
        ink: ink,
        repository: repository,
        pageId: page.id,
        stroke: stroke,
      ),
    );
  }

  // Page coordinates without allocating: called for every pointer sample.
  double _pageX(Offset p) => (p.dx - geometry.sideMargin) / geometry.scale;
  double _pageY(Offset p) =>
      (p.dy + geometry.clampScroll(scroll.value) - geometry.topMargin) /
      geometry.scale;

  @override
  bool canStartStroke(Offset position) {
    if (_page == null || geometry.viewport.isEmpty) return false;
    final x = _pageX(position), y = _pageY(position);
    return x >= 0 && y >= 0 && x <= pageSize.width && y <= pageSize.height;
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
    scroll.value = geometry.clampScroll(scroll.value - delta.dy);
  }

  /// Releases everything and saves pending writes.
  Future<void> close() async {
    feedback.dispose();
    ink.dispose();
    live.dispose();
    history.dispose();
    scroll.dispose();
    await repository.flush();
    repository.dispose();
  }
}
