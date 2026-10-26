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
  Offset _lastCentroid = Offset.zero;

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
        if (!_tapCandidate) handler.scrollBy(centroid - _lastCentroid);
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
        }
      case _Mode.drawing || _Mode.single || _Mode.idle:
        if (_touches.isEmpty) _mode = _Mode.idle;
    }
  }

  Offset _centroid() {
    var sum = Offset.zero;
    for (final t in _touches.values) {
      sum += t.position;
    }
    return _touches.isEmpty ? Offset.zero : sum / _touches.length.toDouble();
  }
}
