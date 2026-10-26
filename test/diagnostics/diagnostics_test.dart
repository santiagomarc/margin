import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:margin/diagnostics/app_log.dart';
import 'package:margin/diagnostics/cost_meter.dart';
import 'package:margin/diagnostics/diagnostics.dart';
import 'package:margin/diagnostics/frame_stats.dart';

void main() {
  test('frame stats report percentiles and slow frames', () {
    final stats = FrameStats(100);
    for (var i = 1; i <= 100; i++) {
      stats.add(i * 100, i * 200, i * 400); // total up to 40 ms
    }
    final s = stats.summary();
    expect(s.count, 100);
    expect(s.total.p50, closeTo(20.4, 0.5));
    expect(s.total.p90, closeTo(36.4, 0.5));
    expect(s.total.max, 40);
    expect(s.build.p90, closeTo(9.1, 0.2));
    expect(s.slow, 59); // frames over 16.7 ms: 42..100
    expect(s.janky, 17); // frames over 33.3 ms: 84..100
  });

  test('frame stats keep only the latest window', () {
    final stats = FrameStats(10);
    for (var i = 0; i < 25; i++) {
      stats.add(1000, 1000, i < 15 ? 50000 : 5000);
    }
    expect(stats.summary().count, 10);
    expect(stats.summary().total.max, 5);
  });

  test('cost meter tracks last, average and max', () {
    final meter = CostMeter(4)
      ..record(100)
      ..record(300)
      ..record(200);
    expect(meter.last, 200);
    expect(meter.max, 300);
    expect(meter.average, 200);
  });

  test('app log keeps the newest lines', () {
    final log = AppLog(capacity: 3);
    for (var i = 0; i < 5; i++) {
      log.add('line $i');
    }
    expect(log.recent().map((l) => l.substring(9)), [
      'line 2',
      'line 3',
      'line 4',
    ]);
    log.error(StateError('boom'), StackTrace.fromString('#0 main\n#1 run'));
    expect(log.recent().first, endsWith('ERROR Bad state: boom'));
  });

  test('bug report has every section', () {
    final diagnostics = Diagnostics();
    diagnostics.frames.add(4000, 6000, 12000);
    diagnostics.log.add('opened scratch page');
    final report = diagnostics.bugReport(
      screen: const ScreenInfo(
        logicalSize: Size(1280, 800),
        pixelRatio: 1,
        refreshRate: 60,
      ),
      strokesOnPage: 42,
    );
    for (final section in [
      'App build: dev',
      'Device: unknown unknown',
      'Screen: 1280×800 dp at 1.00× (1280×800 px), 60 Hz',
      'Memory: RSS',
      'Frames (last 1): total p50 12.0',
      'Touch: last stroke',
      'Live stroke outline:',
      'Strokes on page: 42',
      'opened scratch page',
    ]) {
      expect(report, contains(section));
    }
  });
}
