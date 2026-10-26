import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Recent log lines for the bug report. Errors are also appended to a file,
/// so a crash can still be reported after the app restarts.
class AppLog {
  AppLog({this.capacity = 200});

  final int capacity;
  final Queue<String> _lines = Queue();
  File? _errorFile;

  List<String> recent([int count = 100]) {
    final skip = _lines.length > count ? _lines.length - count : 0;
    return _lines.skip(skip).toList();
  }

  void add(String message) {
    final now = DateTime.now();
    final time = '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
    _push('$time $message');
  }

  void error(Object error, StackTrace? stack) {
    final firstFrames = (stack?.toString() ?? '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .take(4)
        .map((l) => '    $l');
    final lines = ['ERROR $error', ...firstFrames];
    for (final line in lines) {
      add(line);
    }
    final file = _errorFile;
    if (file != null) {
      unawaited(
        file
            .writeAsString(
              '${DateTime.now().toIso8601String()} ${lines.join('\n')}\n',
              mode: FileMode.append,
              flush: true,
            )
            .catchError((Object _) => file),
      );
    }
  }

  /// Routes uncaught Flutter and platform errors here.
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      error(details.exception, details.stack);
      previous?.call(details);
    };
    PlatformDispatcher.instance.onError = (exception, stack) {
      error(exception, stack);
      return false;
    };
  }

  /// Loads errors saved by earlier runs (marked "previous run") and keeps
  /// saving new ones in [directory].
  Future<void> persistErrorsIn(Directory directory) async {
    final file = File('${directory.path}/errors.log');
    if (await file.exists()) {
      final old = await file.readAsLines();
      final kept = old.length > 50 ? old.sublist(old.length - 50) : old;
      for (final line in kept) {
        _push('previous run: $line');
      }
      await file.writeAsString(kept.isEmpty ? '' : '${kept.join('\n')}\n');
    }
    _errorFile = file;
  }

  void _push(String line) {
    _lines.addLast(line);
    while (_lines.length > capacity) {
      _lines.removeFirst();
    }
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
