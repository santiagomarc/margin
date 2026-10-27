import 'package:drift/native.dart';
import 'package:margin/app/app_scope.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/library_repository.dart';
import 'package:margin/diagnostics/diagnostics.dart';

/// The fixed "now" of widget tests, so dates in goldens never change.
final testNow = DateTime.utc(2026, 10, 27, 12);

/// App services backed by an in-memory database and a fixed clock.
AppServices testServices() => AppServices(
  db: MarginDatabase(NativeDatabase.memory()),
  diagnostics: Diagnostics(),
  now: () => testNow,
);

/// Creates a notebook (one page of [template]) and returns its first page.
Future<NotebookPage> createTestNotebook(
  MarginDatabase db, {
  String title = 'Cell structure',
  PaperTemplate template = PaperTemplate.lined,
}) async {
  final notebook = await LibraryRepository(
    db,
    now: () => testNow,
  ).createNotebook(title: title, template: template);
  return (db.select(
    db.pages,
  )..where((p) => p.id.equals(notebook.pageIds.first))).getSingle();
}
