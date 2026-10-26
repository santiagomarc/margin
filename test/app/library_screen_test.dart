import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/app/margin_app.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MarginApp());
  }

  testWidgets('shows the empty state', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.text('No notebooks yet'), findsOneWidget);
    expect(find.text('All notebooks'), findsWidgets);
  });

  testWidgets('hides the sidebar on narrow screens', (tester) async {
    await pumpAt(tester, const Size(600, 900));
    expect(find.text('SUBJECTS'), findsNothing);
    expect(find.text('No notebooks yet'), findsOneWidget);
  });

  // T3 10 screen: 1280×800.
  testWidgets('golden: empty library, landscape', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_empty_landscape.png'),
    );
  });

  testWidgets('golden: empty library, portrait', (tester) async {
    await pumpAt(tester, const Size(800, 1280));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_empty_portrait.png'),
    );
  });
}
