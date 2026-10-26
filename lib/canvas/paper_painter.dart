import 'package:flutter/rendering.dart';

import '../db/page_background.dart';

/// Draws the page itself: white paper, the template's lines, a hairline
/// border. Static, so its layer is cached and costs nothing per frame.
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
  static const _border = Color(0xFFD9D4CB);

  /// Wide ruling (about 8.5 mm): finger handwriting is large.
  static const lineSpacing = 24.0;
  static const firstLine = 72.0;
  static const marginLine = 60.0;

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
    final rule = Paint()
      ..color = _rule
      ..strokeWidth = hairline;
    for (var y = firstLine; y < pageSize.height - 24; y += lineSpacing) {
      canvas.drawLine(Offset(0, y), Offset(pageSize.width, y), rule);
    }
    canvas.drawLine(
      const Offset(marginLine, 0),
      Offset(marginLine, pageSize.height),
      Paint()
        ..color = _marginRule
        ..strokeWidth = hairline,
    );
  }

  void _grid(Canvas canvas, double hairline) {
    final rule = Paint()
      ..color = _rule
      ..strokeWidth = hairline;
    const step = 18.0;
    for (var y = step; y < pageSize.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(pageSize.width, y), rule);
    }
    for (var x = step; x < pageSize.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, pageSize.height), rule);
    }
  }

  void _dotted(Canvas canvas) {
    final dot = Paint()..color = _rule;
    const step = 18.0;
    for (var y = step; y < pageSize.height; y += step) {
      for (var x = step; x < pageSize.width; x += step) {
        canvas.drawCircle(Offset(x, y), 0.9, dot);
      }
    }
  }

  @override
  bool shouldRepaint(PaperPainter oldDelegate) =>
      oldDelegate.template != template ||
      oldDelegate.pageSize != pageSize ||
      oldDelegate.scale != scale;
}
