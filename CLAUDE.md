# Margin

Study notes + PDF markup app with tape (hide/reveal answers). Flutter, Android only for now.
Target device: Huawei MediaPad T3, Android 7 (API 24), 2–3 GB RAM, written on with a finger.
Full plan: `docs/PLAN.md`. Read only the sections a task names.

## Stack
Flutter 3.47.8 (pinned in `pubspec.yaml`; CI and the SessionStart hook install exactly this).
drift (SQLite), pdfrx (PDFium), perfect_freehand, file_picker, rbush. State: built-in ChangeNotifier.

## Folders
`lib/app` screens · `lib/input` pointer handling · `lib/tools` pen/highlighter/eraser/lasso/tape ·
`lib/canvas` layer painters, picture cache, hit testing · `lib/pdf` pdfrx + page image cache ·
`lib/state` ChangeNotifiers · `lib/db` drift schema · `lib/history` undo/redo commands ·
`lib/diagnostics` overlay, benchmarks, bug report · `lib/ui` theme, toolbar.
Tests mirror `lib/` under `test/`; goldens live in `test/**/goldens/`.

## Commands
- `dart format lib test`, `flutter analyze`, `flutter test` (run all three before finishing any task)
- `flutter test --update-goldens` after an intended UI change; look at the PNGs before committing
- `dart run build_runner build` after editing `lib/db/`; commit the generated `*.g.dart`
- Schema change: bump `schemaVersion`, then `dart run drift_dev make-migrations`
- APKs are built by GitHub Actions only (this container can't reach dl.google.com)

## Rules
- Keep widget rebuilds out of the drawing path: input, tools and painters are plain Dart; painters repaint via a Listenable.
- Use `Listener` for drawing input, never `GestureDetector` (its slop delays stroke start).
- Store positions in page coordinates (PDF points), never screen pixels.
- Finger input: one finger = current tool, a second finger drops the live stroke and pans/zooms;
  taps: one finger flips tape, two fingers undo, three redo. Screens, gestures, tool defaults: PLAN "UX and design".
- No allocations per pointer event in the input/drawing hot path (preallocated buffers).
- Touch targets at least 48 dp.
- Every change to notes is an undoable command; DB writes are batched after finger-up, never mid-stroke.
- Only pages near the screen hold pictures or images; release the rest (2 GB RAM).
- No blur, shadows or saveLayer-heavy effects on or around pages; hairline borders instead.
- Every feature gets tests (unit for logic, golden for new screens).
- Don't raise minSdk above 24 or upgrade Flutter past a release that drops API 24.
- Never commit signing keys or `key.properties`.
