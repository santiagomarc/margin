import 'package:flutter_test/flutter_test.dart';
import 'package:margin/history/history.dart';

class _Append implements Command {
  _Append(this.log, this.value);

  final List<int> log;
  final int value;

  @override
  void apply() => log.add(value);

  @override
  void revert() => log.remove(value);
}

void main() {
  test('undo and redo walk the history', () {
    final log = <int>[];
    final history = History();
    history
      ..execute(_Append(log, 1))
      ..execute(_Append(log, 2));
    expect(log, [1, 2]);

    expect(history.undo(), isTrue);
    expect(log, [1]);
    expect(history.canRedo, isTrue);

    expect(history.redo(), isTrue);
    expect(log, [1, 2]);

    expect(history.undo(), isTrue);
    expect(history.undo(), isTrue);
    expect(history.undo(), isFalse);
    expect(log, isEmpty);
  });

  test('a new command clears redo', () {
    final log = <int>[];
    final history = History()..execute(_Append(log, 1));
    history.undo();
    history.execute(_Append(log, 2));
    expect(history.canRedo, isFalse);
    expect(history.redo(), isFalse);
    expect(log, [2]);
  });

  test('forgets the oldest commands past the limit', () {
    final log = <int>[];
    final history = History(limit: 3);
    for (var i = 0; i < 5; i++) {
      history.execute(_Append(log, i));
    }
    var undone = 0;
    while (history.undo()) {
      undone++;
    }
    expect(undone, 3);
    expect(log, [0, 1]);
  });

  test('notifies listeners on every change', () {
    final history = History();
    var notified = 0;
    history.addListener(() => notified++);
    history.execute(_Append([], 1));
    history.undo();
    history.redo();
    expect(notified, 3);
    expect(history.canUndo, isTrue);
  });
}
