import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/app/app_scope.dart';
import 'package:margin/app/library_screen.dart';
import 'package:margin/app/margin_app.dart';
import 'package:margin/app/notebook_screen.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/library_repository.dart';

import '../helpers.dart';

void main() {
  late AppServices services;
  late LibraryRepository repo;

  setUp(() {
    services = testServices();
    repo = LibraryRepository(services.db, now: () => testNow);
  });

  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MarginApp(services: services));
    await tester.pumpAndSettle();
  }

  Future<void> pumpLibrary(WidgetTester tester) =>
      pumpAt(tester, const Size(1280, 800));

  /// Sets a notebook's last-edited time straight in the database.
  Future<void> setEdited(String id, DateTime time) {
    return (services.db.update(services.db.notebooks)
          ..where((n) => n.id.equals(id)))
        .write(NotebooksCompanion(updatedAt: Value(time)));
  }

  /// Subjects and notebooks for the goldens and sort tests.
  Future<void> seedLibrary() async {
    final bio = await repo.createSubject('Biology', 0xFF2E7D32);
    final history = await repo.createSubject('History', 0xFF1F5FBF);
    await repo.createSubject('Chemistry', 0xFF6A1B9A);
    final notebooks = [
      ('Cell structure', bio.id, PaperTemplate.lined, 26),
      ('Photosynthesis', bio.id, PaperTemplate.grid, 25),
      ('The Cold War', history.id, PaperTemplate.dotted, 24),
      ('Scratch page', null, PaperTemplate.blank, 20),
      ('Genetics', bio.id, PaperTemplate.lined, 12),
    ];
    for (final (title, subject, template, day) in notebooks) {
      final n = await repo.createNotebook(
        title: title,
        subjectId: subject,
        template: template,
      );
      await setEdited(n.id, DateTime.utc(2026, 10, day, 12));
    }
    // A PDF notebook (import arrives in R3): its first page is a PDF page.
    final pdf = await repo.createNotebook(
      title: 'Lecture 7 slides',
      subjectId: history.id,
    );
    await (services.db.update(
      services.db.notebooks,
    )..where((n) => n.id.equals(pdf.id))).write(
      NotebooksCompanion(
        kind: const Value(NotebookKind.pdf),
        updatedAt: Value(DateTime.utc(2026, 10, 22, 12)),
      ),
    );
    await (services.db.update(services.db.pages)
          ..where((p) => p.id.equals(pdf.pageIds.single)))
        .write(const PagesCompanion(background: Value(PdfBackground(0))));
  }

  Finder bySemantics(String label) => find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
  );

  Finder inSidebar(String text) =>
      find.descendant(of: find.byType(ListView), matching: find.text(text));

  List<String> cardTitles(WidgetTester tester) => [
    for (final card in tester.widgetList<NotebookCard>(
      find.byType(NotebookCard),
    ))
      card.notebook.title,
  ];

  Future<void> longPressMenu(
    WidgetTester tester,
    Finder target,
    String item,
  ) async {
    await tester.longPress(target);
    await tester.pumpAndSettle();
    await tester.tap(find.text(item).last);
    await tester.pumpAndSettle();
  }

  Future<void> enterName(
    WidgetTester tester,
    String name,
    String confirm,
  ) async {
    await tester.enterText(find.byType(TextField).last, name);
    await tester.tap(find.text(confirm));
    await tester.pumpAndSettle();
  }

  testWidgets('an empty library offers a new notebook', (tester) async {
    await pumpLibrary(tester);
    expect(find.text('No notebooks yet'), findsOneWidget);
    expect(find.text('New notebook'), findsOneWidget);
  });

  testWidgets('New → Notebook creates one with the chosen paper and opens it', (
    tester,
  ) async {
    await pumpLibrary(tester);
    await tester.tap(find.byTooltip('New'));
    await tester.pumpAndSettle();
    expect(find.text('Import PDF (coming in R3)'), findsOneWidget);
    await tester.tap(find.text('Notebook'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Mitosis');
    await tester.tap(bySemantics('Grid paper'));
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
    expect(find.byType(NotebookScreen), findsOneWidget);
    expect(find.text('Mitosis'), findsOneWidget);

    await tester.tap(find.byTooltip('Library'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), ['Mitosis']);
    final page = await services.db.select(services.db.pages).getSingle();
    expect(page.background, const TemplateBackground(PaperTemplate.grid));

    // The next notebook defaults to the paper picked last.
    await tester.tap(find.byTooltip('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notebook'));
    await tester.pumpAndSettle();
    final grid = tester.widget<Semantics>(
      find.ancestor(
        of: find.text('Grid'),
        matching: find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Grid paper',
        ),
      ),
    );
    expect(grid.properties.selected, isTrue);
  });

  testWidgets('subjects: create, rename, recolour, delete with Undo', (
    tester,
  ) async {
    await pumpLibrary(tester);
    await tester.tap(find.text('New subject'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Biology');
    await tester.tap(bySemantics('Red'));
    await tester.pump();
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    var subject = (await repo.subjects()).single;
    expect(subject.name, 'Biology');
    expect(subject.color, 0xFFC62828);
    // The new subject is selected and empty.
    expect(find.text('No notebooks in Biology'), findsOneWidget);

    await longPressMenu(tester, find.text('Biology').first, 'Rename');
    await enterName(tester, 'Cell biology', 'Save');
    expect(find.text('Cell biology'), findsWidgets);

    await longPressMenu(
      tester,
      find.text('Cell biology').first,
      'Change colour',
    );
    await tester.tap(bySemantics('Teal'));
    await tester.pumpAndSettle();
    subject = (await repo.subjects()).single;
    expect(subject.name, 'Cell biology');
    expect(subject.color, 0xFF00838F);

    await longPressMenu(tester, find.text('Cell biology').first, 'Delete');
    expect(await repo.subjects(), isEmpty);
    expect(find.text('All notebooks'), findsWidgets);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect((await repo.subjects()).single.name, 'Cell biology');
  });

  testWidgets('the sidebar counts notebooks per subject', (tester) async {
    await seedLibrary();
    await pumpLibrary(tester);
    Finder countIn(String label) => find.descendant(
      of: find.ancestor(of: find.text(label), matching: find.byType(Row)).first,
      matching: find.byType(Text),
    );
    String count(String label) =>
        tester.widgetList<Text>(countIn(label)).last.data!;
    expect(count('All notebooks'), '6');
    expect(count('Biology'), '3');
    expect(count('History'), '2');
    expect(count('Chemistry'), '0');

    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), ['The Cold War', 'Lecture 7 slides']);
  });

  testWidgets('sorts by recent or title, and the choice is kept', (
    tester,
  ) async {
    await seedLibrary();
    await pumpLibrary(tester);
    expect(cardTitles(tester), [
      'Cell structure',
      'Photosynthesis',
      'The Cold War',
      'Lecture 7 slides',
      'Scratch page',
      'Genetics',
    ]);

    await tester.tap(find.byTooltip('Sort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title').last);
    await tester.pumpAndSettle();
    expect(cardTitles(tester), [
      'Cell structure',
      'Genetics',
      'Lecture 7 slides',
      'Photosynthesis',
      'Scratch page',
      'The Cold War',
    ]);

    // Reopening the app keeps the sort.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(MarginApp(services: services));
    await tester.pumpAndSettle();
    expect(cardTitles(tester).first, 'Cell structure');
    expect(cardTitles(tester)[1], 'Genetics');
  });

  testWidgets('Recent shows notebooks edited in the last two weeks', (
    tester,
  ) async {
    await seedLibrary();
    await pumpLibrary(tester);
    await tester.tap(inSidebar('Recent'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), isNot(contains('Genetics')));
    expect(cardTitles(tester), hasLength(5));
  });

  testWidgets('search filters by title', (tester) async {
    await seedLibrary();
    await pumpLibrary(tester);
    await tester.tap(find.byTooltip('Search titles'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'PHOTO');
    await tester.pump();
    expect(cardTitles(tester), ['Photosynthesis']);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pump();
    expect(find.text('No notebooks match "zzz"'), findsOneWidget);

    await tester.tap(find.byTooltip('Close search'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), hasLength(6));
  });

  testWidgets('card menu: rename, move, duplicate', (tester) async {
    final bio = await repo.createSubject('Biology', 0xFF2E7D32);
    await repo.createNotebook(title: 'Draft');
    await pumpLibrary(tester);

    await longPressMenu(tester, find.text('Draft'), 'Rename');
    await enterName(tester, 'Mitosis', 'Save');
    expect(cardTitles(tester), ['Mitosis']);

    await longPressMenu(tester, find.text('Mitosis'), 'Move to subject');
    await tester.tap(find.text('Biology').last);
    await tester.pumpAndSettle();
    expect((await repo.notebooks()).single.notebook.subjectId, bio.id);
    expect(find.text('Oct 27 · Biology'), findsOneWidget);

    await longPressMenu(tester, find.text('Mitosis'), 'Duplicate');
    expect(cardTitles(tester), unorderedEquals(['Mitosis', 'Mitosis copy']));
  });

  testWidgets('deleting a notebook can be undone for 5 seconds', (
    tester,
  ) async {
    await repo.createNotebook(title: 'Keep me');
    await repo.createNotebook(title: 'Delete me');
    await pumpLibrary(tester);

    await longPressMenu(tester, find.text('Keep me'), 'Delete');
    expect(cardTitles(tester), ['Delete me']);
    expect(find.text('Notebook deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(cardTitles(tester), unorderedEquals(['Keep me', 'Delete me']));
    expect(await repo.notebooks(), hasLength(2));

    await longPressMenu(tester, find.text('Delete me'), 'Delete');
    expect(await repo.notebooks(), hasLength(2), reason: 'still undoable');
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect((await repo.notebooks()).single.title, 'Keep me');
  });

  testWidgets('a card shows the date of the last writing', (tester) async {
    await LibraryRepository(
      services.db,
      now: () => DateTime.utc(2026, 10, 20, 12),
    ).createNotebook(title: 'Cells');
    await pumpLibrary(tester);
    expect(find.text('Oct 20'), findsOneWidget);

    await tester.tap(find.text('Cells'));
    await tester.pumpAndSettle();
    final pen = await tester.createGesture();
    await pen.down(const Offset(300, 300));
    await pen.moveTo(const Offset(500, 320));
    await pen.up();
    await tester.tap(find.byTooltip('Library'));
    await tester.pumpAndSettle();
    expect(find.text('Oct 27'), findsOneWidget);
  });

  testWidgets('narrow screens move subjects into a drawer', (tester) async {
    await repo.createSubject('Biology', 0xFF2E7D32);
    await pumpAt(tester, const Size(600, 960));
    expect(find.text('SUBJECTS'), findsNothing);
    await tester.tap(find.byTooltip('Subjects'));
    await tester.pumpAndSettle();
    expect(find.text('SUBJECTS'), findsOneWidget);
    await tester.tap(find.text('Biology'));
    await tester.pumpAndSettle();
    expect(find.text('SUBJECTS'), findsNothing);
    expect(find.text('No notebooks in Biology'), findsOneWidget);
  });

  // T3 10 screen: 1280×800.
  testWidgets('golden: library with notebooks, landscape', (tester) async {
    await seedLibrary();
    await pumpAt(tester, const Size(1280, 800));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_landscape.png'),
    );
  });

  testWidgets('golden: library with notebooks, portrait', (tester) async {
    await seedLibrary();
    await pumpAt(tester, const Size(800, 1280));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_portrait.png'),
    );
  });

  testWidgets('golden: empty library', (tester) async {
    await pumpAt(tester, const Size(1280, 800));
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/library_empty.png'),
    );
  });
}
