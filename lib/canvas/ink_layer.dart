import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'ink_stroke.dart';

/// Finished strokes of one page, cached as a single [ui.Picture].
///
/// The picture is re-recorded only when strokes change, never while a stroke
/// is being written.
class InkLayerController extends ChangeNotifier {
  final List<InkStroke> _strokes = [];
  ui.Picture? _picture;

  List<InkStroke> get strokes => List.unmodifiable(_strokes);
  int get length => _strokes.length;

  void setAll(Iterable<InkStroke> strokes) {
    _strokes
      ..clear()
      ..addAll(strokes)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _invalidate();
  }

  /// Inserts [stroke] in draw order (by `createdAt`).
  void add(InkStroke stroke) {
    var i = _strokes.length;
    while (i > 0 && _strokes[i - 1].createdAt.isAfter(stroke.createdAt)) {
      i--;
    }
    _strokes.insert(i, stroke);
    _invalidate();
  }

  bool remove(String id) {
    final i = _strokes.indexWhere((s) => s.id == id);
    if (i == -1) return false;
    _strokes.removeAt(i);
    _invalidate();
    return true;
  }

  /// All strokes, recorded in page coordinates.
  ui.Picture get picture => _picture ??= _record();

  ui.Picture _record() {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;
    for (final stroke in _strokes) {
      paint.color = Color(stroke.color);
      canvas.drawPath(stroke.path, paint);
    }
    return recorder.endRecording();
  }

  void _invalidate() {
    _picture?.dispose();
    _picture = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _picture?.dispose();
    super.dispose();
  }
}

class InkPainter extends CustomPainter {
  InkPainter(this.controller, this.scale) : super(repaint: controller);

  final InkLayerController controller;

  /// Screen pixels per page point.
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (controller.length == 0) return;
    canvas.scale(scale);
    canvas.drawPicture(controller.picture);
  }

  @override
  bool shouldRepaint(InkPainter oldDelegate) =>
      oldDelegate.controller != controller || oldDelegate.scale != scale;
}
