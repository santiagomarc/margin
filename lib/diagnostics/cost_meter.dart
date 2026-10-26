import 'dart:typed_data';

/// Rolling record of how long something takes (microseconds), e.g. building
/// the live stroke outline each frame.
class CostMeter {
  CostMeter([int window = 120]) : _samples = Int32List(window);

  final Int32List _samples;
  int _count = 0;
  int _next = 0;

  int last = 0;

  void record(int micros) {
    last = micros;
    _samples[_next] = micros;
    _next = (_next + 1) % _samples.length;
    if (_count < _samples.length) _count++;
  }

  int get count => _count;

  int get max {
    var m = 0;
    for (var i = 0; i < _count; i++) {
      if (_samples[i] > m) m = _samples[i];
    }
    return m;
  }

  double get average {
    if (_count == 0) return 0;
    var sum = 0;
    for (var i = 0; i < _count; i++) {
      sum += _samples[i];
    }
    return sum / _count;
  }
}
