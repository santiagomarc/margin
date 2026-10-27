import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/rendering.dart';

import '../db/page_background.dart';

/// Draws the page itself: white paper, the template as vectors (a few draw
/// calls, sharp at any zoom), a hairline border. Static, so its layer is
/// cached and costs nothing per frame.
class PaperPainter extends CustomPainter {
  PaperPainter({
    required this.template,
    required this.pageSize,
    required this.scale,
  });

  final PaperTemplate template;

  /// Page size in points.
  final Size pageSize;

  /// Screen pixels per page point.
  final double scale;

  static const _paper = Color(0xFFFFFFFF);
  static const _rule = Color(0xFFCFDDED);
  static const _marginRule = Color(0xFFF0C4C4);
  static const _dot = Color(0xFFB4C8DE);
  static const _border = Color(0xFFD9D4CB);

  /// Wide ruling (about 8.5 mm): finger handwriting is large.
  static const lineSpacing = 24.0;
  static const firstLine = 72.0;
  static const marginLine = 60.0;

  /// Grid and dot spacing (about 6.4 mm).
  static const gridStep = 18.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _paper);
    canvas.save();
    canvas.scale(scale);
    final hairline = 1 / scale;
    switch (template) {
      case PaperTemplate.lined:
        _lined(canvas, hairline);
      case PaperTemplate.grid:
        _grid(canvas, hairline);
      case PaperTemplate.dotted:
        _dotted(canvas);
      case PaperTemplate.blank:
        break;
    }
    canvas.restore();
    canvas.drawRect(
      (Offset.zero & size).deflate(0.5),
      Paint()
        ..color = _border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _lined(Canvas canvas, double hairline) {
    final lines = <double>[
      for (var y = firstLine; y < pageSize.height - 24; y += lineSpacing) ...[
        0,
        y,
        pageSize.width,
        y,
      ],
    ];
    _drawLines(canvas, lines, _rule, hairline);
    _drawLines(
      canvas,
      [marginLine, 0, marginLine, pageSize.height],
      _marginRule,
      hairline,
    );
  }

  void _grid(Canvas canvas, double hairline) {
    final lines = <double>[
      for (var y = gridStep; y < pageSize.height; y += gridStep) ...[
        0,
        y,
        pageSize.width,
        y,
      ],
      for (var x = gridStep; x < pageSize.width; x += gridStep) ...[
        x,
        0,
        x,
        pageSize.height,
      ],
    ];
    _drawLines(canvas, lines, _rule, hairline);
  }

  void _dotted(Canvas canvas) {
    final dots = <double>[
      for (var y = gridStep; y < pageSize.height; y += gridStep)
        for (var x = gridStep; x < pageSize.width; x += gridStep) ...[x, y],
    ];
    // One draw call for every dot: round caps make each point a circle.
    canvas.drawRawPoints(
      PointMode.points,
      Float32List.fromList(dots),
      Paint()
        ..color = _dot
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Draws line segments (x0, y0, x1, y1 repeated) in one call.
  void _drawLines(
    Canvas canvas,
    List<double> segments,
    Color color,
    double width,
  ) {
    canvas.drawRawPoints(
      PointMode.lines,
      Float32List.fromList(segments),
      Paint()
        ..color = color
        ..strokeWidth = width,
    );
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) =>
      oldDelegate.template != template ||
      oldDelegate.pageSize != pageSize ||
      oldDelegate.scale != scale;
}
