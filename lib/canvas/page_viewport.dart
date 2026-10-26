import 'package:flutter/widgets.dart';

import '../db/page_background.dart';
import '../state/notebook_controller.dart';
import 'ink_layer.dart';
import 'live_layer.dart';
import 'page_geometry.dart';
import 'paper_painter.dart';

/// One page, fitted to the width, with its layer stack: paper, ink, live
/// stroke. Each layer has its own RepaintBoundary, so a moving finger only
/// repaints the live layer.
class PageViewport extends StatelessWidget {
  const PageViewport({
    super.key,
    required this.controller,
    this.template = PaperTemplate.lined,
  });

  final NotebookController controller;
  final PaperTemplate template;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final geometry = PageGeometry(
          viewport: constraints.biggest,
          pageSize: controller.pageSize,
        );
        controller.geometry = geometry;
        final scale = geometry.scale;
        final cost = controller.diagnostics?.liveOutlineCost;

        final page = SizedBox.fromSize(
          size: geometry.displaySize,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: PaperPainter(
                      template: template,
                      pageSize: geometry.pageSize,
                      scale: scale,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: InkPainter(controller.ink, scale),
                    isComplex: true,
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: LivePainter(controller.live, scale, cost: cost),
                  ),
                ),
              ],
            ),
          ),
        );

        return Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: controller.router.handle,
          onPointerMove: controller.router.handle,
          onPointerUp: controller.router.handle,
          onPointerCancel: controller.router.handle,
          child: ClipRect(
            child: ValueListenableBuilder<double>(
              valueListenable: controller.scroll,
              builder: (context, scroll, child) => Transform.translate(
                offset: Offset(0, -geometry.clampScroll(scroll)),
                child: child,
              ),
              // The page is taller than the viewport: let it overflow, then
              // scroll it with the transform above.
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: 0,
                maxWidth: double.infinity,
                minHeight: 0,
                maxHeight: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: geometry.sideMargin,
                    top: geometry.topMargin,
                  ),
                  child: page,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
