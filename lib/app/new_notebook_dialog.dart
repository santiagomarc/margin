import 'package:flutter/material.dart';

import '../canvas/paper_painter.dart';
import '../db/database.dart';
import '../ui/theme.dart';

/// What the New notebook dialog returns.
class NewNotebookChoice {
  const NewNotebookChoice(this.title, this.subjectId, this.template);

  final String title;
  final String? subjectId;
  final PaperTemplate template;
}

Future<NewNotebookChoice?> showNewNotebookDialog(
  BuildContext context, {
  required List<Subject> subjects,
  String? subjectId,
  required PaperTemplate template,
}) {
  return showDialog<NewNotebookChoice>(
    context: context,
    builder: (context) => _NewNotebookDialog(
      subjects: subjects,
      subjectId: subjectId,
      template: template,
    ),
  );
}

class _NewNotebookDialog extends StatefulWidget {
  const _NewNotebookDialog({
    required this.subjects,
    required this.subjectId,
    required this.template,
  });

  final List<Subject> subjects;
  final String? subjectId;
  final PaperTemplate template;

  @override
  State<_NewNotebookDialog> createState() => _NewNotebookDialogState();
}

class _NewNotebookDialogState extends State<_NewNotebookDialog> {
  final TextEditingController _title = TextEditingController();
  late String? _subjectId = widget.subjectId;
  late PaperTemplate _template = widget.template;

  static const untitled = 'Untitled notebook';

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _title.text.trim();
    Navigator.of(context).pop(
      NewNotebookChoice(
        title.isEmpty ? untitled : title,
        _subjectId,
        _template,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AlertDialog(
      title: const Text('New notebook'),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _title,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(hintText: untitled),
                onSubmitted: (_) => _submit(),
              ),
              if (widget.subjects.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Subject', style: text.labelLarge),
                const SizedBox(height: 4),
                DropdownButton<String?>(
                  value: _subjectId,
                  isExpanded: true,
                  onChanged: (id) => setState(() => _subjectId = id),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    for (final s in widget.subjects)
                      DropdownMenuItem(
                        value: s.id,
                        child: Row(
                          children: [
                            SubjectDot(color: s.color),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                s.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              Text('Paper', style: text.labelLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final template in PaperTemplate.values)
                    TemplateChoice(
                      template: template,
                      selected: template == _template,
                      onTap: () => setState(() => _template = template),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}

String templateLabel(PaperTemplate template) => switch (template) {
  PaperTemplate.blank => 'Blank',
  PaperTemplate.lined => 'Lined',
  PaperTemplate.grid => 'Grid',
  PaperTemplate.dotted => 'Dotted',
};

/// A small page preview of a paper template, selectable.
class TemplateChoice extends StatelessWidget {
  const TemplateChoice({
    super.key,
    required this.template,
    required this.selected,
    required this.onTap,
  });

  final PaperTemplate template;
  final bool selected;
  final VoidCallback onTap;

  static const _width = 72.0;

  @override
  Widget build(BuildContext context) {
    const page = PageSizes.a4;
    const scale = _width / 595.28;
    return Semantics(
      button: true,
      selected: selected,
      label: '${templateLabel(template)} paper',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              DecoratedBox(
                position: DecorationPosition.foreground,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? MarginColors.ink : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: SizedBox(
                  width: _width,
                  height: page.height * scale,
                  child: CustomPaint(
                    painter: PaperPainter(
                      template: template,
                      pageSize: page,
                      scale: scale,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                templateLabel(template),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? MarginColors.ink : MarginColors.textMuted,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A subject's colour dot.
class SubjectDot extends StatelessWidget {
  const SubjectDot({super.key, required this.color, this.size = 10});

  final int color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: Color(color), shape: BoxShape.circle),
    );
  }
}
