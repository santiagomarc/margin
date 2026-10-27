import 'dart:math' as math;
import 'dart:ui';

/// Where every page of a notebook sits in the vertical page list, from the
/// page sizes alone, so the list can use fixed extents: jumping to page 150
/// is instant and needs nothing rendered.
///
/// Content coordinates are the list's scroll coordinates: content y =
/// scroll offset + viewport y.
class PageLayout {
  PageLayout({
    required this.viewport,
    required List<Size> pageSizes,
    this.sideMargin = 24,
    this.gap = 16,
    this.topPadding = 16,
    this.footerExtent = 96,
    this.bottomPadding = 32,
  }) : pageSizes = List.unmodifiable(pageSizes) {
    final width = math.max(1.0, viewport.width - 2 * sideMargin);
    var top = topPadding;
    for (final size in this.pageSizes) {
      final scale = size.width <= 0 ? 1.0 : width / size.width;
      _scales.add(scale);
      _tops.add(top);
      _heights.add(size.height * scale);
      top += size.height * scale + gap;
    }
    _pagesEnd = top;
  }

  static final empty = PageLayout(viewport: Size.zero, pageSizes: const []);

  final Size viewport;

  /// Page sizes in points, in page order.
  final List<Size> pageSizes;
  final double sideMargin;

  /// Space below each page.
  final double gap;
  final double topPadding;

  /// The "Add page" button after the last page.
  final double footerExtent;
  final double bottomPadding;

  final List<double> _scales = [];
  final List<double> _tops = [];
  final List<double> _heights = [];
  late final double _pagesEnd;

  int get length => pageSizes.length;

  /// Screen pixels per page point for page [index] (pages fit the width).
  double scaleOf(int index) => _scales[index];

  Size displaySizeOf(int index) => pageSizes[index] * _scales[index];

  /// The list item extent of page [index]: the page and the gap below it.
  double extentOf(int index) => _heights[index] + gap;

  /// Top of page [index] in content coordinates.
  double topOf(int index) => _tops[index];

  /// Page [index] in content coordinates.
  Rect rectOf(int index) => Rect.fromLTWH(
    sideMargin,
    _tops[index],
    viewport.width - 2 * sideMargin,
    _heights[index],
  );

  double get contentHeight => _pagesEnd + footerExtent + bottomPadding;

  double get maxScroll => math.max(0, contentHeight - viewport.height);

  double clampScroll(double offset) => offset.clamp(0.0, maxScroll);

  /// The scroll offset that puts page [index] at the top of the viewport.
  double scrollToPage(int index) => clampScroll(_tops[index] - topPadding);

  /// The page whose item (page plus gap) contains [contentY]; the nearest
  /// page above or below when outside every page. -1 when there are none.
  int pageAt(double contentY) {
    if (_tops.isEmpty) return -1;
    var lo = 0, hi = _tops.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_tops[mid] <= contentY) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    return lo;
  }

  /// The page under a point in content coordinates, or -1 (margins, gaps,
  /// the footer).
  int pageContaining(double contentX, double contentY) {
    final index = pageAt(contentY);
    if (index < 0) return -1;
    final top = _tops[index];
    if (contentY < top || contentY > top + _heights[index]) return -1;
    if (contentX < sideMargin || contentX > viewport.width - sideMargin) {
      return -1;
    }
    return index;
  }

  /// The page considered "current" at [scrollOffset]: the one under a line
  /// a third of the way down the viewport.
  int currentPage(double scrollOffset) =>
      pageAt(scrollOffset + viewport.height / 3);
}
