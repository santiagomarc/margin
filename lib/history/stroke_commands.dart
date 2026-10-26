import '../canvas/ink_layer.dart';
import '../canvas/ink_stroke.dart';
import '../db/ink_repository.dart';
import 'history.dart';

/// Adds a finished stroke to a page (and removes it again on undo).
class AddStrokeCommand implements Command {
  AddStrokeCommand({
    required this.ink,
    required this.repository,
    required this.pageId,
    required this.stroke,
  });

  final InkLayerController ink;
  final InkRepository repository;
  final String pageId;
  final InkStroke stroke;

  @override
  void apply() {
    ink.add(stroke);
    repository.saveStroke(pageId, stroke);
  }

  @override
  void revert() {
    ink.remove(stroke.id);
    repository.deleteStroke(stroke.id);
  }
}
