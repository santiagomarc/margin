/// Touch measurements for the diagnostics overlay: how often the screen
/// reports a moving finger, and how big each contact is (for palm guard).
class TouchStats {
  int _samples = 0;
  Duration _first = Duration.zero;
  Duration _last = Duration.zero;

  /// Samples per second during the last stroke.
  double lastStrokeRate = 0;

  /// Running average of [lastStrokeRate].
  double averageRate = 0;

  /// Contact size (0–1, as reported by Android) of the latest touch.
  double lastContactSize = 0;

  /// Largest contact size seen during the current or last touch sequence.
  double maxContactSize = 0;

  int _activePointers = 0;

  void pointerDown(double size) {
    if (_activePointers == 0) maxContactSize = 0;
    _activePointers++;
    _contact(size);
  }

  void pointerMove(double size) => _contact(size);

  void pointerUp() {
    if (_activePointers > 0) _activePointers--;
  }

  void strokeStart(Duration time) {
    _samples = 1;
    _first = time;
    _last = time;
  }

  void strokeSample(Duration time) {
    _samples++;
    _last = time;
  }

  void strokeEnd() {
    final seconds = (_last - _first).inMicroseconds / 1e6;
    if (_samples < 5 || seconds <= 0) return;
    lastStrokeRate = (_samples - 1) / seconds;
    averageRate = averageRate == 0
        ? lastStrokeRate
        : averageRate * 0.8 + lastStrokeRate * 0.2;
  }

  void _contact(double size) {
    lastContactSize = size;
    if (size > maxContactSize) maxContactSize = size;
  }
}
