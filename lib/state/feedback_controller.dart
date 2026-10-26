import 'dart:async';

import 'package:flutter/foundation.dart';

/// A short message confirming an invisible gesture ("Undo", "Redo").
class FeedbackController extends ChangeNotifier {
  FeedbackController({this.duration = const Duration(milliseconds: 700)});

  final Duration duration;
  String? _message;
  Timer? _timer;

  String? get message => _message;

  void show(String message) {
    _message = message;
    _timer?.cancel();
    _timer = Timer(duration, () {
      _message = null;
      notifyListeners();
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
