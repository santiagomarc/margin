import 'dart:typed_data';

/// A growable list of (x, y, pressure) triples backed by one [Float32List].
///
/// Capacity doubles when full, so adding a point allocates nothing in the
/// common case: the input hot path stays free of garbage.
class PointBuffer {
  PointBuffer([int initialPoints = 1024])
    : _data = Float32List(initialPoints * 3);

  Float32List _data;
  int _length = 0;

  /// Number of points.
  int get length => _length;
  bool get isEmpty => _length == 0;

  double x(int i) => _data[i * 3];
  double y(int i) => _data[i * 3 + 1];
  double pressure(int i) => _data[i * 3 + 2];

  void add(double x, double y, double pressure) {
    final offset = _length * 3;
    if (offset + 3 > _data.length) {
      _data = Float32List(_data.length * 2)..setRange(0, offset, _data);
    }
    _data[offset] = x;
    _data[offset + 1] = y;
    _data[offset + 2] = pressure;
    _length++;
  }

  void clear() => _length = 0;

  /// A copy of the points, sized exactly.
  Float32List toFloat32List() =>
      Float32List(_length * 3)..setRange(0, _length * 3, _data);
}
