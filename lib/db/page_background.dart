import 'dart:ui';

enum PaperTemplate { blank, lined, grid, dotted }

/// Paper sizes in points (1/72 inch).
abstract final class PageSizes {
  static const a4 = Size(595.28, 841.89);
  static const letter = Size(612, 792);
}

/// What is drawn under a page's ink: a paper template or a page of the
/// notebook's PDF.
sealed class PageBackground {
  const PageBackground();

  factory PageBackground.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'template' => TemplateBackground(
        PaperTemplate.values.byName(json['template'] as String),
      ),
      'pdf' => PdfBackground(json['pageIndex'] as int),
      final type => throw FormatException('Unknown page background: $type'),
    };
  }

  Map<String, dynamic> toJson();
}

final class TemplateBackground extends PageBackground {
  const TemplateBackground(this.template);

  final PaperTemplate template;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'template',
    'template': template.name,
  };

  @override
  bool operator ==(Object other) =>
      other is TemplateBackground && other.template == template;

  @override
  int get hashCode => template.hashCode;
}

final class PdfBackground extends PageBackground {
  const PdfBackground(this.pageIndex);

  /// Zero-based page index in the notebook's PDF file.
  final int pageIndex;

  @override
  Map<String, dynamic> toJson() => {'type': 'pdf', 'pageIndex': pageIndex};

  @override
  bool operator ==(Object other) =>
      other is PdfBackground && other.pageIndex == pageIndex;

  @override
  int get hashCode => pageIndex.hashCode;
}
