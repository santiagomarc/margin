import '../canvas/ink_stroke.dart';
import '../state/page_ink_store.dart';
import 'history.dart';

/// Adds a finished stroke to a page (and removes it again on undo).
class AddStrokeCommand implements Command {
  AddStrokeCommand({
    required this.ink,
    required this.pageId,
    required this.stroke,
  });

  final PageInkStore ink;
  final String pageId;
  final InkStroke stroke;

  @override
  void apply() => ink.addStroke(pageId, stroke);

  @override
  void revert() => ink.removeStroke(pageId, stroke.id);
}
