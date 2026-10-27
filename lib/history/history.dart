import 'package:flutter/foundation.dart';

/// A reversible change to notes. [apply] must be safe to call again after
/// [revert] (that's redo).
abstract class Command {
  void apply();
  void revert();
}

/// Undo and redo stacks for one open notebook.
class History extends ChangeNotifier {
  History({this.limit = 200});

  /// Oldest commands are forgotten beyond this many.
  final int limit;

  final List<Command> _undo = [];
  final List<Command> _redo = [];

  bool get canUndo => _undo.isNotEmpty;
  bool get canRedo => _redo.isNotEmpty;

  void execute(Command command) {
    command.apply();
    _undo.add(command);
    if (_undo.length > limit) _undo.removeAt(0);
    _redo.clear();
    notifyListeners();
  }

  /// Returns false when there is nothing to undo.
  bool undo() {
    if (_undo.isEmpty) return false;
    final command = _undo.removeLast()..revert();
    _redo.add(command);
    notifyListeners();
    return true;
  }

  /// Undoes [command] only if it is the latest change (a snackbar's Undo must
  /// not undo something done after it).
  bool undoIfLast(Command command) {
    if (_undo.isEmpty || !identical(_undo.last, command)) return false;
    return undo();
  }

  /// Returns false when there is nothing to redo.
  bool redo() {
    if (_redo.isEmpty) return false;
    final command = _redo.removeLast()..apply();
    _undo.add(command);
    notifyListeners();
    return true;
  }
}
