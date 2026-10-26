import 'dart:typed_data';
import 'dart:ui';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:margin/canvas/ink_stroke.dart';
import 'package:margin/db/database.dart';
import 'package:margin/db/ink_repository.dart';

InkStroke stroke(String id, int millis, {double x = 10}) => InkStroke(
  id: id,
  tool: StrokeTool.pen,
  color: 0xFF1F2328,
  size: 2.5,
  points: Float32List.fromList([x, 20, 0.6, x + 30, 25, 0.4]),
  bounds: Rect.fromLTRB(x - 2.5, 17.5, x + 32.5, 27.5),
  createdAt: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
);

void main() {
  late MarginDatabase db;
  late InkRepository repo;

  setUp(() {
    db = MarginDatabase(NativeDatabase.memory());
    repo = InkRepository(db);
  });

  tearDown(() async {
    repo.dispose();
    await db.close();
  });

  test('the scratch page is created once and reused', () async {
    final first = await repo.ensureScratchPage();
    final second = await repo.ensureScratchPage();
    expect(first.id, InkRepository.scratchPageId);
    expect(second.id, first.id);
    expect(first.background, const TemplateBackground(PaperTemplate.lined));
    expect(await db.select(db.notebooks).get(), hasLength(1));
  });

  test('strokes save in one flush and load back in draw order', () async {
    final page = await repo.ensureScratchPage();
    repo
      ..saveStroke(page.id, stroke('b', 2000, x: 50))
      ..saveStroke(page.id, stroke('a', 1000));
    expect(await db.select(db.strokes).get(), isEmpty, reason: 'batched');

    await repo.flush();
    final loaded = await repo.loadStrokes(page.id);
    expect(loaded.map((s) => s.id), ['a', 'b']);
    expect(loaded.first.points, stroke('a', 1000).points);
    expect(loaded.first.bounds, stroke('a', 1000).bounds);
    expect(loaded.first.createdAt.millisecondsSinceEpoch, 1000);
  });

  test('deletes are written too', () async {
    final page = await repo.ensureScratchPage();
    repo.saveStroke(page.id, stroke('a', 1000));
    await repo.flush();
    repo.deleteStroke('a');
    await repo.flush();
    expect(await repo.loadStrokes(page.id), isEmpty);
  });

  test('a stroke added and undone before a flush is never written', () async {
    final page = await repo.ensureScratchPage();
    repo
      ..saveStroke(page.id, stroke('a', 1000))
      ..deleteStroke('a');
    await repo.flush();
    expect(await db.select(db.strokes).get(), isEmpty);
  });

  test('a failed flush keeps the changes for the next one', () async {
    final otherDb = MarginDatabase(NativeDatabase.memory());
    final other = InkRepository(otherDb);
    final page = await other.ensureScratchPage();
    other.saveStroke(page.id, stroke('a', 1000));
    await otherDb.close();

    await expectLater(other.flush(), throwsA(anything));
    expect(other.hasPendingWrites, isTrue);
    other.dispose();
  });

  test('pending writes flush by themselves after the delay', () async {
    repo = InkRepository(db, flushDelay: const Duration(milliseconds: 10));
    final page = await repo.ensureScratchPage();
    repo.saveStroke(page.id, stroke('a', 1000));
    expect(repo.hasPendingWrites, isTrue);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(repo.hasPendingWrites, isFalse);
    expect(await repo.loadStrokes(page.id), hasLength(1));
  });
}
