import 'package:flutter/material.dart';

import '../canvas/paper_painter.dart';
import '../db/ink_repository.dart';
import '../db/page_background.dart';
import '../ui/theme.dart';
import 'notebook_screen.dart';

/// The first screen: subjects on the left, notebooks on the right.
///
/// For now it only holds the scratch page; subjects and notebooks arrive in
/// Session 2.
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
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          child: _NotebookCard(
            title: 'Scratch page',
            subtitle: 'Try the pen here',
            onOpen: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const NotebookScreen()),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 24, 32, 0),
          child: Text(
            'Notebooks, subjects and PDF import arrive in the next updates.',
            style: text.bodyMedium?.copyWith(color: MarginColors.textMuted),
          ),
        ),
      ],
    );
  }
}

/// A notebook in the library grid: a page preview, title and subtitle.
class _NotebookCard extends StatelessWidget {
  const _NotebookCard({
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  static const width = 150.0;

  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const page = InkRepository.a4;
    const scale = width / 595.28;
    return Semantics(
      button: true,
      label: 'Open $title',
      child: GestureDetector(
        onTap: onOpen,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: width,
                height: page.height * scale,
                child: CustomPaint(
                  painter: PaperPainter(
                    template: PaperTemplate.lined,
                    pageSize: page,
                    scale: scale,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                subtitle,
                style: text.bodySmall?.copyWith(color: MarginColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
