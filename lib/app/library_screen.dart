import 'dart:async';

import 'package:flutter/material.dart';

import '../canvas/paper_painter.dart';
import '../db/database.dart';
import '../db/library_repository.dart';
import '../db/settings_repository.dart';
import '../state/library_controller.dart';
import '../ui/dialogs.dart';
import '../ui/format.dart';
import '../ui/theme.dart';
import 'app_scope.dart';
import 'new_notebook_dialog.dart';
import 'notebook_screen.dart';

/// The first screen: subjects on the left, a grid of notebooks on the right.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  static const sidebarWidth = 260.0;
  static const sidebarBreakpoint = 720.0;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

enum _CardAction { rename, move, duplicate, delete }

enum _SubjectAction { rename, recolor, delete }

class _LibraryScreenState extends State<LibraryScreen> {
  LibraryController? _controller;
  late DateTime Function() _now;
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  LibraryController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller != null) return;
    final services = AppScope.of(context);
    _now = services.now;
    _controller = LibraryController(
      repository: LibraryRepository(services.db, now: services.now),
      settings: SettingsRepository(services.db),
      now: services.now,
    );
    _guard(controller.load());
  }

  @override
  void dispose() {
    unawaited(controller.commitAllDeletes().catchError((Object _) {}));
    controller.dispose();
    super.dispose();
  }

  /// Runs a library change; a failure is logged and shown with what to do.
  Future<T?> _guard<T>(Future<T> future) async {
    try {
      return await future;
    } catch (error, stack) {
      if (!mounted) return null;
      AppScope.of(context).diagnostics.log.error(error, stack);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Couldn't save that change. Try again; if it keeps failing, "
            'copy a bug report from a notebook\'s More menu.',
          ),
        ),
      );
      return null;
    }
  }

  void _closeDrawer() {
    if (_scaffold.currentState?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _open(String notebookId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotebookScreen(
          notebookId: notebookId,
          // Its last strokes are saved after it closes: show their date.
          onClosed: () {
            if (mounted) _guard(controller.refresh());
          },
        ),
      ),
    );
    if (mounted) await _guard(controller.refresh());
  }

  Future<void> _newNotebook() async {
    final choice = await showNewNotebookDialog(
      context,
      subjects: controller.subjects,
      subjectId: controller.currentSubjectId,
      template: controller.defaultTemplate,
    );
    if (choice == null) return;
    final notebook = await _guard(
      controller.createNotebook(
        title: choice.title,
        subjectId: choice.subjectId,
        template: choice.template,
      ),
    );
    if (notebook != null && mounted) await _open(notebook.id);
  }

  Future<void> _newSubject() async {
    _closeDrawer();
    final result = await showSubjectDialog(
      context,
      title: 'New subject',
      initialColor: SubjectColors
          .all[controller.subjects.length % SubjectColors.all.length],
    );
    if (result == null) return;
    final subject = await _guard(
      controller.createSubject(result.$1, result.$2),
    );
    if (subject != null) controller.setFilter(SubjectNotebooks(subject.id));
  }

  Future<void> _cardMenu(NotebookSummary notebook, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<_CardAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: _CardAction.rename, child: Text('Rename')),
        PopupMenuItem(value: _CardAction.move, child: Text('Move to subject')),
        PopupMenuItem(value: _CardAction.duplicate, child: Text('Duplicate')),
        PopupMenuItem(value: _CardAction.delete, child: Text('Delete')),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _CardAction.rename:
        final title = await showNameDialog(
          context,
          title: 'Rename notebook',
          initial: notebook.title,
        );
        if (title != null) {
          await _guard(controller.renameNotebook(notebook.id, title));
        }
      case _CardAction.move:
        await _moveNotebook(notebook);
      case _CardAction.duplicate:
        await _guard(controller.duplicateNotebook(notebook.id));
      case _CardAction.delete:
        _deleteNotebook(notebook);
    }
  }

  Future<void> _moveNotebook(NotebookSummary notebook) async {
    final current = notebook.notebook.subjectId;
    final picked = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to subject'),
        children: [
          _SubjectOption(
            label: 'No subject',
            selected: current == null,
            onTap: () => Navigator.of(context).pop((null,)),
          ),
          for (final s in controller.subjects)
            _SubjectOption(
              label: s.name,
              color: s.color,
              selected: current == s.id,
              onTap: () => Navigator.of(context).pop((s.id,)),
            ),
        ],
      ),
    );
    if (picked == null || picked.$1 == current) return;
    await _guard(controller.moveNotebook(notebook.id, picked.$1));
  }

  void _deleteNotebook(NotebookSummary notebook) {
    controller.deleteNotebook(notebook.id);
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger
        .showSnackBar(
          SnackBar(
            content: const Text('Notebook deleted'),
            duration: const Duration(seconds: 5),
            // Undo snackbars would otherwise stay until dismissed.
            persist: false,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => controller.undoDelete(notebook.id),
            ),
          ),
        )
        .closed
        .then((reason) {
          if (reason != SnackBarClosedReason.action) {
            _guard(controller.commitDelete(notebook.id));
          }
        });
  }

  Future<void> _subjectMenu(Subject subject, Offset position) async {
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final action = await showMenu<_SubjectAction>(
      context: context,
      position: RelativeRect.fromRect(
        position & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: const [
        PopupMenuItem(value: _SubjectAction.rename, child: Text('Rename')),
        PopupMenuItem(
          value: _SubjectAction.recolor,
          child: Text('Change colour'),
        ),
        PopupMenuItem(value: _SubjectAction.delete, child: Text('Delete')),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case _SubjectAction.rename:
        final name = await showNameDialog(
          context,
          title: 'Rename subject',
          initial: subject.name,
        );
        if (name != null) {
          await _guard(controller.renameSubject(subject.id, name));
        }
      case _SubjectAction.recolor:
        final color = await showColorDialog(context, initial: subject.color);
        if (color != null) {
          await _guard(controller.recolorSubject(subject.id, color));
        }
      case _SubjectAction.delete:
        final deletion = await _guard(controller.deleteSubject(subject.id));
        if (deletion == null || !mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text('Subject "${subject.name}" deleted'),
              duration: const Duration(seconds: 5),
              // Undo snackbars would otherwise stay until dismissed.
              persist: false,
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () => _guard(controller.restoreSubject(deletion)),
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= LibraryScreen.sidebarBreakpoint;
        final sidebar = _Sidebar(
          controller: controller,
          onSelect: (filter) {
            _closeDrawer();
            controller.setFilter(filter);
          },
          onNewSubject: _newSubject,
          onSubjectMenu: _subjectMenu,
        );
        return Scaffold(
          key: _scaffold,
          drawer: wide
              ? null
              : Drawer(
                  width: LibraryScreen.sidebarWidth,
                  backgroundColor: MarginColors.sidebar,
                  elevation: 0,
                  shape: const RoundedRectangleBorder(),
                  child: SafeArea(child: sidebar),
                ),
          body: SafeArea(
            child: Row(
              children: [
                if (wide)
                  SizedBox(width: LibraryScreen.sidebarWidth, child: sidebar),
                Expanded(
                  child: ListenableBuilder(
                    listenable: controller,
                    builder: (context, _) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(
                          controller: controller,
                          onMenu: wide
                              ? null
                              : () => _scaffold.currentState?.openDrawer(),
                          onNewNotebook: _newNotebook,
                        ),
                        Expanded(child: _body()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body() {
    if (!controller.isLoaded) return const SizedBox();
    final notebooks = controller.visible;
    if (notebooks.isEmpty) {
      return _EmptyState(controller: controller, onNewNotebook: _newNotebook);
    }
    return _NotebookGrid(
      notebooks: notebooks,
      subjectOf: controller.subjectOf,
      now: _now(),
      onOpen: _open,
      onMenu: _cardMenu,
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.controller,
    required this.onSelect,
    required this.onNewSubject,
    required this.onSubjectMenu,
  });

  final LibraryController controller;
  final ValueChanged<LibraryFilter> onSelect;
  final VoidCallback onNewSubject;
  final void Function(Subject subject, Offset position) onSubjectMenu;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: MarginColors.sidebar,
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 16),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'Margin',
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: MarginColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _SidebarItem(
              icon: Icons.library_books_outlined,
              label: 'All notebooks',
              count: controller.totalCount,
              selected: controller.filter == const AllNotebooks(),
              onTap: () => onSelect(const AllNotebooks()),
            ),
            _SidebarItem(
              icon: Icons.schedule,
              label: 'Recent',
              selected: controller.filter == const RecentNotebooks(),
              onTap: () => onSelect(const RecentNotebooks()),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Text(
                'SUBJECTS',
                style: text.labelSmall?.copyWith(
                  color: MarginColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            for (final subject in controller.subjects)
              _SidebarItem(
                color: subject.color,
                label: subject.name,
                count: controller.countFor(subject.id),
                selected: controller.filter == SubjectNotebooks(subject.id),
                onTap: () => onSelect(SubjectNotebooks(subject.id)),
                onLongPress: (position) => onSubjectMenu(subject, position),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onNewSubject,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('New subject'),
                style: TextButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: MarginColors.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color,
    this.count,
    this.onLongPress,
  });

  final IconData? icon;
  final int? color;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;
  final ValueChanged<Offset>? onLongPress;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? MarginColors.ink : MarginColors.textMuted;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? MarginColors.paper : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: GestureDetector(
            onLongPressStart: onLongPress == null
                ? null
                : (details) => onLongPress!(details.globalPosition),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Center(
                        child: color != null
                            ? SubjectDot(color: color!)
                            : Icon(icon, size: 20, color: foreground),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyLarge?.copyWith(
                          color: selected ? MarginColors.ink : null,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (count != null)
                      Text(
                        '$count',
                        style: text.bodyMedium?.copyWith(
                          color: MarginColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatefulWidget {
  const _Header({
    required this.controller,
    required this.onMenu,
    required this.onNewNotebook,
  });

  final LibraryController controller;
  final VoidCallback? onMenu;
  final VoidCallback onNewNotebook;

  @override
  State<_Header> createState() => _HeaderState();
}

class _HeaderState extends State<_Header> {
  final TextEditingController _search = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _closeSearch() {
    _search.clear();
    widget.controller.setQuery('');
    setState(() => _searching = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(widget.onMenu == null ? 32 : 8, 16, 24, 8),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            if (widget.onMenu != null)
              IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Subjects',
                onPressed: widget.onMenu,
              ),
            Expanded(
              child: _searching
                  ? TextField(
                      controller: _search,
                      autofocus: true,
                      onChanged: controller.setQuery,
                      decoration: InputDecoration(
                        hintText: 'Search titles',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close search',
                          onPressed: _closeSearch,
                        ),
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                    )
                  : Text(
                      controller.heading,
                      overflow: TextOverflow.ellipsis,
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<LibrarySort>(
              tooltip: 'Sort',
              initialValue: controller.sort,
              onSelected: controller.setSort,
              itemBuilder: (context) => [
                CheckedPopupMenuItem(
                  value: LibrarySort.recent,
                  checked: controller.sort == LibrarySort.recent,
                  child: const Text('Recent'),
                ),
                CheckedPopupMenuItem(
                  value: LibrarySort.title,
                  checked: controller.sort == LibrarySort.title,
                  child: const Text('Title'),
                ),
              ],
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.sort,
                        size: 20,
                        color: MarginColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.sort == LibrarySort.recent
                            ? 'Recent'
                            : 'Title',
                        style: text.bodyLarge,
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ),
            if (!_searching)
              IconButton(
                icon: const Icon(Icons.search),
                tooltip: 'Search titles',
                onPressed: () => setState(() => _searching = true),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<int>(
              tooltip: 'New',
              onSelected: (_) => widget.onNewNotebook(),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 0, child: Text('Notebook')),
                PopupMenuItem(
                  enabled: false,
                  child: Text('Import PDF (coming in R3)'),
                ),
              ],
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: MarginColors.ink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 20, color: MarginColors.paper),
                    const SizedBox(width: 6),
                    Text(
                      'New',
                      style: text.labelLarge?.copyWith(
                        color: MarginColors.paper,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotebookGrid extends StatelessWidget {
  const _NotebookGrid({
    required this.notebooks,
    required this.subjectOf,
    required this.now,
    required this.onOpen,
    required this.onMenu,
  });

  final List<NotebookSummary> notebooks;
  final Subject? Function(String? id) subjectOf;
  final DateTime now;
  final ValueChanged<String> onOpen;
  final void Function(NotebookSummary notebook, Offset position) onMenu;

  static const _minCardWidth = 200.0;

  /// Thumbnail height / width: the top three quarters of an A4 page.
  static const thumbAspect = 1.06;
  static const _spacing = 24.0;
  static const _textHeight = 56.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 32.0;
        final width = constraints.maxWidth - 2 * padding;
        final columns = ((width + _spacing) / (_minCardWidth + _spacing))
            .floor()
            .clamp(2, 6);
        final cardWidth = (width - (columns - 1) * _spacing) / columns;
        final thumbHeight = cardWidth * thumbAspect;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(padding, 16, padding, 32),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            mainAxisExtent: thumbHeight + _textHeight,
          ),
          itemCount: notebooks.length,
          itemBuilder: (context, index) {
            final notebook = notebooks[index];
            return NotebookCard(
              key: ValueKey(notebook.id),
              notebook: notebook,
              subject: subjectOf(notebook.notebook.subjectId),
              now: now,
              thumbHeight: thumbHeight,
              onOpen: () => onOpen(notebook.id),
              onMenu: (position) => onMenu(notebook, position),
            );
          },
        );
      },
    );
  }
}

/// A notebook in the library grid: first-page preview, title, date and
/// subject colour. Tap opens; long-press opens its menu.
class NotebookCard extends StatelessWidget {
  const NotebookCard({
    super.key,
    required this.notebook,
    required this.subject,
    required this.now,
    required this.thumbHeight,
    required this.onOpen,
    required this.onMenu,
  });

  final NotebookSummary notebook;
  final Subject? subject;
  final DateTime now;
  final double thumbHeight;
  final VoidCallback onOpen;
  final ValueChanged<Offset> onMenu;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final page = notebook.firstPage;
    final background = page?.background;
    final pageSize = page == null
        ? PageSizes.a4
        : Size(page.width, page.height);
    final isPdf = notebook.notebook.kind == NotebookKind.pdf;
    return Semantics(
      button: true,
      label: 'Open ${notebook.title}',
      child: GestureDetector(
        onTap: onOpen,
        onLongPressStart: (details) => onMenu(details.globalPosition),
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: thumbHeight,
              width: double.infinity,
              // The top of the first page, fitted to the card's width.
              child: DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(color: MarginColors.divider),
                ),
                child: ClipRect(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final scale = constraints.maxWidth / pageSize.width;
                      return Stack(
                        children: [
                          OverflowBox(
                            alignment: Alignment.topLeft,
                            maxHeight: double.infinity,
                            child: SizedBox.fromSize(
                              size: pageSize * scale,
                              child: CustomPaint(
                                painter: PaperPainter(
                                  template: background is TemplateBackground
                                      ? background.template
                                      : PaperTemplate.blank,
                                  pageSize: pageSize,
                                  scale: scale,
                                ),
                              ),
                            ),
                          ),
                          if (subject != null)
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              width: 4,
                              child: ColoredBox(color: Color(subject!.color)),
                            ),
                          if (isPdf)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: MarginColors.ink,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'PDF',
                                  style: text.labelSmall?.copyWith(
                                    color: MarginColors.paper,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notebook.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                if (subject != null) ...[
                  SubjectDot(color: subject!.color, size: 8),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    [
                      formatShortDate(notebook.notebook.updatedAt, now),
                      if (subject != null) subject!.name,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.bodySmall?.copyWith(
                      color: MarginColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectOption extends StatelessWidget {
  const _SubjectOption({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final int? color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      onPressed: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: color == null
                  ? const Icon(Icons.block, size: 16)
                  : SubjectDot(color: color!),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            if (selected) const Icon(Icons.check, color: MarginColors.ink),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.controller, required this.onNewNotebook});

  final LibraryController controller;
  final VoidCallback onNewNotebook;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final query = controller.query.trim();
    final (title, body) = switch (controller.filter) {
      _ when query.isNotEmpty => (
        'No notebooks match "$query"',
        'Try a shorter or different word.',
      ),
      SubjectNotebooks() => (
        'No notebooks in ${controller.heading}',
        controller.hasNotebooks
            ? 'Create one here, or move one in from its menu '
                  '(long-press a card).'
            : 'Create one here to start writing.',
      ),
      RecentNotebooks() when controller.hasNotebooks => (
        'Nothing edited lately',
        'Notebooks you edit in the next two weeks show up here.',
      ),
      _ => ('No notebooks yet', 'Create a notebook to start writing.'),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: text.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: MarginColors.textMuted),
            ),
            if (query.isEmpty) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onNewNotebook,
                icon: const Icon(Icons.add),
                label: const Text('New notebook'),
                style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
