import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../canvas/page_viewport.dart';
import '../db/ink_repository.dart';
import '../db/notebook_repository.dart';
import '../diagnostics/app_log.dart';
import '../diagnostics/diagnostics.dart';
import '../diagnostics/diagnostics_overlay.dart';
import '../state/notebook_controller.dart';
import '../ui/dialogs.dart';
import '../ui/feedback_pill.dart';
import '../ui/notebook_toolbar.dart';
import 'app_scope.dart';

/// A notebook open for writing: its pages in a vertical list.
class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key, required this.notebookId, this.onClosed});

  final String notebookId;

  /// Called once everything has been saved after the screen goes away.
  final VoidCallback? onClosed;

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  NotebookController? _controller;
  AppLifecycleListener? _lifecycle;
  late AppLog _log;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final services = AppScope.of(context);
    _log = services.diagnostics.log;
    final controller = NotebookController(
      notebooks: NotebookRepository(
        services.db,
        widget.notebookId,
        now: services.now,
      ),
      inkRepository: InkRepository(
        services.db,
        notebookId: widget.notebookId,
        now: services.now,
      ),
      diagnostics: services.diagnostics,
    );
    _controller = controller;
    // Android may kill a backgrounded app without warning: save on the way.
    _lifecycle = AppLifecycleListener(onHide: _flush, onPause: _flush);
    controller.load().catchError((Object error, StackTrace stack) {
      services.diagnostics.log.error(error, stack);
    });
  }

  void _flush() => unawaited(_controller?.flush());

  @override
  void dispose() {
    _lifecycle?.dispose();
    final onClosed = widget.onClosed;
    unawaited(
      _controller?.close().then(
        (_) => onClosed?.call(),
        onError: (Object error, StackTrace stack) => _log.error(error, stack),
      ),
    );
    super.dispose();
  }

  Future<void> _rename() async {
    final controller = _controller!;
    final title = await showNameDialog(
      context,
      title: 'Rename notebook',
      initial: controller.title,
    );
    if (title != null) await controller.rename(title);
  }

  PageMenuState _pageMenu() {
    final controller = _controller!;
    return PageMenuState(
      current: controller.currentPage.value,
      count: controller.pages.length,
    );
  }

  Future<void> _onMore(MoreAction action) async {
    final controller = _controller!;
    final diagnostics = AppScope.of(context).diagnostics;
    final messenger = ScaffoldMessenger.of(context);
    final current = controller.currentPage.value;
    switch (action) {
      case MoreAction.addPage:
        controller.addPage();
      case MoreAction.movePageUp:
        controller.movePageBy(current, -1);
      case MoreAction.movePageDown:
        controller.movePageBy(current, 1);
      case MoreAction.deletePage:
        final command = controller.deletePage(current);
        if (command == null) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Page ${current + 1} deleted'),
              duration: const Duration(seconds: 5),
              // Undo snackbars would otherwise stay until dismissed.
              persist: false,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => controller.history.undoIfLast(command),
              ),
            ),
          );
      case MoreAction.toggleDiagnostics:
        diagnostics.overlayVisible.value = !diagnostics.overlayVisible.value;
      case MoreAction.copyBugReport:
        final report = diagnostics.bugReport(
          screen: ScreenInfo.of(View.of(context)),
          strokesOnPage: _strokesOnCurrentPage(),
        );
        await Clipboard.setData(ClipboardData(text: report));
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Bug report copied. Paste it into your next session.',
            ),
          ),
        );
    }
  }

  int? _strokesOnCurrentPage() {
    final controller = _controller!;
    if (controller.pages.isEmpty) return null;
    final index = controller.currentPage.value.clamp(
      0,
      controller.pages.length - 1,
    );
    return controller.ink.layerOf(controller.pages[index].id)?.length;
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller!;
    final diagnostics = AppScope.of(context).diagnostics;
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: diagnostics.overlayVisible,
          builder: (context, showDiagnostics, _) => Column(
            children: [
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => NotebookToolbar(
                  title: controller.title,
                  history: controller.history,
                  diagnosticsVisible: showDiagnostics,
                  pageMenu: _pageMenu,
                  onBack: () => Navigator.of(context).maybePop(),
                  onRename: _rename,
                  onUndo: controller.undo,
                  onRedo: controller.redo,
                  onMore: _onMore,
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ListenableBuilder(
                        listenable: controller,
                        builder: (context, child) =>
                            controller.isLoaded ? child! : const SizedBox(),
                        child: PageViewport(controller: controller),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: FeedbackPill(controller: controller.feedback),
                      ),
                    ),
                    if (showDiagnostics)
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: DiagnosticsOverlay(
                          diagnostics: diagnostics,
                          strokeCount: () => _strokesOnCurrentPage() ?? 0,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
