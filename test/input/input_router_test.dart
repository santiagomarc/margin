import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/diagnostics/touch_stats.dart';
import 'package:margin/input/input_router.dart';

class _Recorder implements InputHandler {
  final calls = <String>[];
  Offset scrolled = Offset.zero;
  bool allowStroke = true;

  @override
  bool canStartStroke(Offset position) => allowStroke;
  @override
  void strokeStart(Offset position, Duration time) => calls.add('start');
  @override
  void strokeUpdate(Offset position, Duration time) => calls.add('update');
  @override
  void strokeEnd(Duration time, {required bool isTap}) =>
      calls.add(isTap ? 'end(tap)' : 'end');
  @override
  void strokeCancel() => calls.add('cancel');
  @override
  void multiFingerTap(int fingers) => calls.add('tap$fingers');
  @override
  void scrollBy(Offset delta) {
    scrolled += delta;
    if (calls.isEmpty || calls.last != 'scroll') calls.add('scroll');
  }
}

Duration ms(int v) => Duration(milliseconds: v);

void main() {
  late _Recorder handler;
  late InputRouter router;
  late TouchStats stats;

  setUp(() {
    handler = _Recorder();
    stats = TouchStats();
    router = InputRouter(handler, stats: stats);
  });

  void down(int pointer, Offset at, int t, {double size = 0.02}) =>
      router.handle(
        PointerDownEvent(
          pointer: pointer,
          position: at,
          timeStamp: ms(t),
          size: size,
        ),
      );
  void move(int pointer, Offset at, int t) => router.handle(
    PointerMoveEvent(pointer: pointer, position: at, timeStamp: ms(t)),
  );
  void up(int pointer, Offset at, int t) => router.handle(
    PointerUpEvent(pointer: pointer, position: at, timeStamp: ms(t)),
  );

  test('one finger draws from touch-down to lift', () {
    down(1, const Offset(10, 10), 0);
    move(1, const Offset(30, 10), 16);
    move(1, const Offset(60, 12), 32);
    up(1, const Offset(60, 12), 48);
    expect(handler.calls, ['start', 'update', 'update', 'end']);
  });

  test('a quick still touch ends as a tap', () {
    down(1, const Offset(10, 10), 0);
    move(1, const Offset(12, 11), 40);
    up(1, const Offset(12, 11), 90);
    expect(handler.calls, ['start', 'update', 'end(tap)']);
  });

  test('a long still touch is not a tap', () {
    down(1, const Offset(10, 10), 0);
    up(1, const Offset(10, 10), 400);
    expect(handler.calls, ['start', 'end']);
  });

  test('a second finger drops the stroke and scrolls', () {
    down(1, const Offset(100, 100), 0);
    move(1, const Offset(140, 100), 100);
    down(2, const Offset(200, 100), 150);
    move(1, const Offset(140, 60), 170);
    move(2, const Offset(200, 60), 170);
    up(1, const Offset(140, 60), 200);
    up(2, const Offset(200, 60), 210);
    expect(handler.calls, ['start', 'update', 'cancel', 'scroll']);
    expect(handler.scrolled.dy, closeTo(-40, 0.01));
  });

  test('two fingers tapping quickly is a two-finger tap', () {
    down(1, const Offset(100, 100), 0);
    down(2, const Offset(160, 100), 30);
    move(1, const Offset(102, 101), 60);
    up(1, const Offset(102, 101), 120);
    up(2, const Offset(160, 100), 130);
    expect(handler.calls, ['start', 'cancel', 'tap2']);
  });

  test('three fingers tapping quickly is a three-finger tap', () {
    down(1, const Offset(100, 100), 0);
    down(2, const Offset(160, 100), 20);
    down(3, const Offset(220, 100), 40);
    up(2, const Offset(160, 100), 140);
    up(1, const Offset(100, 100), 150);
    up(3, const Offset(220, 100), 160);
    expect(handler.calls, ['start', 'cancel', 'tap3']);
  });

  test('fingers held too long are not a tap', () {
    down(1, const Offset(100, 100), 0);
    down(2, const Offset(160, 100), 30);
    up(1, const Offset(100, 100), 400);
    up(2, const Offset(160, 100), 410);
    expect(handler.calls, ['start', 'cancel']);
  });

  test('a second finger after the first has moved is a scroll, not a tap', () {
    down(1, const Offset(100, 100), 0);
    move(1, const Offset(150, 100), 50);
    down(2, const Offset(200, 100), 80);
    up(1, const Offset(150, 100), 120);
    up(2, const Offset(200, 100), 130);
    expect(handler.calls, ['start', 'update', 'cancel']);
  });

  test('the last finger of a scroll never starts drawing', () {
    down(1, const Offset(100, 100), 0);
    down(2, const Offset(160, 100), 20);
    move(1, const Offset(100, 50), 60);
    move(2, const Offset(160, 50), 60);
    up(2, const Offset(160, 50), 100);
    move(1, const Offset(100, 0), 140);
    up(1, const Offset(100, 0), 180);
    expect(handler.calls, ['start', 'cancel', 'scroll']);
    expect(handler.scrolled.dy, closeTo(-100, 0.01));
  });

  test('touches outside the page do not draw but still form gestures', () {
    handler.allowStroke = false;
    down(1, const Offset(5, 5), 0);
    move(1, const Offset(40, 5), 20);
    up(1, const Offset(40, 5), 40);
    down(1, const Offset(5, 5), 100);
    down(2, const Offset(60, 5), 110);
    up(1, const Offset(5, 5), 160);
    up(2, const Offset(60, 5), 170);
    expect(handler.calls, ['tap2']);
  });

  test('a cancelled touch drops the stroke', () {
    down(1, const Offset(10, 10), 0);
    move(1, const Offset(40, 10), 16);
    router.handle(
      PointerCancelEvent(
        pointer: 1,
        position: const Offset(40, 10),
        timeStamp: ms(30),
      ),
    );
    expect(handler.calls, ['start', 'update', 'cancel']);
  });

  test('touch stats track sample rate and contact size', () {
    down(1, Offset.zero, 0, size: 0.03);
    for (var i = 1; i <= 30; i++) {
      move(1, Offset(i * 5.0, 0), i * 16);
    }
    up(1, const Offset(150, 0), 500);
    expect(stats.lastStrokeRate, closeTo(62.5, 0.5));
    expect(stats.maxContactSize, 0.03);

    down(2, Offset.zero, 1000, size: 0.2);
    expect(stats.maxContactSize, 0.2, reason: 'reset per touch sequence');
  });
}
