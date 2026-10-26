import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/app/app_scope.dart';
import 'package:margin/app/margin_app.dart';
import 'package:margin/app/notebook_screen.dart';
import 'package:margin/canvas/ink_layer.dart';
import 'package:margin/canvas/ink_stroke.dart';
import 'package:margin/canvas/live_layer.dart';
import 'package:margin/canvas/point_buffer.dart';
import 'package:margin/canvas/stroke_geometry.dart';
import 'package:margin/db/ids.dart';
import 'package:margin/db/ink_repository.dart';
import 'package:margin/db/tables.dart';
import 'package:margin/tools/pen_tool.dart';

import '../helpers.dart';

void main() {
  late AppServices services;

  setUp(() => services = testServices());

  Future<void> pumpNotebook(
    WidgetTester tester, {
    Size size = const Size(1280, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MarginApp(services: services));
    await tester.tap(find.text('Scratch page'));
    await tester.pumpAndSettle();
    expect(find.byType(NotebookScreen), findsOneWidget);
  }

  InkLayerController ink(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is InkPainter,
      ),
    );
    return (paint.painter! as InkPainter).controller;
  }

  LiveStroke live(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.byWidgetPredicate(
        (w) => w is CustomPaint && w.painter is LivePainter,
      ),
    );
    return (paint.painter! as LivePainter).live;
  }

  /// Draws a stroke with one finger, 16 ms between samples.
  Future<void> drawStroke(
    WidgetTester tester,
    Offset from,
    Offset to, {
    int pointer = 1,
  }) async {
    final gesture = await tester.createGesture(pointer: pointer);
    await gesture.down(from, timeStamp: Duration.zero);
    for (var i = 1; i <= 10; i++) {
      await gesture.moveTo(
        Offset.lerp(from, to, i / 10)!,
        timeStamp: Duration(milliseconds: i * 16),
      );
    }
    await gesture.up(timeStamp: const Duration(milliseconds: 180));
    await tester.pump();
  }

  /// Taps with [fingers] fingers at once.
  Future<void> multiTap(WidgetTester tester, int fingers) async {
    final gestures = <TestGesture>[];
    for (var i = 0; i < fingers; i++) {
      final g = await tester.createGesture(pointer: 10 + i);
      await g.down(
        Offset(400 + i * 60.0, 400),
        timeStamp: Duration(milliseconds: i * 20),
      );
      gestures.add(g);
    }
    for (final g in gestures) {
      await g.up(timeStamp: const Duration(milliseconds: 150));
    }
    await tester.pump();
  }

  testWidgets('one finger draws a stroke that gets saved', (tester) async {
    await pumpNotebook(tester);
    await drawStroke(tester, const Offset(200, 300), const Offset(600, 340));
    expect(ink(tester).length, 1);
    expect(live(tester).points.isEmpty, isTrue);

    // The batched write lands shortly after the finger lifts.
    await tester.pump(const Duration(seconds: 1));
    final rows = await services.db.select(services.db.strokes).get();
    expect(rows, hasLength(1));
    expect(rows.single.pageId, InkRepository.scratchPageId);
    expect(rows.single.minX, lessThan(rows.single.maxX));
  });

  testWidgets('two-finger tap undoes and three-finger tap redoes', (
    tester,
  ) async {
    await pumpNotebook(tester);
    await drawStroke(tester, const Offset(200, 300), const Offset(600, 340));
    expect(ink(tester).length, 1);

    await multiTap(tester, 2);
    expect(ink(tester).length, 0);
    expect(find.text('Undo'), findsOneWidget);

    await multiTap(tester, 3);
    expect(ink(tester).length, 1);
    expect(find.text('Redo'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('a second finger mid-stroke drops it and scrolls the page', (
    tester,
  ) async {
    await pumpNotebook(tester);
    final first = await tester.createGesture(pointer: 1);
    await first.down(const Offset(300, 500), timeStamp: Duration.zero);
    await first.moveTo(
      const Offset(360, 500),
      timeStamp: const Duration(milliseconds: 100),
    );
    expect(live(tester).points.isEmpty, isFalse);

    final second = await tester.createGesture(pointer: 2);
    await second.down(
      const Offset(500, 500),
      timeStamp: const Duration(milliseconds: 150),
    );
    expect(live(tester).points.isEmpty, isTrue);

    for (var i = 1; i <= 5; i++) {
      final t = Duration(milliseconds: 150 + i * 16);
      await first.moveTo(Offset(360, 500 - i * 40.0), timeStamp: t);
      await second.moveTo(Offset(500, 500 - i * 40.0), timeStamp: t);
    }
    await first.up(timeStamp: const Duration(milliseconds: 300));
    await second.up(timeStamp: const Duration(milliseconds: 300));
    await tester.pump();

    expect(ink(tester).length, 0);
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(ValueListenableBuilder<double>),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().y, lessThan(-150));
  });

  testWidgets('toolbar undo and redo follow the history', (tester) async {
    await pumpNotebook(tester);
    IconButton button(IconData icon) =>
        tester.widget<IconButton>(find.widgetWithIcon(IconButton, icon));
    expect(button(Icons.undo).onPressed, isNull);

    await drawStroke(tester, const Offset(200, 300), const Offset(600, 340));
    expect(button(Icons.undo).onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.undo));
    await tester.pump();
    expect(ink(tester).length, 0);
    expect(button(Icons.redo).onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.redo));
    await tester.pump(const Duration(seconds: 1));
    expect(ink(tester).length, 1);
  });

  testWidgets('strokes are there after reopening', (tester) async {
    await pumpNotebook(tester);
    await drawStroke(tester, const Offset(200, 300), const Offset(600, 340));
    await drawStroke(tester, const Offset(200, 400), const Offset(600, 380));

    await tester.tap(find.byTooltip('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scratch page'));
    await tester.pumpAndSettle();
    expect(ink(tester).length, 2);
  });

  testWidgets('More shows diagnostics and copies a bug report', (tester) async {
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await pumpNotebook(tester);
    await drawStroke(tester, const Offset(200, 300), const Offset(600, 340));

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Frames  p90'), findsOneWidget);
    expect(find.textContaining('Strokes 1'), findsOneWidget);

    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy bug report'));
    await tester.pump();
    expect(copied, contains('Margin bug report'));
    expect(copied, contains('Strokes on page: 1'));
    expect(copied, contains('Screen: 1280×800 dp'));
    expect(find.textContaining('Bug report copied'), findsOneWidget);

    // Hide the overlay again so its timer stops.
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Diagnostics'));
    await tester.pumpAndSettle();
  });

  testWidgets('the toolbar fits a portrait 8-inch screen', (tester) async {
    await pumpNotebook(tester, size: const Size(600, 960));
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.more_horiz), findsOneWidget);
  });

  testWidgets('golden: notebook with handwriting', (tester) async {
    final repo = InkRepository(services.db);
    final page = await repo.ensureScratchPage();
    for (final stroke in _sampleHandwriting()) {
      repo.saveStroke(page.id, stroke);
    }
    await repo.flush();
    repo.dispose();

    await pumpNotebook(tester);
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/notebook_handwriting.png'),
    );
  });
}

/// Loops, waves and an underline in page points, sampled at 60 Hz the way a
/// finger would write them, then run through the pen's own pipeline.
List<InkStroke> _sampleHandwriting() {
  final strokes = <InkStroke>[];

  void stroke(
    Offset Function(double t) curve, {
    int samples = 40,
    int color = PenTool.defaultColor,
    double size = PenTool.defaultSize,
  }) {
    final pressure = SpeedPressure();
    final raw = PointBuffer(samples);
    for (var i = 0; i <= samples; i++) {
      final p = curve(i / samples);
      raw.add(p.dx, p.dy, pressure.next(p.dx, p.dy, i * 16667));
    }
    final points = simplifyStroke(settleStroke(raw, size), simplifyTolerance);
    strokes.add(
      InkStroke(
        id: newId(),
        tool: StrokeTool.pen,
        color: color,
        size: size,
        points: points,
        bounds: strokeBounds(points, size),
        createdAt: nextTimestamp(),
      ),
    );
  }

  // Three lines of cursive-like loops on the ruled lines.
  for (var line = 0; line < 3; line++) {
    final baseline = 112.0 + line * 48;
    final width = 380.0 - line * 70;
    stroke(
      (t) => Offset(
        80 + t * width + 7 * math.cos(t * math.pi * 22),
        baseline - 9 - 8 * math.sin(t * math.pi * 22),
      ),
      samples: 160,
    );
  }
  // An underline and a blue wave.
  stroke((t) => Offset(80 + t * 240, 124 + 2 * math.sin(t * math.pi)));
  stroke(
    (t) => Offset(90 + t * 300, 270 + 14 * math.sin(t * math.pi * 4)),
    samples: 80,
    color: 0xFF1F5FBF,
    size: 4,
  );
  // A star.
  stroke((t) {
    final k = (t * 5).floor().clamp(0, 4);
    final a0 = -math.pi / 2 + k * 4 * math.pi / 5;
    final a1 = a0 + 4 * math.pi / 5;
    final f = t * 5 - k;
    final p0 = Offset(470 + 30 * math.cos(a0), 300 + 30 * math.sin(a0));
    final p1 = Offset(470 + 30 * math.cos(a1), 300 + 30 * math.sin(a1));
    return Offset.lerp(p0, p1, f)!;
  }, samples: 60);
  // A dot.
  stroke((t) => const Offset(400, 175), samples: 1);
  return strokes;
}
