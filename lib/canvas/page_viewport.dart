import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../db/database.dart';
import '../state/notebook_controller.dart';
import '../ui/theme.dart';
import 'ink_layer.dart';
import 'live_layer.dart';
import 'page_layout.dart';
import 'paper_painter.dart';

/// The notebook's pages in a vertical list, fitted to the width, with fixed
/// extents from the page sizes.
///
/// A raw [Listener] feeds every touch to the input router: one finger
/// writes, two fingers scroll the list (its own drag is turned off). The
/// live stroke is one overlay above the list, so writing repaints only it.
class PageViewport extends StatelessWidget {
  const PageViewport({super.key, required this.controller});

  final NotebookController controller;

  @override
  Widget build(BuildContext context) {
    final cost = controller.diagnostics?.liveOutlineCost;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final pages = controller.pages;
          final layout = PageLayout(
            viewport: constraints.biggest,
            pageSizes: controller.pageSizes,
          );
          controller.updateLayout(layout);
          return Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: controller.router.handle,
            onPointerMove: controller.router.handle,
            onPointerUp: controller.router.handle,
            onPointerCancel: controller.router.handle,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ScrollConfiguration(
                  behavior: const _NoDragScrollBehavior(),
                  child: ListView.builder(
                    controller: controller.scrollController(),
                    padding: EdgeInsets.only(
                      top: layout.topPadding,
                      bottom: layout.bottomPadding,
                    ),
                    // Pages more than about a screen away are disposed, which
                    // releases their strokes and cached pictures.
                    scrollCacheExtent: const ScrollCacheExtent.viewport(1),
                    itemCount: pages.length + 1,
                    itemExtentBuilder: (index, _) {
                      if (index < pages.length) return layout.extentOf(index);
                      if (index == pages.length) return layout.footerExtent;
                      return null;
                    },
                    findChildIndexCallback: (key) {
                      if (key is! ValueKey<String>) return null;
                      final index = pages.indexWhere((p) => p.id == key.value);
                      return index < 0 ? null : index;
                    },
                    itemBuilder: (context, index) {
                      if (index == pages.length) {
                        return _AddPageFooter(onAdd: controller.addPage);
                      }
                      return PageTile(
                        key: ValueKey(pages[index].id),
                        controller: controller,
                        page: pages[index],
                        displaySize: layout.displaySizeOf(index),
                        scale: layout.scaleOf(index),
                        sideMargin: layout.sideMargin,
                      );
                    },
                  ),
                ),
                IgnorePointer(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: LivePainter(controller.live, cost: cost),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One page with its layer stack: paper, then ink. Holds the page's ink
/// only while it is built (near the screen).
class PageTile extends StatefulWidget {
  const PageTile({
    super.key,
    required this.controller,
    required this.page,
    required this.displaySize,
    required this.scale,
    required this.sideMargin,
  });

  final NotebookController controller;
  final NotebookPage page;
  final Size displaySize;
  final double scale;
  final double sideMargin;

  @override
  State<PageTile> createState() => _PageTileState();
}

class _PageTileState extends State<PageTile> {
  late InkLayerController _ink;

  @override
  void initState() {
    super.initState();
    _ink = widget.controller.ink.attach(widget.page.id);
  }

  @override
  void didUpdateWidget(PageTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.id != widget.page.id) {
      widget.controller.ink.release(oldWidget.page.id);
      _ink = widget.controller.ink.attach(widget.page.id);
    }
  }

  @override
  void dispose() {
    widget.controller.ink.release(widget.page.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final background = page.background;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: widget.sideMargin),
        child: SizedBox.fromSize(
          size: widget.displaySize,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                RepaintBoundary(
                  child: CustomPaint(
                    painter: PaperPainter(
                      template: background is TemplateBackground
                          ? background.template
                          : PaperTemplate.blank,
                      pageSize: Size(page.width, page.height),
                      scale: widget.scale,
                    ),
                  ),
                ),
                RepaintBoundary(
                  child: CustomPaint(
                    painter: InkPainter(_ink, widget.scale),
                    isComplex: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPageFooter extends StatelessWidget {
  const _AddPageFooter({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Add page'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(160, 48),
          foregroundColor: MarginColors.ink,
          side: const BorderSide(color: MarginColors.divider),
        ),
      ),
    );
  }
}

/// No drag scrolling from any device: the input router scrolls the list
/// with two fingers, and one finger always writes.
class _NoDragScrollBehavior extends MaterialScrollBehavior {
  const _NoDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {};

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;
}
