import '../db/database.dart';
import 'history.dart';

/// The open notebook's page order, as page commands change it.
abstract interface class PageList {
  /// Inserts [page] at [index] (adding its row if needed).
  void insertPage(int index, NotebookPage page);

  /// Takes the page out of the order. Its row and strokes stay until the
  /// notebook closes, so undo can bring it back.
  void removePage(String pageId);

  /// Moves a page to [index] in the order.
  void movePage(String pageId, int index);
}

class AddPageCommand implements Command {
  AddPageCommand(this.pages, this.page, this.index);

  final PageList pages;
  final NotebookPage page;
  final int index;

  @override
  void apply() => pages.insertPage(index, page);

  @override
  void revert() => pages.removePage(page.id);
}

class DeletePageCommand implements Command {
  DeletePageCommand(this.pages, this.page, this.index);

  final PageList pages;
  final NotebookPage page;
  final int index;

  @override
  void apply() => pages.removePage(page.id);

  @override
  void revert() => pages.insertPage(index, page);
}

class MovePageCommand implements Command {
  MovePageCommand(this.pages, this.pageId, this.from, this.to);

  final PageList pages;
  final String pageId;
  final int from;
  final int to;

  @override
  void apply() => pages.movePage(pageId, to);

  @override
  void revert() => pages.movePage(pageId, from);
}
