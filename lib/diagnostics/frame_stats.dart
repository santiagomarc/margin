import 'dart:typed_data';

import 'package:flutter/scheduler.dart';

/// Frame timings from the engine (build and raster time of the last
/// [window] frames). In release builds the engine reports them in batches.
class FrameStats {
  FrameStats([this.window = 240])
    : _build = Int32List(window),
      _raster = Int32List(window),
      _total = Int32List(window);

  final int window;
  final Int32List _build;
  final Int32List _raster;
  final Int32List _total;
  int _count = 0;
  int _next = 0;
  bool _attached = false;

  void attach() {
    if (_attached) return;
    _attached = true;
    SchedulerBinding.instance.addTimingsCallback(_onTimings);
  }

  void detach() {
    if (!_attached) return;
    _attached = false;
    SchedulerBinding.instance.removeTimingsCallback(_onTimings);
  }

  void _onTimings(List<FrameTiming> timings) {
    for (final t in timings) {
      add(
        t.buildDuration.inMicroseconds,
        t.rasterDuration.inMicroseconds,
        t.totalSpan.inMicroseconds,
      );
    }
  }

  /// Records one frame; all values in microseconds.
  void add(int build, int raster, int total) {
    _build[_next] = build;
    _raster[_next] = raster;
    _total[_next] = total;
    _next = (_next + 1) % window;
    if (_count < window) _count++;
  }

  FrameSummary summary() => FrameSummary(
    count: _count,
    build: Percentiles.of(_build, _count),
    raster: Percentiles.of(_raster, _count),
    total: Percentiles.of(_total, _count),
    slow: _countOver(_total, 16667),
    janky: _countOver(_total, 33333),
  );

  int _countOver(Int32List values, int micros) {
    var n = 0;
    for (var i = 0; i < _count; i++) {
      if (values[i] > micros) n++;
    }
    return n;
  }
}

/// Percentiles in milliseconds.
class Percentiles {
  const Percentiles(this.p50, this.p90, this.p99, this.max);

  factory Percentiles.of(Int32List micros, int count) {
    if (count == 0) return const Percentiles(0, 0, 0, 0);
    final sorted = List<int>.generate(count, (i) => micros[i])..sort();
    double at(double q) => sorted[((count - 1) * q).round()] / 1000;
    return Percentiles(at(0.5), at(0.9), at(0.99), sorted.last / 1000);
  }

  final double p50;
  final double p90;
  final double p99;
  final double max;
}

class FrameSummary {
  const FrameSummary({
    required this.count,
    required this.build,
    required this.raster,
    required this.total,
    required this.slow,
    required this.janky,
  });

  final int count;
  final Percentiles build;
  final Percentiles raster;
  final Percentiles total;

  /// Frames over 16.7 ms (missed 60 Hz).
  final int slow;

  /// Frames over 33 ms (visible stutter).
  final int janky;
}
