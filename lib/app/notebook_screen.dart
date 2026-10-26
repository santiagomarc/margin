import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../canvas/page_viewport.dart';
import '../db/ink_repository.dart';
import '../diagnostics/diagnostics.dart';
import '../diagnostics/diagnostics_overlay.dart';
import '../state/notebook_controller.dart';
import '../ui/feedback_pill.dart';
import '../ui/notebook_toolbar.dart';
import 'app_scope.dart';

/// A notebook open for writing. For now always the scratch page.
class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  NotebookController? _controller;
  AppLifecycleListener? _lifecycle;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final services = AppScope.of(context);
    final controller = NotebookController(
      repository: InkRepository(services.db),
      diagnostics: services.diagnostics,
    );
    _controller = controller;
    // Android may kill a backgrounded app without warning: save on the way.
    _lifecycle = AppLifecycleListener(onHide: _flush, onPause: _flush);
    controller.load().then(
      (_) {
        if (mounted) setState(() => _loaded = true);
      },
      onError: (Object error, StackTrace stack) {
        services.diagnostics.log.error(error, stack);
      },
    );
  }

  void _flush() => unawaited(_controller?.flush());

  @override
  void dispose() {
    _lifecycle?.dispose();
    unawaited(_controller?.close());
    super.dispose();
  }

  Future<void> _onMore(MoreAction action) async {
    final diagnostics = AppScope.of(context).diagnostics;
    switch (action) {
      case MoreAction.toggleDiagnostics:
        diagnostics.overlayVisible.value = !diagnostics.overlayVisible.value;
      case MoreAction.copyBugReport:
        final report = diagnostics.bugReport(
          screen: ScreenInfo.of(View.of(context)),
          strokesOnPage: _controller?.ink.length,
        );
        final messenger = ScaffoldMessenger.of(context);
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
              NotebookToolbar(
                title: 'Scratch page',
                history: controller.history,
                diagnosticsVisible: showDiagnostics,
                onBack: () => Navigator.of(context).maybePop(),
                onUndo: controller.undo,
                onRedo: controller.redo,
                onMore: _onMore,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _loaded
                          ? PageViewport(controller: controller)
                          : const SizedBox.shrink(),
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
                          strokeCount: () => controller.ink.length,
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
