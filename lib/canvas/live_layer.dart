import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../diagnostics/cost_meter.dart';
import 'point_buffer.dart';
import 'stroke_geometry.dart';

/// The stroke being written. Only this layer repaints while a finger moves.
///
/// One overlay above the page list draws it, placed over the page the stroke
/// started on (the list can't scroll while one finger writes).
class LiveStroke extends ChangeNotifier {
  final PointBuffer points = PointBuffer();
  int color = 0xFF000000;
  double size = 2.5;

  /// Top-left of the stroke's page in the overlay, in logical pixels.
  Offset origin = Offset.zero;

  /// The page's on-screen size; the stroke is clipped to it.
  Size clip = Size.zero;

  /// Screen pixels per page point.
  double scale = 1;

  /// Puts the overlay over the page a stroke is about to start on.
  void place(Offset origin, Size clip, double scale) {
    this.origin = origin;
    this.clip = clip;
    this.scale = scale;
  }

  void begin({required int color, required double size}) {
    this.color = color;
    this.size = size;
    points.clear();
  }

  void add(double x, double y, double pressure) {
    points.add(x, y, pressure);
    notifyListeners();
  }

  void clear() {
    points.clear();
    notifyListeners();
  }
}

class LivePainter extends CustomPainter {
  LivePainter(this.live, {this.cost}) : super(repaint: live);

  final LiveStroke live;

  /// Records how long building the outline takes (diagnostics).
  final CostMeter? cost;

  final Stopwatch _stopwatch = Stopwatch();
  final Paint _paint = Paint()..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    if (live.points.isEmpty) return;
    _stopwatch
      ..reset()
      ..start();
    final path = strokePath(
      live.points.toFloat32List(),
      live.size,
      complete: false,
    );
    cost?.record(_stopwatch.elapsedMicroseconds);
    canvas.translate(live.origin.dx, live.origin.dy);
    canvas.clipRect(Offset.zero & live.clip);
    canvas.scale(live.scale);
    canvas.drawPath(path, _paint..color = Color(live.color));
  }

  @override
  bool shouldRepaint(LivePainter oldDelegate) => oldDelegate.live != live;
}
