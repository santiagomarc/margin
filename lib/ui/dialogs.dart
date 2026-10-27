import 'package:flutter/material.dart';

import 'theme.dart';

/// Asks for a name. Returns the trimmed text, or null when cancelled or
/// left empty.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  String initial = '',
  String hint = '',
  String confirmLabel = 'Save',
}) async {
  final result = await showDialog<String>(
    context: context,
    builder: (context) => _NameDialog(
      title: title,
      initial: initial,
      hint: hint,
      confirmLabel: confirmLabel,
    ),
  );
  final trimmed = result?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.initial,
    required this.hint,
    required this.confirmLabel,
  });

  final String title;
  final String initial;
  final String hint;
  final String confirmLabel;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final TextEditingController _text =
      TextEditingController(text: widget.initial)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initial.length,
        );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() => Navigator.of(context).pop(_text.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        child: TextField(
          controller: _text,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: widget.hint),
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _text,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: Text(widget.confirmLabel),
          ),
        ),
      ],
    );
  }
}

/// A row of colour swatches, each a 48 dp target.
class ColorSwatches extends StatelessWidget {
  const ColorSwatches({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (final color in SubjectColors.all)
          Semantics(
            button: true,
            selected: color == selected,
            label: SubjectColors.nameOf(color),
            child: InkWell(
              onTap: () => onSelected(color),
              customBorder: const CircleBorder(),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(color),
                      shape: BoxShape.circle,
                      border: color == selected
                          ? Border.all(color: MarginColors.ink, width: 3)
                          : null,
                    ),
                    child: color == selected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Asks for a subject's name and colour. Returns null when cancelled.
Future<(String, int)?> showSubjectDialog(
  BuildContext context, {
  required String title,
  String initialName = '',
  int? initialColor,
  String confirmLabel = 'Create',
}) {
  return showDialog<(String, int)>(
    context: context,
    builder: (context) => _SubjectDialog(
      title: title,
      initialName: initialName,
      initialColor: initialColor ?? SubjectColors.all.first,
      confirmLabel: confirmLabel,
    ),
  );
}

class _SubjectDialog extends StatefulWidget {
  const _SubjectDialog({
    required this.title,
    required this.initialName,
    required this.initialColor,
    required this.confirmLabel,
  });

  final String title;
  final String initialName;
  final int initialColor;
  final String confirmLabel;

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late int _color = widget.initialColor;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop((name, _color));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(hintText: 'Subject name'),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 16),
            ColorSwatches(
              selected: _color,
              onSelected: (c) => setState(() => _color = c),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ValueListenableBuilder(
          valueListenable: _name,
          builder: (context, value, _) => FilledButton(
            onPressed: value.text.trim().isEmpty ? null : _submit,
            child: Text(widget.confirmLabel),
          ),
        ),
      ],
    );
  }
}

/// Picks a colour on its own (Change colour). Returns null when cancelled.
Future<int?> showColorDialog(BuildContext context, {required int initial}) {
  return showDialog<int>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Subject colour'),
      content: SizedBox(
        width: 400,
        child: ColorSwatches(
          selected: initial,
          onSelected: (c) => Navigator.of(context).pop(c),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
