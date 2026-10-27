import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:margin/canvas/page_layout.dart';
import 'package:margin/db/page_background.dart';

void main() {
  // T3 10 in landscape, below the 56 dp toolbar.
  const viewport = Size(1280, 744);
  final layout = PageLayout(
    viewport: viewport,
    pageSizes: const [PageSizes.a4, PageSizes.letter, PageSizes.a4],
  );

  test('pages fit the width between the side margins', () {
    expect(layout.scaleOf(0), closeTo((1280 - 48) / 595.28, 1e-9));
    expect(layout.scaleOf(1), closeTo((1280 - 48) / 612, 1e-9));
    expect(layout.displaySizeOf(0).width, closeTo(1232, 1e-9));
    expect(layout.displaySizeOf(1).width, closeTo(1232, 1e-9));
  });

  test('extents and tops add up, with a gap below each page', () {
    final h0 = layout.displaySizeOf(0).height;
    final h1 = layout.displaySizeOf(1).height;
    expect(layout.extentOf(0), h0 + 16);
    expect(layout.topOf(0), 16);
    expect(layout.topOf(1), 16 + h0 + 16);
    expect(layout.topOf(2), 16 + h0 + 16 + h1 + 16);
    expect(
      layout.contentHeight,
      layout.topOf(2) + layout.extentOf(2) + 96 + 32,
    );
    expect(layout.maxScroll, layout.contentHeight - viewport.height);
  });

  test('finds the page under a point, and nothing in margins or gaps', () {
    final top1 = layout.topOf(1);
    expect(layout.pageContaining(100, top1 + 10), 1);
    expect(layout.pageContaining(10, top1 + 10), -1, reason: 'side margin');
    expect(layout.pageContaining(100, top1 - 8), -1, reason: 'gap');
    expect(layout.pageContaining(100, 8), -1, reason: 'top padding');
    expect(layout.pageContaining(100, layout.contentHeight - 10), -1);
    expect(layout.pageAt(top1 - 8), 0);
    expect(layout.pageAt(-50), 0);
    expect(layout.pageAt(1e9), 2);
  });

  test('scrolling to a page puts it at the top, clamped at the end', () {
    expect(layout.scrollToPage(0), 0);
    expect(layout.scrollToPage(1), layout.topOf(1) - 16);
    expect(layout.scrollToPage(2), lessThanOrEqualTo(layout.maxScroll));
    expect(layout.currentPage(layout.scrollToPage(1)), 1);
  });

  test('an empty notebook has no pages', () {
    expect(PageLayout.empty.length, 0);
    expect(PageLayout.empty.pageAt(10), -1);
    expect(PageLayout.empty.pageContaining(10, 10), -1);
  });
}
