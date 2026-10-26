import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:margin/canvas/point_buffer.dart';
import 'package:margin/canvas/stroke_geometry.dart';

Float32List triples(List<List<double>> points) =>
    Float32List.fromList([for (final p in points) ...p]);

void main() {
  group('simplifyStroke', () {
    test('collapses a straight line to its endpoints', () {
      final line = triples([
        for (var i = 0; i <= 10; i++) [i * 10.0, i * 5.0, 0.5],
      ]);
      final simplified = simplifyStroke(line, 0.1);
      expect(
        simplified,
        triples([
          [0, 0, 0.5],
          [100, 50, 0.5],
        ]),
      );
    });

    test('keeps a corner and the corner keeps its pressure', () {
      final corner = triples([
        [0, 0, 0.4],
        [5, 0, 0.5],
        [10, 0, 0.6],
        [10, 5, 0.7],
        [10, 10, 0.8],
      ]);
      final simplified = simplifyStroke(corner, 0.1);
      expect(
        simplified,
        triples([
          [0, 0, 0.4],
          [10, 0, 0.6],
          [10, 10, 0.8],
        ]),
      );
    });

    test('keeps deviations larger than the tolerance only', () {
      final wobble = triples([
        [0, 0, 0.5],
        [10, 0.05, 0.5],
        [20, 0, 0.5],
        [30, 2, 0.5],
        [40, 0, 0.5],
      ]);
      final simplified = simplifyStroke(wobble, 0.1);
      expect(simplified.length ~/ 3, 4);
      expect(simplified.sublist(6, 9), [30, 2, 0.5]);
    });

    test('leaves one- and two-point strokes alone', () {
      expect(
        simplifyStroke(
          triples([
            [1, 2, 0.5],
          ]),
          0.1,
        ),
        [1, 2, 0.5],
      );
      expect(
        simplifyStroke(
          triples([
            [1, 2, 0.5],
            [3, 4, 0.6],
          ]),
          0.1,
        ),
        triples([
          [1, 2, 0.5],
          [3, 4, 0.6],
        ]),
      );
    });
  });

  group('SpeedPressure', () {
    // Samples 10 ms apart moving [step] points each time.
    double settle(double step) {
      final p = SpeedPressure();
      var value = 0.0;
      for (var i = 0; i < 40; i++) {
        value = p.next(i * step, 0, i * 10000);
      }
      return value;
    }

    test('slow writing is fuller than fast writing', () {
      final slow = settle(0.5); // 0.05 pt/ms
      final fast = settle(10); // 1 pt/ms
      expect(slow, greaterThan(fast));
      expect(slow, closeTo(0.88, 0.02));
      expect(fast, lessThan(0.45));
    });

    test('stays between the slow and fast pressures', () {
      expect(settle(1000), greaterThanOrEqualTo(0.3));
      expect(settle(0), lessThanOrEqualTo(0.9));
    });

    test('starts at the initial pressure and ignores zero time steps', () {
      final p = SpeedPressure();
      expect(p.next(0, 0, 0), 0.6);
      expect(p.next(50, 0, 0), 0.6);
    });

    test('reset starts a new stroke', () {
      final p = SpeedPressure();
      p.next(0, 0, 0);
      p.next(100, 0, 10000);
      p.reset();
      expect(p.next(0, 0, 50000), 0.6);
    });
  });

  test('strokeBounds pads the extremes', () {
    final bounds = strokeBounds(
      triples([
        [10, 20, 0.5],
        [30, 5, 0.5],
      ]),
      2,
    );
    expect(bounds.left, 8);
    expect(bounds.top, 3);
    expect(bounds.right, 32);
    expect(bounds.bottom, 22);
  });

  test('strokePath outlines dots and lines', () {
    final dot = strokePath(
      triples([
        [50, 50, 0.6],
      ]),
      2.5,
      complete: true,
    );
    expect(dot.getBounds().center.dx, closeTo(50.5, 1));
    expect(dot.getBounds().width, greaterThan(1));

    final line = strokePath(
      triples([
        for (var i = 0; i <= 20; i++) [i * 5.0, 100, 0.5],
      ]),
      2.5,
      complete: true,
    );
    final b = line.getBounds();
    expect(b.width, greaterThan(95));
    expect(b.height, closeTo(2.5, 1.5));
  });

  test('a tap (repeated position, changing pressure) still draws a dot', () {
    final raw = PointBuffer(4)
      ..add(400, 175, 0.6)
      ..add(400, 175, 0.69)
      ..add(400, 175, 0.75);
    final live = strokePath(raw.toFloat32List(), 2.5, complete: false);
    expect(live.getBounds().width, greaterThan(2));

    final points = simplifyStroke(settleStroke(raw, 2.5), simplifyTolerance);
    final saved = strokePath(points, 2.5, complete: true, streamline: 0);
    expect(saved.getBounds().width, greaterThan(2));
    expect(saved.getBounds().height, greaterThan(2));
    expect(saved.getBounds().center.dx, closeTo(400.5, 1));
  });

  test('settleStroke keeps the end point and pressures in range', () {
    final raw = PointBuffer(2);
    for (var i = 0; i <= 30; i++) {
      raw.add(i * 3.0, (i % 2) * 1.0, 0.5 + i / 100);
    }
    final settled = settleStroke(raw, 2.5);
    final n = settled.length ~/ 3;
    expect(n, greaterThan(5));
    expect(settled[(n - 1) * 3], 90);
    for (var i = 0; i < n; i++) {
      expect(settled[i * 3 + 2], inInclusiveRange(0.5, 0.8 + 1e-6));
    }
  });

  test('PointBuffer grows and keeps every point', () {
    final buffer = PointBuffer(2);
    for (var i = 0; i < 100; i++) {
      buffer.add(i.toDouble(), -i.toDouble(), i / 100);
    }
    expect(buffer.length, 100);
    expect(buffer.x(99), 99);
    expect(buffer.y(50), -50);
    expect(buffer.pressure(10), closeTo(0.1, 1e-6));
    expect(buffer.toFloat32List().length, 300);
    buffer.clear();
    expect(buffer.isEmpty, isTrue);
  });
}
