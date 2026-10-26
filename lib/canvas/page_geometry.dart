import 'dart:math' as math;
import 'dart:ui';

/// Where the page sits in the viewport, and conversions between viewport and
/// page coordinates. Pages fit the viewport width.
class PageGeometry {
  const PageGeometry({
    required this.viewport,
    required this.pageSize,
    this.sideMargin = 24,
    this.topMargin = 16,
    this.bottomMargin = 32,
  });

  static const zero = PageGeometry(viewport: Size.zero, pageSize: Size.zero);

  final Size viewport;

  /// Page size in points.
  final Size pageSize;
  final double sideMargin;
  final double topMargin;
  final double bottomMargin;

  /// Screen pixels per page point.
  double get scale => pageSize.width == 0
      ? 1
      : math.max(0.1, (viewport.width - 2 * sideMargin) / pageSize.width);

  Size get displaySize => pageSize * scale;

  /// Top-left of the page in the viewport, before scrolling.
  Offset get pageOrigin => Offset(sideMargin, topMargin);

  double get contentHeight => topMargin + displaySize.height + bottomMargin;

  double get maxScroll => math.max(0, contentHeight - viewport.height);

  double clampScroll(double scroll) => scroll.clamp(0.0, maxScroll);

  Offset toPage(Offset viewportPoint, double scroll) =>
      (viewportPoint + Offset(0, scroll) - pageOrigin) / scale;

  bool containsPagePoint(Offset pagePoint) =>
      (Offset.zero & pageSize).contains(pagePoint);
}
