import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:perfect_freehand/perfect_freehand.dart';

import 'point_buffer.dart';

/// How much the live stroke is smoothed (perfect_freehand `streamline`).
///
/// Flutter on Android only delivers the newest touch position per event, so
/// samples are sparse; streamlining hides the resulting corners.
const double penStreamline = 0.45;

/// How much pressure changes the width (perfect_freehand `thinning`).
const double penThinning = 0.55;

/// Simplification tolerance in page points (about 0.035 mm).
const double simplifyTolerance = 0.1;

/// Turns finger speed into pressure: slow writing gives a fuller line, fast
/// writing a thinner one. A finger reports no real pressure.
class SpeedPressure {
  SpeedPressure({
    this.maxSpeed = 1.2,
    this.slowPressure = 0.9,
    this.fastPressure = 0.3,
    this.smoothing = 0.3,
    this.initialPressure = 0.6,
  });

  /// Speed, in page points per millisecond, at which the line is thinnest.
  final double maxSpeed;
  final double slowPressure;
  final double fastPressure;

  /// Fraction of the way the pressure moves toward its target per sample.
  final double smoothing;
  final double initialPressure;

  double _pressure = 0;
  double _lastX = 0;
  double _lastY = 0;
  int _lastMicros = 0;
  bool _started = false;

  void reset() => _started = false;

  /// Pressure for a sample at ([x], [y]) in page points at [micros].
  double next(double x, double y, int micros) {
    if (!_started) {
      _started = true;
      _pressure = initialPressure;
    } else {
      final dt = (micros - _lastMicros) / 1000.0;
      if (dt > 0) {
        final dx = x - _lastX;
        final dy = y - _lastY;
        final speed = math.sqrt(dx * dx + dy * dy) / dt;
        final t = (speed / maxSpeed).clamp(0.0, 1.0);
        final target = slowPressure + (fastPressure - slowPressure) * t;
        _pressure += (target - _pressure) * smoothing;
      }
    }
    _lastX = x;
    _lastY = y;
    _lastMicros = micros;
    return _pressure;
  }
}

StrokeOptions penOptions(
  double size, {
  required bool complete,
  double streamline = penStreamline,
}) {
  return StrokeOptions(
    size: size,
    thinning: penThinning,
    smoothing: 0.5,
    streamline: streamline,
    simulatePressure: false,
    isComplete: complete,
  );
}

/// Whether every point sits where the first one is (a tap). perfect_freehand
/// draws nothing for repeated positions with different pressures, so such
/// strokes are collapsed to one point, which it draws as a dot.
bool _isDot(Float32List points) {
  for (var i = 3; i < points.length; i += 3) {
    if (points[i] != points[0] || points[i + 1] != points[1]) return false;
  }
  return true;
}

List<PointVector> _vectors(Float32List points) {
  if (_isDot(points) && points.length > 3) {
    return [PointVector(points[0], points[1], points[2])];
  }
  final count = points.length ~/ 3;
  return List<PointVector>.generate(
    count,
    (i) => PointVector(points[i * 3], points[i * 3 + 1], points[i * 3 + 2]),
    growable: false,
  );
}

/// Applies perfect_freehand's smoothing to the raw points of a finished
/// stroke. Storing these points means the saved stroke renders exactly like
/// the live one did (render them with `streamline: 0`).
Float32List settleStroke(PointBuffer raw, double size) {
  final settled = getStrokePoints(
    _vectors(raw.toFloat32List()),
    options: penOptions(size, complete: true),
  );
  final out = Float32List(settled.length * 3);
  for (var i = 0; i < settled.length; i++) {
    out[i * 3] = settled[i].point.x;
    out[i * 3 + 1] = settled[i].point.y;
    out[i * 3 + 2] = settled[i].pressure;
  }
  return out;
}

/// Ramer–Douglas–Peucker simplification of (x, y, pressure) triples.
///
/// Drops points that lie within [tolerance] of the line through their
/// neighbours. Endpoints are always kept; kept points keep their pressure.
Float32List simplifyStroke(Float32List points, double tolerance) {
  final count = points.length ~/ 3;
  if (count < 3) return Float32List.fromList(points);

  final keep = Uint8List(count);
  keep[0] = 1;
  keep[count - 1] = 1;
  final tolerance2 = tolerance * tolerance;
  final stack = <int>[0, count - 1];
  while (stack.isNotEmpty) {
    final last = stack.removeLast();
    final first = stack.removeLast();
    var maxDistance2 = 0.0;
    var index = -1;
    for (var i = first + 1; i < last; i++) {
      final d2 = _segmentDistance2(points, i, first, last);
      if (d2 > maxDistance2) {
        maxDistance2 = d2;
        index = i;
      }
    }
    if (index != -1 && maxDistance2 > tolerance2) {
      keep[index] = 1;
      stack
        ..add(first)
        ..add(index)
        ..add(index)
        ..add(last);
    }
  }

  var kept = 0;
  for (final k in keep) {
    kept += k;
  }
  final out = Float32List(kept * 3);
  var o = 0;
  for (var i = 0; i < count; i++) {
    if (keep[i] == 0) continue;
    out[o++] = points[i * 3];
    out[o++] = points[i * 3 + 1];
    out[o++] = points[i * 3 + 2];
  }
  return out;
}

/// Squared distance from point [p] to segment [a]–[b] (indices into triples).
double _segmentDistance2(Float32List pts, int p, int a, int b) {
  final px = pts[p * 3], py = pts[p * 3 + 1];
  final ax = pts[a * 3], ay = pts[a * 3 + 1];
  final bx = pts[b * 3], by = pts[b * 3 + 1];
  final dx = bx - ax, dy = by - ay;
  final length2 = dx * dx + dy * dy;
  var t = length2 == 0 ? 0.0 : ((px - ax) * dx + (py - ay) * dy) / length2;
  t = t.clamp(0.0, 1.0);
  final cx = ax + t * dx - px, cy = ay + t * dy - py;
  return cx * cx + cy * cy;
}

/// Bounding box of the points, grown by [pad] on every side.
Rect strokeBounds(Float32List points, double pad) {
  if (points.isEmpty) return Rect.zero;
  var minX = points[0], maxX = points[0];
  var minY = points[1], maxY = points[1];
  for (var i = 3; i < points.length; i += 3) {
    minX = math.min(minX, points[i]);
    maxX = math.max(maxX, points[i]);
    minY = math.min(minY, points[i + 1]);
    maxY = math.max(maxY, points[i + 1]);
  }
  return Rect.fromLTRB(minX - pad, minY - pad, maxX + pad, maxY + pad);
}

/// Filled outline of a stroke, in the points' coordinates.
Path strokePath(
  Float32List points,
  double size, {
  required bool complete,
  double streamline = penStreamline,
}) {
  final outline = getStroke(
    _vectors(points),
    options: penOptions(size, complete: complete, streamline: streamline),
  );
  return outlinePath(outline);
}

/// Smooth closed path through outline points, using quadratic curves between
/// midpoints (the standard perfect_freehand rendering).
Path outlinePath(List<Offset> outline) {
  final path = Path();
  if (outline.isEmpty) return path;
  path.moveTo(outline.first.dx, outline.first.dy);
  for (var i = 0; i < outline.length - 1; i++) {
    final a = outline[i];
    final b = outline[i + 1];
    path.quadraticBezierTo(a.dx, a.dy, (a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
  }
  path.close();
  return path;
}
