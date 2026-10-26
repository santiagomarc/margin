import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../diagnostics/cost_meter.dart';
import 'point_buffer.dart';
import 'stroke_geometry.dart';

/// The stroke being written. Only this layer repaints while a finger moves.
class LiveStroke extends ChangeNotifier {
  final PointBuffer points = PointBuffer();
  int color = 0xFF000000;
  double size = 2.5;

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
  LivePainter(this.live, this.scale, {this.cost}) : super(repaint: live);

  final LiveStroke live;

  /// Screen pixels per page point.
  final double scale;

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
    canvas.scale(scale);
    canvas.drawPath(path, _paint..color = Color(live.color));
  }

  @override
  bool shouldRepaint(LivePainter oldDelegate) =>
      oldDelegate.live != live || oldDelegate.scale != scale;
}
