import '../canvas/ink_stroke.dart';
import '../canvas/live_layer.dart';
import '../canvas/stroke_geometry.dart';
import '../db/ids.dart';
import '../db/tables.dart';

/// The pen: feeds finger samples into the live stroke and turns the result
/// into a finished [InkStroke] when the finger lifts.
class PenTool {
  PenTool({
    required this.live,
    required this.onCommit,
    this.color = defaultColor,
    this.size = defaultSize,
  });

  /// "Ink black" from docs/PLAN.md, "Tool defaults".
  static const defaultColor = 0xFF1F2328;

  /// The middle size preset, in page points.
  static const defaultSize = 2.5;

  final LiveStroke live;
  final void Function(InkStroke stroke) onCommit;
  int color;
  double size;

  final SpeedPressure _pressure = SpeedPressure();
  double _lastX = double.nan;
  double _lastY = double.nan;

  /// Positions are in page points; [micros] is the event timestamp.
  void start(double x, double y, int micros) {
    _pressure.reset();
    live.begin(color: color, size: size);
    _add(x, y, micros);
  }

  void update(double x, double y, int micros) {
    // Android repeats the last position on some frames; skip duplicates.
    if (x == _lastX && y == _lastY) return;
    _add(x, y, micros);
  }

  void end() {
    if (live.points.isEmpty) return;
    final settled = settleStroke(live.points, size);
    final points = simplifyStroke(settled, simplifyTolerance);
    final stroke = InkStroke(
      id: newId(),
      tool: StrokeTool.pen,
      color: color,
      size: size,
      points: points,
      bounds: strokeBounds(points, size),
      createdAt: nextTimestamp(),
    );
    live.clear();
    onCommit(stroke);
  }

  void cancel() => live.clear();

  void _add(double x, double y, int micros) {
    _lastX = x;
    _lastY = y;
    live.add(x, y, _pressure.next(x, y, micros));
  }
}
