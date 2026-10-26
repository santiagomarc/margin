import 'package:flutter/material.dart';

import '../history/history.dart';
import 'theme.dart';

enum MoreAction { toggleDiagnostics, copyBugReport }

/// The notebook toolbar from docs/PLAN.md, "Screens": back and title on the
/// left, tools in the middle, undo/redo/review/pages/more on the right.
class NotebookToolbar extends StatelessWidget {
  const NotebookToolbar({
    super.key,
    required this.title,
    required this.history,
    required this.diagnosticsVisible,
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onMore,
  });

  static const height = 56.0;

  final String title;
  final History history;
  final bool diagnosticsVisible;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final ValueChanged<MoreAction> onMore;

  /// Below this width the tools stop being exactly centred, so the title can
  /// shrink instead of the right-hand buttons overflowing (portrait T3 8").
  static const centredMinWidth = 760.0;

  @override
  Widget build(BuildContext context) {
    final left = Row(
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Library',
          onPressed: onBack,
        ),
        Flexible(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
    const tools = [
      _ToolButton(icon: Icons.edit_outlined, label: 'Pen', selected: true),
      _ToolButton(
        icon: Icons.border_color_outlined,
        label: 'Highlighter (coming in R4)',
      ),
      _ToolButton(icon: Icons.auto_fix_normal, label: 'Eraser (coming in R4)'),
      _ToolButton(icon: Icons.crop_16_9, label: 'Tape (coming in R5)'),
    ];
    final right = _actions();
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: MarginColors.desk,
        border: Border(bottom: BorderSide(color: MarginColors.divider)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: LayoutBuilder(
        builder: (context, constraints) =>
            constraints.maxWidth >= centredMinWidth
            ? Row(
                children: [
                  Expanded(child: left),
                  ...tools,
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: right,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(child: left),
                  ...tools,
                  right,
                ],
              ),
      ),
    );
  }

  Widget _actions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListenableBuilder(
          listenable: history,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Undo (two-finger tap)',
                onPressed: history.canUndo ? onUndo : null,
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                tooltip: 'Redo (three-finger tap)',
                onPressed: history.canRedo ? onRedo : null,
              ),
            ],
          ),
        ),
        const IconButton(
          icon: Icon(Icons.visibility_outlined),
          tooltip: 'Review (coming in R5)',
          onPressed: null,
        ),
        const IconButton(
          icon: Icon(Icons.grid_view_outlined),
          tooltip: 'Pages (coming in R6)',
          onPressed: null,
        ),
        PopupMenuButton<MoreAction>(
          icon: const Icon(Icons.more_horiz),
          tooltip: 'More',
          onSelected: onMore,
          itemBuilder: (context) => [
            CheckedPopupMenuItem(
              value: MoreAction.toggleDiagnostics,
              checked: diagnosticsVisible,
              child: const Text('Diagnostics'),
            ),
            const PopupMenuItem(
              value: MoreAction.copyBugReport,
              child: Text('Copy bug report'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final enabled = selected;
    return Tooltip(
      message: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Container(
          width: 48,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? MarginColors.ink : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 24,
            color: selected
                ? MarginColors.paper
                : MarginColors.textMuted.withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}
