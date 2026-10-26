import 'dart:async';

import 'package:flutter/material.dart';

import 'diagnostics.dart';

/// Live numbers in a corner of the notebook screen. Updates twice a second
/// and never takes input, so it can't get in the way of writing.
class DiagnosticsOverlay extends StatefulWidget {
  const DiagnosticsOverlay({
    super.key,
    required this.diagnostics,
    required this.strokeCount,
  });

  final Diagnostics diagnostics;
  final int Function() strokeCount;

  @override
  State<DiagnosticsOverlay> createState() => _DiagnosticsOverlayState();
}

class _DiagnosticsOverlayState extends State<DiagnosticsOverlay> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diagnostics;
    final f = d.frames.summary();
    final screen = ScreenInfo.of(View.of(context));
    String ms(double v) => v.toStringAsFixed(1);
    String mb(int bytes) => (bytes / (1024 * 1024)).toStringAsFixed(0);
    final lines = [
      'Frames  p90 ${ms(f.total.p90)} · max ${ms(f.total.max)} ms · '
          '>16.7 ms ${f.slow}/${f.count}',
      'Build p90 ${ms(f.build.p90)} · raster p90 ${ms(f.raster.p90)} ms',
      'Memory  ${mb(d.rssBytes)} MB · images ${mb(d.imageCacheBytes)} MB',
      'Touch   ${d.touch.lastStrokeRate.round()} Hz · contact '
          '${d.touch.lastContactSize.toStringAsFixed(3)} '
          '(max ${d.touch.maxContactSize.toStringAsFixed(3)})',
      'Outline ${ms(d.liveOutlineCost.last / 1000)} · max '
          '${ms(d.liveOutlineCost.max / 1000)} ms',
      'Screen  ${screen.describe()}',
      'Strokes ${widget.strokeCount()}',
    ];
    return IgnorePointer(
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xCC1B1F24),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            lines.join('\n'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
