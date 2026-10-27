import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/canvas/paper_painter.dart';
import 'package:margin/db/page_background.dart';

void main() {
  // Half of A4 at the T3's fit-width scale in portrait (about 1.24×), so
  // rules, dots and the margin line are all visible at real size.
  const scale = (800 - 48) / 595.28;
  final size = Size(PageSizes.a4.width * scale, PageSizes.a4.height * scale);

  for (final template in PaperTemplate.values) {
    testWidgets('golden: ${template.name} paper', (tester) async {
      tester.view.physicalSize = Size(size.width + 48, size.height / 2);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ColoredBox(
          color: const Color(0xFFF4F2EE),
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: RepaintBoundary(
                key: const ValueKey('page'),
                child: CustomPaint(
                  size: size,
                  painter: PaperPainter(
                    template: template,
                    pageSize: PageSizes.a4,
                    scale: scale,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await expectLater(
        find.byType(ColoredBox),
        matchesGoldenFile('goldens/paper_${template.name}.png'),
      );
    });
  }

  test('repaints only when something it draws changes', () {
    PaperPainter painter(PaperTemplate t, double s) =>
        PaperPainter(template: t, pageSize: PageSizes.a4, scale: s);
    final lined = painter(PaperTemplate.lined, 1);
    expect(lined.shouldRepaint(painter(PaperTemplate.lined, 1)), isFalse);
    expect(lined.shouldRepaint(painter(PaperTemplate.grid, 1)), isTrue);
    expect(lined.shouldRepaint(painter(PaperTemplate.lined, 2)), isTrue);
  });
}
