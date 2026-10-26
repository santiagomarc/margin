import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'app_log.dart';
import 'build_info.dart';
import 'cost_meter.dart';
import 'device_info.dart';
import 'frame_stats.dart';
import 'touch_stats.dart';

/// The screen as Flutter sees it.
class ScreenInfo {
  const ScreenInfo({
    required this.logicalSize,
    required this.pixelRatio,
    required this.refreshRate,
  });

  factory ScreenInfo.of(FlutterView view) => ScreenInfo(
    logicalSize: view.physicalSize / view.devicePixelRatio,
    pixelRatio: view.devicePixelRatio,
    refreshRate: view.display.refreshRate,
  );

  final Size logicalSize;
  final double pixelRatio;
  final double refreshRate;

  String describe() {
    final w = logicalSize.width.round(), h = logicalSize.height.round();
    final pw = (logicalSize.width * pixelRatio).round();
    final ph = (logicalSize.height * pixelRatio).round();
    return '$w×$h dp at ${pixelRatio.toStringAsFixed(2)}× '
        '($pw×$ph px), ${refreshRate.round()} Hz';
  }
}

/// Everything the app measures about itself on the tablet (see "Measuring"
/// in docs/PLAN.md). Claude can't run the app on the T3, so these numbers
/// are how speed problems get reported.
class Diagnostics {
  Diagnostics({AppLog? log}) : log = log ?? AppLog();

  final AppLog log;
  final FrameStats frames = FrameStats();
  final TouchStats touch = TouchStats();

  /// Time to build the live stroke's outline each frame.
  final CostMeter liveOutlineCost = CostMeter();

  /// Whether the overlay is shown (More → Diagnostics).
  final ValueNotifier<bool> overlayVisible = ValueNotifier(false);

  DeviceInfo device = const DeviceInfo();

  void start() {
    frames.attach();
    log.add('App started, build ${BuildInfo.label}');
    unawaited(DeviceInfo.load().then((info) => device = info));
  }

  int get rssBytes {
    try {
      return ProcessInfo.currentRss;
    } on UnsupportedError {
      return 0;
    }
  }

  int get imageCacheBytes =>
      PaintingBinding.instance.imageCache.currentSizeBytes;

  /// Text for More → Copy bug report.
  String bugReport({required ScreenInfo screen, int? strokesOnPage}) {
    final f = frames.summary();
    String ms(double v) => v.toStringAsFixed(1);
    String mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(1);
    return [
      'Margin bug report',
      'App build: ${BuildInfo.label}',
      'Device: ${device.describe()}',
      'Screen: ${screen.describe()}',
      'Memory: RSS ${mb(rssBytes)} MB, image cache ${mb(imageCacheBytes)} MB',
      'Frames (last ${f.count}): total p50 ${ms(f.total.p50)} / '
          'p90 ${ms(f.total.p90)} / p99 ${ms(f.total.p99)} / '
          'max ${ms(f.total.max)} ms; build p90 ${ms(f.build.p90)} ms; '
          'raster p90 ${ms(f.raster.p90)} ms; '
          'over 16.7 ms: ${f.slow}; over 33 ms: ${f.janky}',
      'Touch: last stroke ${touch.lastStrokeRate.round()} Hz, '
          'average ${touch.averageRate.round()} Hz; contact size last '
          '${touch.lastContactSize.toStringAsFixed(3)}, max '
          '${touch.maxContactSize.toStringAsFixed(3)}',
      'Live stroke outline: last ${ms(liveOutlineCost.last / 1000)} ms, '
          'average ${ms(liveOutlineCost.average / 1000)} ms, '
          'max ${ms(liveOutlineCost.max / 1000)} ms',
      if (strokesOnPage != null) 'Strokes on page: $strokesOnPage',
      'Recent log (newest last):',
      ...log.recent().map((l) => '  $l'),
    ].join('\n');
  }

  void dispose() {
    frames.detach();
    overlayVisible.dispose();
  }
}
