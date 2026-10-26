import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/app/margin_app.dart';

import '../helpers.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MarginApp(services: testServices()));
  }

  testWidgets('shows the scratch page card', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    expect(find.text('Scratch page'), findsOneWidget);
    expect(find.text('All notebooks'), findsWidgets);
  });

  testWidgets('hides the sidebar on narrow screens', (tester) async {
    await pumpAt(tester, const Size(600, 900));
    expect(find.text('SUBJECTS'), findsNothing);
    expect(find.text('Scratch page'), findsOneWidget);
  });

  // T3 10 screen: 1280×800.
  testWidgets('golden: library, landscape', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_landscape.png'),
    );
  });

  testWidgets('golden: library, portrait', (tester) async {
    await pumpAt(tester, const Size(800, 1280));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_portrait.png'),
    );
  });
}
