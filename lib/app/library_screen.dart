import 'package:flutter/material.dart';

import '../ui/theme.dart';

/// The first screen: subjects on the left, notebooks on the right.
///
/// Empty for now; subjects and notebooks arrive in Session 2.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const _sidebarWidth = 260.0;
  static const _sidebarBreakpoint = 720.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final showSidebar = constraints.maxWidth >= _sidebarBreakpoint;
            return Row(
              children: [
                if (showSidebar)
                  const SizedBox(width: _sidebarWidth, child: _Sidebar()),
                const Expanded(child: _NotebookArea()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ColoredBox(
      color: MarginColors.sidebar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 12, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Margin',
              style: text.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: MarginColors.ink,
              ),
            ),
            const SizedBox(height: 28),
            const _SidebarItem(
              icon: Icons.library_books_outlined,
              label: 'All notebooks',
              selected: true,
            ),
            const _SidebarItem(icon: Icons.schedule, label: 'Recent'),
            const SizedBox(height: 28),
            Text(
              'SUBJECTS',
              style: text.labelSmall?.copyWith(
                color: MarginColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No subjects yet',
              style: text.bodyMedium?.copyWith(color: MarginColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? MarginColors.ink : MarginColors.textMuted;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? MarginColors.paper : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotebookArea extends StatelessWidget {
  const _NotebookArea();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 28, 32, 0),
          child: Text(
            'All notebooks',
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    color: MarginColors.paper,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book_outlined,
                    size: 40,
                    color: MarginColors.ink,
                  ),
                ),
                const SizedBox(height: 20),
                Text('No notebooks yet', style: text.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Your notebooks and imported PDFs will show up here.',
                  style: text.bodyMedium?.copyWith(
                    color: MarginColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
