import 'dart:math';

final Random _random = Random();
int _counter = 0;
int _lastMillis = 0;

/// A unique, roughly time-ordered id (time + counter + random), so new rows
/// never collide even when created in the same millisecond.
String newId() {
  final time = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
  final count = (_counter++ & 0xFFFF).toRadixString(36).padLeft(4, '0');
  final rand = _random.nextInt(1 << 30).toRadixString(36).padLeft(6, '0');
  return '$time$count$rand';
}

/// The current time in UTC, strictly increasing in milliseconds.
///
/// Strokes are drawn in `createdAt` order, so two strokes must never share a
/// timestamp.
DateTime nextTimestamp() {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  _lastMillis = now > _lastMillis ? now : _lastMillis + 1;
  return DateTime.fromMillisecondsSinceEpoch(_lastMillis, isUtc: true);
}
