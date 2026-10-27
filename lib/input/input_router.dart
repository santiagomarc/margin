import 'dart:typed_data';

import 'package:flutter/gestures.dart';

import '../diagnostics/touch_stats.dart';

/// Receives the classified input. Positions are in viewport coordinates.
abstract interface class InputHandler {
  /// Whether a one-finger touch at [position] may start a stroke.
  bool canStartStroke(Offset position);

  void strokeStart(Offset position, Duration time);
  void strokeUpdate(Offset position, Duration time);

  /// The finger lifted. [isTap] when it barely moved and lifted quickly.
  void strokeEnd(Duration time, {required bool isTap});

  /// Another finger landed or the system cancelled the touch: drop the stroke.
  void strokeCancel();

  /// Every finger landed and lifted quickly without moving.
  void multiFingerTap(int fingers);

  /// Two or more fingers moved together by [delta].
  void scrollBy(Offset delta);

  /// The fingers of a scroll lifted, moving at [velocity] (logical pixels
  /// per second; zero when they had stopped).
  void scrollEnd(Offset velocity);
}

enum _Mode { idle, drawing, single, multi }

class _Touch {
  _Touch(this.down, this.downTime) : position = down;

  final Offset down;
  final Duration downTime;
  Offset position;

  bool get moved => (position - down).distance > InputRouter.tapSlop;
}

/// Classifies raw pointer events (see "How finger input works" in
/// docs/PLAN.md):
///
/// - one finger draws, starting on touch-down (no gesture slop);
/// - a second finger drops the live stroke and the touch becomes a scroll;
/// - fingers that all land and lift quickly without moving are a tap
///   (two fingers undo, three redo, decided by the handler).
///
/// Plain Dart: uses event timestamps, never wall-clock time.
class InputRouter {
  InputRouter(this.handler, {this.stats});

  final InputHandler handler;
  final TouchStats? stats;

  /// Movement, in logical pixels, beyond which a touch is not a tap.
  static const tapSlop = 10.0;
  static const tapMaxDuration = Duration(milliseconds: 250);
  static const multiTapMaxDuration = Duration(milliseconds: 300);

  final Map<int, _Touch> _touches = {};
  _Mode _mode = _Mode.idle;
  int? _drawPointer;
  Duration _sequenceStart = Duration.zero;
  int _maxFingers = 0;
  bool _tapCandidate = false;
  bool _scrolled = false;
  Offset _lastCentroid = Offset.zero;
  Duration _lastScrollTime = Duration.zero;

  // Recent scroll positions (cumulative, one per event timestamp) for the
  // fling velocity: every finger of one Android event shares a timestamp.
  static const _samples = 8;
  final Float64List _sampleTime = Float64List(_samples);
  final Float64List _sampleX = Float64List(_samples);
  final Float64List _sampleY = Float64List(_samples);
  int _sampleCount = 0;
  int _sampleLast = -1;
  double _scrollX = 0;
  double _scrollY = 0;

  /// A scroll whose fingers rested this long before lifting doesn't fling.
  static const flingMaxPause = Duration(milliseconds: 80);

  /// How far back the fling velocity looks.
  static const flingWindow = Duration(milliseconds: 100);

  void handle(PointerEvent event) {
    if (event.kind == PointerDeviceKind.trackpad) return;
    switch (event) {
      case PointerDownEvent():
        _down(event);
      case PointerMoveEvent():
        _move(event);
      case PointerUpEvent():
        _up(event, cancelled: false);
      case PointerCancelEvent():
        _up(event, cancelled: true);
    }
  }

  void _down(PointerDownEvent event) {
    _touches[event.pointer] = _Touch(event.localPosition, event.timeStamp);
    stats?.pointerDown(event.size);

    if (_touches.length == 1) {
      _sequenceStart = event.timeStamp;
      _maxFingers = 1;
      if (handler.canStartStroke(event.localPosition)) {
        _mode = _Mode.drawing;
        _drawPointer = event.pointer;
        stats?.strokeStart(event.timeStamp);
        handler.strokeStart(event.localPosition, event.timeStamp);
      } else {
        _mode = _Mode.single;
      }
      return;
    }

    if (_touches.length > _maxFingers) _maxFingers = _touches.length;
    if (_mode == _Mode.drawing) {
      handler.strokeCancel();
      _drawPointer = null;
    }
    if (_mode != _Mode.multi) {
      _mode = _Mode.multi;
      _scrolled = false;
      _sampleCount = 0;
      _sampleLast = -1;
      _scrollX = 0;
      _scrollY = 0;
      _tapCandidate =
          event.timeStamp - _sequenceStart <= multiTapMaxDuration &&
          !_touches.values.any((t) => t.moved);
    }
    _lastCentroid = _centroid();
  }

  void _move(PointerMoveEvent event) {
    final touch = _touches[event.pointer];
    if (touch == null) return;
    touch.position = event.localPosition;
    stats?.pointerMove(event.size);

    switch (_mode) {
      case _Mode.drawing when event.pointer == _drawPointer:
        stats?.strokeSample(event.timeStamp);
        handler.strokeUpdate(event.localPosition, event.timeStamp);
      case _Mode.multi:
        if (_tapCandidate &&
            (touch.moved ||
                event.timeStamp - _sequenceStart > multiTapMaxDuration)) {
          _tapCandidate = false;
        }
        final centroid = _centroid();
        if (!_tapCandidate) {
          final delta = centroid - _lastCentroid;
          handler.scrollBy(delta);
          _trackVelocity(delta, event.timeStamp);
        }
        _lastCentroid = centroid;
      case _Mode.drawing || _Mode.single || _Mode.idle:
        break;
    }
  }

  void _up(PointerEvent event, {required bool cancelled}) {
    final touch = _touches.remove(event.pointer);
    if (touch == null) return;
    stats?.pointerUp();

    switch (_mode) {
      case _Mode.drawing when event.pointer == _drawPointer:
        _drawPointer = null;
        _mode = _Mode.idle;
        stats?.strokeEnd();
        if (cancelled) {
          handler.strokeCancel();
        } else {
          final isTap =
              !touch.moved &&
              event.timeStamp - touch.downTime <= tapMaxDuration;
          handler.strokeEnd(event.timeStamp, isTap: isTap);
        }
      case _Mode.multi:
        if (_touches.isNotEmpty) {
          _lastCentroid = _centroid();
          return;
        }
        _mode = _Mode.idle;
        if (!cancelled &&
            _tapCandidate &&
            !touch.moved &&
            event.timeStamp - _sequenceStart <= multiTapMaxDuration) {
          handler.multiFingerTap(_maxFingers);
        } else if (_scrolled) {
          final resting = event.timeStamp - _lastScrollTime > flingMaxPause;
          handler.scrollEnd(
            cancelled || resting ? Offset.zero : _flingVelocity(),
          );
        }
      case _Mode.drawing || _Mode.single || _Mode.idle:
        if (_touches.isEmpty) _mode = _Mode.idle;
    }
  }

  void _trackVelocity(Offset delta, Duration time) {
    _scrollX += delta.dx;
    _scrollY += delta.dy;
    final t = time.inMicroseconds.toDouble();
    if (_sampleCount == 0 || _sampleTime[_sampleLast] != t) {
      _sampleLast = (_sampleLast + 1) % _samples;
      if (_sampleCount < _samples) _sampleCount++;
    }
    _sampleTime[_sampleLast] = t;
    _sampleX[_sampleLast] = _scrollX;
    _sampleY[_sampleLast] = _scrollY;
    _scrolled = true;
    _lastScrollTime = time;
  }

  /// Logical pixels per second over the last [flingWindow] of the scroll.
  Offset _flingVelocity() {
    if (_sampleCount < 2) return Offset.zero;
    final newest = _sampleLast;
    final window = flingWindow.inMicroseconds;
    var oldest = newest;
    for (var i = 1; i < _sampleCount; i++) {
      final j = (newest - i + _samples) % _samples;
      if (_sampleTime[newest] - _sampleTime[j] > window) break;
      oldest = j;
    }
    final dt = (_sampleTime[newest] - _sampleTime[oldest]) / 1e6;
    if (dt <= 0) return Offset.zero;
    return Offset(
      (_sampleX[newest] - _sampleX[oldest]) / dt,
      (_sampleY[newest] - _sampleY[oldest]) / dt,
    );
  }

  Offset _centroid() {
    var sum = Offset.zero;
    for (final t in _touches.values) {
      sum += t.position;
    }
    return _touches.isEmpty ? Offset.zero : sum / _touches.length.toDouble();
  }
}
