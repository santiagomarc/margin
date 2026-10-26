import 'package:drift/drift.dart';

import 'converters.dart';

// Schema from docs/PLAN.md, "Data model". All positions are page coordinates
// (PDF points, 1/72 inch). Ids are client-generated strings.

enum NotebookKind { notes, pdf }

enum StrokeTool { pen, highlighter }

enum StudyResult { got, missed }

class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// ARGB color value.
  IntColumn get color => integer()();
  IntColumn get sortOrder => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class PdfFiles extends Table {
  TextColumn get id => text()();

  /// Path of the copy inside app storage.
  TextColumn get path => text()();
  IntColumn get pageCount => integer()();
  TextColumn get sha256 => text().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Notebooks extends Table {
  TextColumn get id => text()();
  TextColumn get subjectId => text().nullable().references(
    Subjects,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get title => text()();
  TextColumn get kind => textEnum<NotebookKind>()();
  TextColumn get pdfFileId => text().nullable().references(PdfFiles, #id)();

  /// Page order. Reordering pages rewrites only this column.
  TextColumn get pageIds => text().map(const StringListConverter())();
  IntColumn get createdAt => integer().map(const MillisDateTimeConverter())();
  IntColumn get updatedAt => integer().map(const MillisDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// Named NotebookPage so it doesn't clash with Flutter's Page widget.
@DataClassName('NotebookPage')
@TableIndex(name: 'pages_notebook_id', columns: {#notebookId})
class Pages extends Table {
  TextColumn get id => text()();
  TextColumn get notebookId =>
      text().references(Notebooks, #id, onDelete: KeyAction.cascade)();
  RealColumn get width => real()();
  RealColumn get height => real()();
  TextColumn get background => text().map(const PageBackgroundConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'strokes_page_id', columns: {#pageId})
class Strokes extends Table {
  TextColumn get id => text()();
  TextColumn get pageId =>
      text().references(Pages, #id, onDelete: KeyAction.cascade)();
  TextColumn get tool => textEnum<StrokeTool>()();

  /// ARGB color value.
  IntColumn get color => integer()();
  RealColumn get size => real()();

  /// x, y, pressure repeated.
  BlobColumn get points => blob().map(const Float32ListConverter())();

  // Bounding box, as columns so hit tests can filter in SQL.
  RealColumn get minX => real()();
  RealColumn get minY => real()();
  RealColumn get maxX => real()();
  RealColumn get maxY => real()();

  /// Also the draw order: undoing an erase must restore the original value.
  IntColumn get createdAt => integer().map(const MillisDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@TableIndex(name: 'tapes_page_id', columns: {#pageId})
class Tapes extends Table {
  TextColumn get id => text()();
  TextColumn get pageId =>
      text().references(Pages, #id, onDelete: KeyAction.cascade)();

  /// x, y, pressure repeated (centerline of the band).
  BlobColumn get points => blob().map(const Float32ListConverter())();
  RealColumn get width => real()();
  TextColumn get style => text().withDefault(const Constant('solid'))();
  BoolColumn get hidden => boolean().withDefault(const Constant(true))();

  RealColumn get minX => real()();
  RealColumn get minY => real()();
  RealColumn get maxX => real()();
  RealColumn get maxY => real()();

  // Study mode (after MVP).
  TextColumn get studyLastResult => textEnum<StudyResult>().nullable()();
  IntColumn get studyDueAt =>
      integer().map(const MillisDateTimeConverter()).nullable()();

  IntColumn get createdAt => integer().map(const MillisDateTimeConverter())();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
