# Margin — Study Notes & PDF App Plan

Oct 26, 2026 · @marc

## Key decisions

Build Margin (working name) as a native Android app in **Flutter**, tuned for the device you'll actually use: a **Huawei MediaPad T3 on Android 7**, written on with a **finger**. The 8- and 10-inch T3 have a Snapdragon 425, 2–3 GB of RAM and a 1280×800 screen, so every choice below favours doing less work per frame and using little memory.

Why Flutter:

- **Not a web app.** The last Chrome for Android 7 is Chrome 119 (2023), so a web app would be stuck on an old browser forever, and PDF rendering in JavaScript (pdf.js) is slow on this chip.
- **Not Kotlin.** Native Kotlin would be a little faster to start and use a little less memory, but drawing and PDF speed would be about the same (both use the GPU and PDFium). Flutter wins on what this project needs: Claude can run its tests and render screenshots inside a cloud session, and the same code can later be built for iPad on your MacBook.
- **Flutter on Android 7.** Flutter 3.47's default minimum is Android 7.0 (API 24), exactly the T3, so a Flutter upgrade must be checked before it's taken. On Android 7 it uses its OpenGL renderer (the Vulkan renderer is for Android 10 and up).

| Layer | Choice | Why |
| --- | --- | --- |
| Language + UI | Dart + Flutter (stable 3.47.x), Android only for now, minSdk 24 | Compiles to native ARM code and draws with its own engine; no browser in the way. |
| State | Built-in `ChangeNotifier` / `ValueNotifier` | No extra package. Canvas layers repaint through their own notifiers, so tool or menu changes never rebuild the page. |
| Ink | `CustomPainter` + `perfect_freehand` | Turns finger points into smooth, variable-width stroke outlines. Width comes from writing speed, since a finger has no pressure. |
| PDF viewing | `pdfrx` (bundles PDFium) | PDFium is the C++ engine inside Chrome's PDF viewer. Renders off the UI thread, can render just part of a page (for sharp zoom), and gives text positions for search and smart highlight later. |
| PDF export (later) | `pdf` package | Writes pages with your ink and tape baked in. Also generates the 200-page test PDF for benchmarks. |
| Storage | SQLite via `drift` | Typed tables, tested migrations, runs on a background isolate. Stroke points stored as compact binary; PDFs copied once into app storage as files. |
| File import | `file_picker` | Opens PDFs from Downloads, Drive, etc. |
| Spatial index | `rbush` | Fast eraser and lasso hit testing on pages with thousands of strokes. |
| Tests | `flutter_test`: unit, widget, golden (screenshot) and migration tests | All run inside a cloud session with no device, so Claude can check its own work and look at screens. |
| Diagnostics | Built-in overlay, benchmarks and a copyable bug report | Claude can't touch the T3, so the app measures itself and you paste the numbers into the next session. |
| Delivery | GitHub Actions → signed release APK on a GitHub Release | Every push to main builds a new APK; you download it on the tablet and install it over the old one. |
| Sync (later) | Supabase (`supabase_flutter`) | You already know it; added only after the local app is solid. |

If you later want an iPad version, Flutter builds for iOS on your MacBook with Xcode. Most code carries over; the input rules gain Apple Pencil support (pressure, pen-only mode), which the data model already has room for.

## Product goals

Margin does one job: reviewing lecture PDFs and notes on the T3. You highlight what matters, cover the answers with tape, and quiz yourself. Every feature and fix is checked against these goals, in this order; when two conflict, the higher one wins.

1. **Never lose notes.** Saved within a second of lifting your finger, safe when Android kills the app, and (from v1.1) backed up to a file.
2. **Ink feels instant.** The line appears under your finger on the next frame, on a Snapdragon 425.
3. **Reviewing is effortless.** Highlight, tape and quiz in as few taps as possible, without accidental marks.
4. **Light on 2 GB of RAM.** A 200-page PDF scrolls smoothly and the app survives in the background.
5. **Finger-first.** Every action works with fingers alone and nothing needs precision.

## Setup: GitHub + the $100 cloud credit

The credit is for Claude Code cloud sessions: Claude works on your GitHub repo inside an Anthropic-hosted VM, pushes a branch, and you merge it as a pull request. It applies automatically, and after it runs out or expires (Nov 5, 3:59 PM Manila time) your normal plan usage takes over. ([Claude Code on the web docs](https://code.claude.com/docs/en/web-quickstart))

1. **Create the repo.** (done) Private repo `margin` with a main branch.
2. **Connect GitHub.** (done) Claude GitHub App installed with access to `margin` at [claude.ai/code](https://claude.ai/code).
3. **Cloud environment.** (done) The current environment reaches the Flutter SDK download and pub.dev, so sessions can install Flutter and run tests. It blocks `dl.google.com` (Android build tools), which is fine: GitHub Actions builds the APK. Allow `dl.google.com` under the environment's Allowed domains only if you want APKs built inside sessions too. ([cloud environments](https://code.claude.com/docs/en/cloud-environments#network-access))
4. **Add the plan to the repo.** (done) This file, `docs/PLAN.md`. Every session reads the sections its prompt names, so you never re-explain the project.
5. **Session 0.** (done, PR 1) Scaffold, `CLAUDE.md`, a startup hook that installs Flutter in each session, and the APK build.
6. **Add the signing secrets.** Add `ANDROID_KEYSTORE_BASE64` and `ANDROID_KEYSTORE_PASSWORD` under Settings → Secrets and variables → Actions, from the file Session 0 gave you. Keep that file somewhere safe (a password manager). Every APK must be signed with this same key, or Android refuses to install updates.
7. **Merge PR 1, then prepare the tablet.** Turn on Settings → Security → Unknown sources (on Android 7 it's one switch). Sign in to GitHub in Chrome on the tablet, since the repo is private. Install the APK from the repo's Releases page.
8. **Loop per session.** Start a new session with the next prompt → Claude builds it and runs tests → read the PR's diff → merge → GitHub builds the APK → install over the old one → run the tablet checklist and use it for real study → paste findings (and the app's Copy bug report) into the next session's prompt.

**Credit rules**

- **Budget per session.** Check what Session 0 used, then divide what's left by the 8 sessions below. Check the balance after every session; if one overshoots, the next ships only its **Must** list.
- **One session per row of Build phases.** A session's cost grows with how much context it carries and how many turns it runs, so short, focused sessions stretch the credit furthest. Start each in a new session rather than continuing an old one.
- **Point, don't paste.** Prompts name sections of this file instead of pasting the plan.
- **Must before Stretch.** Each prompt lists Must and Stretch work. Claude finishes Must, then does Stretch only if the session is still short.
- **Batch your feedback.** Collect bugs and wishes from a day of use into one prompt, not a stream of small messages.
- **Parallel sessions only for separate features.** Two sessions at once burn the credit twice as fast and can conflict on the same files.
- **Heavier models for engines, lighter for polish.** If a model picker is offered, use the heavier model for the ink, PDF and tape sessions and a lighter one for UI polish.
- **Judge speed only on the release APK.** Debug builds are many times slower and say nothing about how the app really feels.

## UX and design

The look is inspired by Notability's calm, paper-first layout, with an original name, icon, colours and visuals.

### Design language

- **Paper first.** White pages with a hairline border sit on a warm-grey "desk". The chrome is light and quiet, with one ink-blue accent for the active tool and primary actions.
- **Flat.** No shadows, blur or elevation anywhere near pages: they cost GPU time on every frame and look busy. Separation comes from hairlines and spacing.
- **Little motion.** Short fades of 150 ms or less, only where they explain a change (panel opening, tape flipping).
- **Type.** Roboto, the Android system font: 22 dp titles, 16 dp body, 12 dp labels.
- **Touch.** Every target is at least 48 dp; tool icons are 24 dp inside 48 dp buttons.
- **Orientation.** Landscape and portrait both work; nothing is hidden in either.

### Screens

**Library**

```text
┌ Sidebar (260 dp) ─┬ All notebooks                  Sort ▾  Search  [+ New] ┐
│ Margin            │ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐                    │
│ ▣ All notebooks   │ │thumb │ │thumb │ │thumb │ │thumb │                    │
│ ◷ Recent          │ │      │ │ PDF  │ │      │ │      │                    │
│                   │ └──────┘ └──────┘ └──────┘ └──────┘                    │
│ SUBJECTS          │ Title    Title    Title    Title                       │
│ ● Biology    12   │ Oct 26   Oct 25   Oct 24   Oct 20                      │
│ ● History     4   │                                                         │
└───────────────────┴─────────────────────────────────────────────────────────┘
```

- The sidebar holds All notebooks, Recent, and subjects with colour dots and counts (later also "Due for review"). It hides below 720 dp of width.
- Notebook cards sit in a grid of 3–4 columns in landscape. Each shows a first-page thumbnail, title, last-edited date, subject colour and a PDF badge.
- **+ New** offers Notebook or Import PDF. Long-pressing a card opens Rename, Move to subject, Duplicate and Delete. Delete shows "Notebook deleted · Undo" for 5 seconds.
- Sort by Recent or Title, and search titles.
- On first launch, a short "Welcome to Margin" notebook teaches the gestures and has a tape to tap.

**Notebook**

```text
┌ Toolbar (56 dp) ───────────────────────────────────────────────────────────┐
│ ‹  Cell structure ▾ │ Pen  Highlighter  Eraser  Tape │ Undo Redo Review Pages ⋯ │
├ Tool options (44 dp) ───────────────────────────────────────────────────────┤
│ ● ● ● ● ● ●   ▪ ▪ ▪   (tool-specific: eraser mode · tape shape · Hide all · Reveal all) │
├─────────────────────────────────────────────────────────────────────────────┤
│                    ┌───────────────────────────┐                         ▐ │
│                    │           page            │                scrubber ▐ │
│                    └───────────────────────────┘                         ▐ │
│                               12 / 200                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

- **Toolbar.** Back and the title (tap to rename) on the left; tools in the middle (Lasso joins later); Undo, Redo, Review, Pages and More (⋯) on the right.
- **Tool options strip.** Sits under the toolbar for the active tool: 6 colours, 3 size presets, and tool-specific options. Tap the active tool again to collapse the strip and gain room.
- **Pages.** Scroll vertically, fit to width, with 24 dp side margins and 16 dp gaps between pages.
- **Page pill and scrubber.** A "12 / 200" pill shows while scrolling. A scrubber on the right edge jumps through long PDFs, with a page-number bubble while dragging.
- **Pages panel.** Slides in from the left with thumbnails (and later the PDF's own table of contents). Tap a thumbnail to jump; long-press it for Insert page before/after, Duplicate, Delete and Change paper.
- **Picks up where you left off.** A notebook reopens at the page and zoom you left it at.

**Review mode** (the Review button)

- Drawing turns off: one finger scrolls, taps flip tape, and a two-finger tap still undoes a flip.
- The toolbar turns pale blue and shows "Reviewing", Hide all, Reveal all and Exit, so you always know you're in it.
- Later, Study joins it: step through tapes one at a time and mark each Got it or Missed.

**Settings** (from More)

- Paper defaults: template, A4 or Letter.
- Gestures: two-finger tap to undo (on/off); palm guard (experimental).
- Diagnostics: performance overlay, benchmarks, Copy bug report.
- About: app build, device, screen size and pixel ratio.

### Gestures

| Gesture | Drawing tools | Review mode |
| --- | --- | --- |
| One-finger drag | Uses the active tool | Scrolls |
| One-finger tap on a tape | Flips the tape | Flips the tape |
| One-finger tap elsewhere | Pen: a dot. Other tools: nothing | Nothing |
| Second finger lands mid-stroke | Drops the stroke and starts scroll/zoom | — |
| Two-finger drag / pinch | Scroll / zoom (1×–4×) | Scroll / zoom |
| Two-finger tap | Undo | Undo |
| Three-finger tap | Redo | Redo |
| Two-finger double tap | Fit page width | Fit page width |
| Hold still at the end of a highlighter stroke | Straightens it | — |
| Long-press a card or thumbnail | Opens its menu | Opens its menu |

A tap of any number of fingers means every finger lands and lifts within about 250 ms and moves less than about 10 px.

### Tool defaults

| Tool | Colours | Sizes (page points) | Behaviour |
| --- | --- | --- | --- |
| Pen | ink black, blue, red, green, purple, orange | 1.5 · 2.5 · 4 | Width varies with speed |
| Highlighter | yellow, green, blue, pink, orange | 12 · 18 · 26 | Drawn under ink; the whole layer shows at 40% opacity, so overlaps never darken |
| Tape | masking beige, blue, pink, green, grey | 16 · 24 · 36 | **Strip:** a straight band from where the drag starts to where it ends. **Box:** drag a rectangle |
| Eraser | — | 12 · 24 · 40 | Partial (cuts strokes) or whole stroke; always removes a whole tape |

Each tool remembers its last colour and size. Long-press a size preset to change it. Tape defaults to Strip because fingers draw wobbly lines and most answers sit on one line; Box covers a diagram or paragraph.

### Feedback and safety

- Everything that changes notes is undoable: strokes, erasing, tape, Hide all, Reveal all, page and notebook deletes.
- Deletes show an Undo snackbar for 5 seconds.
- Saving is silent and fast. Only a failure is ever shown, and it says what to do.
- Empty states always offer the next step (e.g. "Import a PDF").

### Finger-first rules

1. Every action works with one, two or three fingers. Nothing needs a stylus.
2. Nothing smaller than 48 dp to tap.
3. Undo is always one gesture away (two-finger tap) and visible in the toolbar.
4. Reading never marks the page: Review mode exists for that.
5. **Palm guard (experimental).** Android reports a contact size for each touch, and Flutter passes it on (`PointerEvent.size`). A resting palm is much bigger than a fingertip, so touches above a threshold can be ignored. The diagnostics overlay shows live contact sizes so the threshold can be tuned on the T3. It ships off and is turned on only if the T3 reports useful sizes.

## Feature scope and releases

Each session ships a release (R1–R8) you can use that day; "v1.1" and later come after Nov 5 on your regular plan. Everything marked R ships by Nov 5 unless the credit runs short (see Build phases).

| Area | Feature | What it does | When |
| --- | --- | --- | --- |
| Ink | Pen | Width follows writing speed (colour and size choices arrive in R4) | R1 |
| Ink | Undo / redo | Toolbar buttons, two-finger tap undo, three-finger tap redo | R1 |
| Ink | Finger gestures | One finger uses the tool; a second finger drops the stroke and scrolls or zooms | R1 |
| Ink | Highlighter | Under the ink, 40% layer opacity, hold to straighten | R4 |
| Ink | Eraser | Partial and whole-stroke | R4 |
| Ink | Colours and presets | Per-tool colours and 3 editable size presets, remembered | R4 |
| Ink | Palm guard | Ignores touches with a palm-sized contact area (experimental) | R6 |
| Ink | Lasso | Select strokes to move, resize, recolor, copy, paste or delete | R8 stretch, else v1.3 |
| Ink | Zoom box | Write large in a magnified strip at the bottom; the ink lands small on the page, which makes small handwriting possible with a finger | R8 stretch, else v1.3 |
| Ink | Shape snap | Hold at the end of a stroke to turn it into a line, arrow, rectangle or ellipse | v1.3 |
| Ink | Stylus support | Pressure-based width and pen-only mode, for an active stylus or iPad | v2 |
| Page | Paper templates | Blank, lined, grid, dotted | R2 |
| Page | Pages | Add, delete, reorder | R2 |
| Page | Picks up where you left off | Reopens at the last page and zoom | R2 |
| Page | Zoom and pan | 1×–4×, sharp re-render after the pinch | R3 |
| Page | Page pill + scrubber | Where you are, and fast jumps through long notebooks | R6 |
| Page | Pages panel | Thumbnails, page menu, duplicate page | R6 |
| Page | Study templates | Cornell notes; Q&A (an answer column made for taping) | v1.3 |
| Page | Text boxes, images | Typed text and photos you can move and resize | v1.3 |
| PDF | Import | Open a PDF into a new notebook; every tool works on its pages | R3 |
| PDF | Insert blank page | Add a writing page between PDF pages | R3 |
| PDF | Thumbnails | In the pages panel | R6 |
| PDF | Contents | The PDF's own table of contents in the pages panel | v1.2 |
| PDF | Smart highlight | On PDF text, a highlighter stroke snaps to the text lines it crosses, so finger highlights look neat | v1.2 |
| PDF | Search | Find typed text inside the PDF | v1.2 |
| PDF | Export | Save a new PDF with ink and tape baked in | v1.2 |
| Tape | Tape tool | Strip or box, 5 colours, 3 widths | R5 |
| Tape | Tap to reveal | Finger tap toggles one tape between hidden and peeked | R5 |
| Tape | Review mode | Drawing off; scroll and flip tapes without leaving marks | R5 |
| Tape | Hide all / reveal all | Per page or whole notebook, undoable | R5 |
| Tape | Highlight → tape | Turn every highlight of one colour on a page or notebook into tape in one step | v1.1 |
| Tape | Study mode | Steps through tapes in reading order; you mark each "got it" or "missed" | v1.1 |
| Tape | Spaced repetition | Missed tapes come back on a schedule (COGNIT logic); "Due for review" in the library | v1.1 |
| Tape | Tape styles | Patterns | v1.3 |
| Library | Subjects + notebooks | Subjects with colours, notebook grid, sort, rename, move, duplicate, delete | R2 |
| Library | Search titles | Filter notebooks by title | R2 stretch, else R6 |
| Library | Card thumbnails | First-page previews on notebook cards | R6 |
| Library | Welcome notebook | Teaches the gestures on first launch | R6 |
| Library | Backup and restore | The whole library as one file, saved anywhere; restore from it | R6 stretch, else first thing in v1.1 |
| Library | Recently deleted | Deleted notebooks kept for 30 days | v1.1 |
| App | Diagnostics overlay | Frame times, memory, touch rate, contact size, screen size and pixel ratio | R1 |
| App | Copy bug report | Device, build, recent errors and measurements, ready to paste into a session | R1 |
| App | Settings screen | Paper defaults, gestures, palm guard, diagnostics | R6 |
| App | Benchmarks | Replays writing and scrolls a 200-page PDF, reports frame times and memory | R7 |
| Sync | Cloud sync | Same notebooks on several devices through Supabase | v2 |
| Search | Handwriting search | On-device handwriting recognition so notes can be searched (check it works on the T3) | v2 |

Not planned: audio recording. It adds a large feature for little reviewer value.

## Architecture and data model

Each page is a stack of layers, and only the top one repaints while you write. Strokes are saved as small arrays of numbers, not images, so notebooks stay light and every stroke can still be erased, moved or recolored.

**Terms used here**

- **Stroke:** one finger-down to finger-up line, stored as a list of points. Each point is x, y and pressure (0 to 1). With a finger, "pressure" is computed from writing speed while you write.
- **Page coordinates:** positions measured in PDF points (1/72 inch) on the page itself, so zooming changes how strokes are drawn but never the stored numbers.
- **Bounding box (bbox):** the smallest rectangle around a stroke. Checking boxes first makes erasing, lasso and tape taps fast, because most strokes are ruled out without testing every point.
- **RepaintBoundary:** a Flutter widget that gives its child its own GPU layer, so repainting one layer never repaints the others.
- **Background isolate:** a separate Dart thread. The database and PDF rendering run off the UI thread, so neither ever freezes your finger's line.

**Layer stack per page** (bottom to top): background (paper template or PDF page image, plus a sharp tile when zoomed) → highlighter → ink → tape → live stroke. Each is its own `RepaintBoundary` + `CustomPainter`.

**Input pipeline**

```text
Listener (raw pointers) → InputRouter → active Tool → Command → History (undo/redo) → Repository (batched DB writes)
                              │
                              └→ scroll / zoom controller (two or more fingers)
```

The InputRouter is plain Dart. It classifies every touch sequence as a draw, a tap, a multi-finger tap (undo/redo), a scroll or zoom, or a palm (when palm guard is on), and hands it to exactly one consumer.

**Page renderer and memory manager.** Each visible page owns its layers and caches. One `MemoryBudget` object tracks every decoded image (PDF pages, tiles, flattened ink, thumbnails), evicts the least recently used past the budget, and drops everything off-screen when Android signals memory pressure (`didHaveMemoryPressure`).

**Data model** (SQLite tables through drift, one row per object; schema v1 is in the repo)

```dart
Subject  { id, name, color, sortOrder }
Notebook { id, subjectId?, title, kind: notes | pdf, pdfFileId?, pageIds: List<String>, createdAt, updatedAt }
PdfFile  { id, path, pageCount, sha256 }            // file copied once into app storage; pages point to it
Page     { id, notebookId, width, height,
           background: template(blank | lined | grid | dotted)
                     | pdf(pageIndex) }
Stroke   { id, pageId, tool: pen | highlighter, color, size,
           points: Float32List,                     // x, y, pressure repeated; stored as a BLOB
           minX, minY, maxX, maxY, createdAt }      // createdAt (ms) is also the draw order
Tape     { id, pageId, points: Float32List, width, style, hidden: bool,
           minX, minY, maxX, maxY, studyLastResult?, studyDueAt?, createdAt }
```

Strokes and tapes are indexed by `pageId`, so opening a page is one query. Pages are ordered by the `pageIds` list, so reordering pages rewrites one row instead of every page. Deleting a notebook cascades to its pages, strokes and tapes. Storing pressure per point keeps the format ready for a real stylus later.

**Planned schema changes** (each is a drift migration with a migration test; never edit an old version)

| Version | Release | Change |
| --- | --- | --- |
| v2 | R2 | `notebooks.lastPageId`, `notebooks.lastZoom`; `settings` key-value table (tool presets, paper defaults, gesture toggles) |
| v3 | R5 | `tapes.shape`: strip, box or free (default strip) |
| v4 | v1.1 | Spaced-repetition fields on tapes (interval, ease, reps); `notebooks.deletedAt` for Recently deleted |

**How finger input works**

1. Drawing uses a raw `Listener`, not `GestureDetector`. A gesture detector waits until the finger has moved about 18 px before it reports a drag, which would make every stroke start late.
2. One finger down: the active tool starts at once.
3. A second finger lands while drawing: the in-progress stroke is dropped (it never reaches undo history or the database) and the touch becomes scroll and pinch zoom.
4. A touch sequence where every finger lifts within about 250 ms and moves less than about 10 px is a **tap**: one finger flips tape, two fingers undo, three fingers redo.
5. Width from speed is computed while writing and stored as each point's pressure. Rendering then uses the stored values, so simplifying points after the stroke ends never changes how it looks.
6. **Touch samples are sparse.** Flutter on Android passes on only the newest touch position of each Android event; it doesn't read the samples Android batches in between (checked in the Flutter 3.47 engine). So the pen smooths with perfect_freehand's streamline option and draws curves between samples, not straight segments. The diagnostics overlay shows the T3's real touch rate.
7. There is no hardware palm rejection with a finger. Palm guard (experimental), Review mode and two-finger undo cover the gap.

**How tape works**

1. With the Tape tool, a finger drag shows a live preview and saves a `Tape` with `hidden: true`. **Strip** makes a straight band of the chosen width from the drag's start to its end. **Box** makes a rectangle from the drag's corners.
2. A tap is tested against each tape's bounding box, then its exact outline. A hit flips `hidden`. In the pen and highlighter tools and in Review mode, a tap on a tape flips it instead of drawing a dot.
3. Hidden tape draws fully opaque, with zigzag torn ends drawn as a plain path (no image or shadow). Peeked tape draws as a faint dashed outline, so you still see where the answer was.
4. **Review mode** turns drawing off: one finger scrolls, taps flip tapes, and the toolbar shrinks to Hide all, Reveal all and Exit.
5. Hide all / reveal all sets `hidden` on every tape of the page or notebook in one database write, as one undoable command.

**Code layout**

```text
lib/
  main.dart
  app/        library, notebook, settings and diagnostics screens
  input/      InputRouter: draw vs. tap vs. multi-finger tap vs. scroll/zoom vs. palm
  tools/      pen, highlighter, eraser, lasso, tape
  canvas/     layer painters, stroke picture cache, hit testing, MemoryBudget
  pdf/        pdfrx wrapper, page image cache, zoom tiles
  state/      ChangeNotifiers: tool settings, open notebook, selection, review mode
  db/         drift tables, migrations, repositories
  history/    undo/redo as reversible commands
  diagnostics/ frame timing, memory, touch stats, benchmarks, bug report
  ui/         toolbar, options strip, colour palette, thumbnails, theme
test/         unit, widget, golden and migration tests
.github/workflows/  analyze + test; signed release APK on main
```

## Performance plan

The app feels fast if the line appears under your finger with no lag and big PDFs scroll smoothly. Both come from doing as little work as possible per frame, which is one screen refresh: about 16 ms at 60 Hz. On a Snapdragon 425 there is little headroom, so these rules are not optional.

**Targets** (checked on the T3 with the release APK, using the diagnostics overlay and benchmarks)

| Measure | Target |
| --- | --- |
| Frame time while writing | 90% of frames under 16 ms; none over 33 ms |
| Ink start | Visible on the first frame after touch-down |
| Cold start to library | Under 2 seconds |
| Open a 200-page PDF to first visible page | Under 1 second |
| Scroll a 200-page PDF | 90% of frames under 16 ms; a page is never blank for more than 300 ms |
| Open a 50-page handwritten notebook | Under 1 second |
| Tap on tape to reveal | Visible on the next frame |
| Memory while reviewing a 200-page PDF | Under 300 MB (resident set size) |
| Save after finger-up | In the database within 1 second |

**Memory budget** (decoded images held at once; enforced by `MemoryBudget`)

| Item | Budget | Notes |
| --- | --- | --- |
| PDF page images | 40 MB | About 4–5 pages at screen resolution: visible pages plus one ahead and one behind |
| Zoom tile | 8 MB | Only the visible area, only while zoomed in |
| Flattened ink and highlighter | 24 MB | Visible pages only |
| Thumbnails | 16 MB | Small, on-disk cache, loaded on demand |
| **Total** | **about 90 MB** | Everything else is vector data and code |

Keep any single image under 4096 px on a side, which is safe on older Adreno GPUs.

**Writing**

- **Repaint only the live stroke each frame.** The stroke being written sits on its own top layer. On finger-up it is added to the ink layer once and the live layer is cleared, so old strokes are never redrawn while writing.
- **Cache finished strokes.** Each page's ink is recorded into one `ui.Picture` and marked `isComplex` so the engine caches it as an image. When a page passes a few hundred strokes it is flattened to an image outright, so the GPU draws one picture instead of every path.
- **Highlighter without darkening.** Highlighter strokes are drawn opaque and flattened to an image, which is drawn at 40% opacity. Overlapping highlights stay even, and there's no per-frame layer blending.
- **No allocations per touch event.** Incoming points go into a preallocated, growable `Float32List`; nothing is created per event in the hot path, so the garbage collector never pauses a stroke.
- **Long strokes stay cheap.** perfect_freehand recomputes the whole outline every frame. If the overlay shows the live stroke costing more than about 4 ms, the settled part of the stroke is frozen into a picture and only the tail is recomputed.
- **Keep widget rebuilds out of the drawing path.** Pointer handling, tools and painters are plain Dart objects. Painters repaint through a `Listenable`; widgets only draw the toolbar, menus and library, so a state change never rebuilds the page.
- **Shrink strokes after finger-up.** Remove points that add nothing to the shape (Ramer–Douglas–Peucker simplification with a tiny tolerance), then save as a `Float32List`.
- **Save after, not during.** Database writes are batched a moment after finger-up in one transaction on the background isolate, never mid-stroke.
- **Keep effects simple.** No blur, shadows or saveLayer-heavy effects on the canvas. On Android 7, Flutter's OpenGL renderer can stutter the first time a new effect is drawn; compiled shaders are cached on disk, so it happens once per install.

**Pages and PDFs**

- **Only build what's on screen.** Pages are built lazily. Pages more than one screen away hold no images, and their cached pictures are disposed.
- **Fixed page sizes.** Every page's size is known before it renders, so the list uses fixed extents (`itemExtentBuilder`). Jumping to page 150 is instant and the scrubber is exact.
- **Render in priority order.** Visible pages render first, then one ahead and one behind. Renders for pages that scrolled away are cancelled (pdfrx cancellation tokens).
- **Never blank.** While a page renders, its low-resolution thumbnail is shown stretched in its place.
- **Render off the UI thread.** pdfrx renders each page once at fit-width × pixel ratio and keeps it in the LRU cache, so scrolling back costs nothing.
- **Cheap zoom, sharp finish.** During a pinch, a snapshot of the page is scaled with a transform (instant but blurry); nothing is re-rendered mid-gesture. When the fingers lift, ink redraws sharp from its vector picture. Above about 1.5×, pdfrx renders a sharp tile of just the visible area on top of the base image, because a full page at 4× would be over 100 MB.
- **Fast eraser and lasso.** Each stroke's bounding box is checked first, so only strokes near the finger are tested point by point. A spatial index (`rbush`) handles pages with thousands of strokes.
- **Thumbnails in idle time.** Generated at low resolution when nothing else is happening, saved to disk and reused until the page changes.
- **Hairline borders, not shadows,** around pages.

**Start-up**

- Nothing heavy runs before the first frame. The database opens on its background isolate while the first frame draws.
- The Android launch screen uses the same desk colour as the app, so there's no white flash.
- The library shows cached thumbnails from disk; no notebook or PDF loads until you open one.

**Measuring** (the T3 is the only place speed can be judged)

- **Diagnostics overlay (R1).** Build and raster time per frame (from Flutter's `FrameTiming`), memory (`ProcessInfo.currentRss`), image memory used, touch events per second, live contact size, screen size and pixel ratio.
- **Copy bug report (R1).** Puts the app build, device, Android version, screen info, last 100 log lines and the latest measurements on the clipboard, ready to paste into a session prompt.
- **Benchmarks (R7).** "Ink" replays a built-in writing script through the real input pipeline for 20 seconds. "PDF" scrolls a generated 200-page PDF top to bottom. Each reports frame times (50th, 90th and 99th percentile, worst frame, dropped frames) and peak memory, and adds them to the bug report.

## Quality and feedback loop

- **Unit tests** cover geometry, simplification, hit testing, gesture classification, commands, the memory budget and zoom-tile maths.
- **Widget tests** drive real pointer sequences: one-finger drawing, a second finger landing mid-stroke, two- and three-finger taps, a tap on a tape.
- **Golden tests** screenshot every screen at the T3's real logical size, in landscape and portrait. If R1's diagnostics show a pixel ratio other than 1.0, the goldens are re-baselined to match.
- **Migration tests** check every schema version upgrades without losing data.
- **CI** runs format, analyzer, generated-code check and all tests on every PR. Release notes list the PRs merged since the last build.
- **On-device loop.** After each merge, install the APK, run the tablet checklist, then use the app for real study. From R3 on, review one real lecture PDF with it each day. Paste the bug report and your notes into the next session.

## Build phases

Every session ships an APK you can use for real study that day. Each one adds a thin slice through every layer (input, drawing, storage, UI), not one layer at a time. The order puts what you care about most (PDF, highlighter, tape) as early as the foundations allow.

| Session | Target date | Release | Must | Stretch | Done when |
| --- | --- | --- | --- | --- | --- |
| 0. Scaffold | Oct 26 | R0 | Done (PR 1) | — | The APK installs and opens an empty library |
| 1. Ink engine | Oct 27 | R1 | Notebook screen shell, InputRouter, pen, undo/redo with gestures, save/load, diagnostics overlay, bug report | Release notes from merged PRs | Writing with a finger on a scratch page feels instant; overlay shows real numbers |
| 2. Notebooks | Oct 28 | R2 | Subjects, notebooks, library grid, pages and templates, scroll, autosave, reopen where you left off, schema v2 | Title search | Notes survive closing and reopening the app |
| 3. PDF | Oct 29–30 | R3 | PDF import, prioritized rendering, LRU cache, placeholders, pinch zoom with sharp tiles, insert blank page | Import progress for large files | A 200-page lecture PDF scrolls smoothly, zooms sharp, and takes ink |
| 4. Mark-up | Oct 31 | R4 | Highlighter, eraser (partial + whole), options strip with colours and editable presets | — | You can highlight and correct a full PDF page |
| 5. Tape | Nov 1 | R5 | Tape strip and box, tap to flip, Review mode, Hide all / Reveal all, schema v3 | — | You can cover answers on a reviewer and quiz yourself |
| 6. Navigation + polish | Nov 2 | R6 | Pages panel with thumbnails, page pill and scrubber, card thumbnails, welcome notebook, settings, palm guard | Backup and restore | Moving around a 200-page PDF is quick, and a first-time user knows the gestures |
| 7. Speed | Nov 3 | R7 | Benchmarks; measure every target; fix the slowest paths using your overlay reports | — | Benchmark report shows where each target stands |
| 8. Fixes | Nov 4 | R8 | Fix what the benchmarks and your tablet testing found | Lasso or zoom box | All targets pass, or the gaps are written down with a plan |
| Buffer | Nov 5 AM | — | Leftover fixes | — | Credit expires 3:59 PM |

**If the credit runs short, cut in this order:** Stretch items → lasso and zoom box → welcome notebook → benchmarks (keep the overlay). Never cut PDF, highlighter, tape or Review mode: those are the reason you're building this.

## After Nov 5

On your regular plan, in this order:

1. **v1.1 Safety and study.** Backup and restore first (if R6 didn't reach it), Recently deleted, Study mode, spaced repetition with "Due for review", Highlight → tape.
2. **v1.2 PDF power.** Smart highlight, Contents, Search, Export.
3. **v1.3 Writing tools.** Zoom box, lasso (if not done), shape snap, text boxes, images, Cornell and Q&A templates, tape styles.
4. **v2 More devices.** Supabase sync, iPad build, stylus support, handwriting search.

## Session prompts

Start each one as a **new** cloud session on the `margin` repo, after the previous PR is merged. Each prompt names the sections to read instead of repeating them. Replace `<…>` with your notes and the app's Copy bug report output.

**Session 1: Ink engine**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Screens" (Notebook), "Gestures", "Finger-first rules", "How finger input works", "Writing" and "Measuring".
Must:
- Notebook screen shell: toolbar layout from "Screens" with Pen active (other tools shown disabled), one lined scratch page. The library gets a temporary "Scratch page" card that opens it.
- InputRouter on Listener: one finger draws; a second finger drops the live stroke; two-finger tap undoes, three-finger tap redoes.
- Pen with perfect_freehand: width from speed computed while writing and stored as pressure; streamline smoothing; points in a preallocated buffer.
- Live layer and cached ink layer (RepaintBoundary, isComplex).
- Undo/redo commands in lib/history with toolbar buttons.
- Simplify on finger-up; batched save with drift; strokes reload after restart.
- Diagnostics overlay (More → Diagnostics) and Copy bug report, as in "Measuring".
Stretch: CI release notes list merged PRs (gh release create --generate-notes).
Tests: simplification, speed-to-width, gesture classification with simulated pointers, undo/redo, save/load; golden of the notebook screen with sample strokes.
Open a PR with a short list of what I should test on the tablet.
```

**Session 2: Notebooks**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Screens" (Library, Notebook), R2 rows of "Feature scope and releases", "Planned schema changes" (v2), "Pages and PDFs".
Tablet feedback from R1: <paste notes and bug report>.
Must:
- Schema v2 with migration test.
- Subjects: create, rename, colour, delete. Notebooks: create, rename, move, duplicate, delete with Undo snackbar.
- Library grid of notebook cards with sort; sidebar with subjects and counts.
- Notebook pages: vertical list with fixed extents, two-finger scroll, add page at the end, delete and reorder from the More menu, paper templates drawn as vectors.
- Only pages near the screen hold pictures; autosave; reopen at the last page.
- Fix R1 bugs from the feedback above.
Stretch: title search.
Tests: notebook and subject CRUD, page ordering, migration v1→v2; goldens of the library with notebooks (landscape, portrait) and each template.
Open a PR.
```

**Session 3: PDF**

```text
Read CLAUDE.md, then in docs/PLAN.md: PDF rows of "Feature scope and releases", "Pages and PDFs", "Memory budget".
Tablet feedback from R2: <paste>.
Must:
- Import a PDF: file_picker, copy into app storage once (sha256 dedupe), one page row per PDF page with its real size.
- Render visible pages with pdfrx off the UI thread at fit-width × pixel ratio, in priority order, cancelling pages that scroll away; LRU cache inside the memory budget; thumbnail-quality placeholder until sharp.
- MemoryBudget object; drop off-screen images on memory pressure.
- Pinch zoom 1×–4× (snapshot during the gesture, re-render after), two-finger double tap to fit width, sharp tile of the visible area above about 1.5×.
- Insert a blank page between PDF pages. Pen and undo work on PDF pages.
Stretch: progress indicator for large imports.
Tests: a small generated PDF fixture; cache eviction, render priority and tile maths as unit tests (use a fake renderer if PDFium can't load in tests here).
Open a PR.
```

**Session 4: Mark-up**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Tool defaults", Ink rows of "Feature scope and releases", "Writing".
Tablet feedback from R3: <paste>.
Must:
- Highlighter layer under ink: opaque strokes flattened to an image drawn at 40%; hold still at the end to straighten.
- Eraser: partial (splits strokes) and whole stroke; bounding boxes before point tests; rbush index on pages with many strokes.
- Tool options strip: 6 colours, 3 size presets per tool, long-press a preset to edit it, all remembered in the settings table.
Tests: stroke splitting, hit testing, preset persistence; golden of a PDF page with highlights under ink.
Open a PR.
```

**Session 5: Tape**

```text
Read CLAUDE.md, then in docs/PLAN.md: Tape rows of "Feature scope and releases", "How tape works", "Gestures", "Screens" (Review mode), "Planned schema changes" (v3).
Tablet feedback from R4: <paste>.
Must:
- Schema v3 (tapes.shape) with migration test.
- Tape tool: strip and box with live preview, 5 colours, 3 widths; eraser removes whole tapes.
- Tap to flip from pen, highlighter and Review mode; hidden = opaque with torn ends, peeked = faint dashed outline.
- Review mode: one finger scrolls, taps flip, pale-blue toolbar with Hide all, Reveal all, Exit.
- Hide all / Reveal all per page and per notebook, each one undoable command.
Tests: tap classification, strip and box hit testing, Review mode input routing, undo of Hide all; goldens of hidden and peeked tape and the Review toolbar.
Open a PR.
```

**Session 6: Navigation and polish**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Screens", "Finger-first rules" (palm guard), R6 rows of "Feature scope and releases".
Tablet feedback from R5 and the contact sizes the overlay showed for a fingertip vs. a resting palm: <paste>.
Must:
- Pages panel: thumbnails made in idle time and cached on disk; tap to jump; long-press menu (insert before/after, duplicate, delete, change paper).
- Page pill and right-edge scrubber with a page bubble.
- First-page thumbnails on library cards.
- Welcome notebook on first launch that teaches the gestures, with a tape to tap.
- Settings screen as in "Screens"; palm guard using the measured threshold (off by default if the sizes weren't useful).
Stretch: backup and restore of the whole library as one file; title search if R2 didn't ship it.
Tests: thumbnail cache invalidation, scrubber page maths, palm classification; goldens of the pages panel, settings and welcome notebook.
Open a PR.
```

**Session 7: Speed**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Performance plan".
Overlay reports from the tablet: <paste bug reports taken while writing and while scrolling a big PDF>.
Must:
- Benchmarks as in "Measuring" (ink replay, generated 200-page PDF scroll), results added to the bug report.
- Find and fix the slowest paths behind every target that the reports show missing.
- Report which targets you could and couldn't verify here.
Open a PR with exactly what I should run on the tablet and paste back.
```

**Session 8: Fixes**

```text
Read CLAUDE.md, then in docs/PLAN.md: "Performance plan" targets and "Feature scope and releases".
Benchmark results and tablet bugs from R7: <paste>.
Must: fix them, in order of the Product goals.
Stretch: lasso (Ink rows of Feature scope), or the zoom box if writing small with a finger is still hard.
Open a PR.
```

**Bug report template** (for any session)

```text
Device: MediaPad T3 <8 or 10>, Android 7
App build: <release name from GitHub>
What I did: <steps>
What happened: <result>
What I expected: <result>
Bug report from the app: <paste More → Diagnostics → Copy bug report>
```

## Risks and testing

The biggest risk is losing notes, not lag. On Android, uninstalling the app deletes its data, and an APK signed with a different key can only be installed by uninstalling first. One fixed signing key from Session 0 prevents that; backup and restore (R6 stretch or first in v1.1) covers the rest.

| Risk | What happens | Fix |
| --- | --- | --- |
| Signing key lost or changed | Android refuses the update; uninstalling wipes all notes | One key from Session 0, stored as GitHub secrets plus your own copy; never uninstall to "fix" an install error |
| Android kills the app in the background (2–3 GB RAM, EMUI) | Last strokes lost; app restarts on the library | Save within a second of finger-up; reopen at the last page |
| Memory on big PDFs | App crashes or gets killed on a 200-page PDF | MemoryBudget, visible-only images, zoom tiles instead of huge renders |
| Sparse touch samples | Curves look jagged | perfect_freehand streamline, curves between samples; touch rate measured in R1 |
| Palm and stray touches | Marks where your hand rests | Review mode, two-finger undo, palm guard if the T3 reports contact sizes |
| Fingers are blunt | Small handwriting is hard | Zoom in to write; zoom box in R8 stretch or v1.3 |
| No Android device in the cloud | Feel and speed can't be judged by Claude | Unit, widget and golden tests in every session; diagnostics and benchmarks on the tablet; checklist after every merge |
| T3 pixel ratio differs from the goldens | Layouts tested at the wrong size | R1 diagnostics show the real size; goldens re-baselined to it |
| Old OpenGL renderer on Android 7 | Occasional first-time stutter | Simple canvas effects; measured in R7 |
| Scope too big for the credit | Tape or PDF unfinished | Must/Stretch per session, cut order in Build phases, balance checked after every session |
| Merging without reading | Bugs pile up across sessions | Read each diff and run the checklist before the next session |
| Copying the original app | Trouble if you ever publish it | Original name, icon and visuals; build the features, not their look |

**Tablet checklist** (on the release APK after every merge; items apply from the release shown)

- [ ] R1: Write a full page fast with your finger: no lag, no gaps, curves look smooth
- [ ] R1: Start scrolling with two fingers mid-stroke: no stray line is left behind
- [ ] R1: Two-finger tap 20 times (undo), three-finger tap 20 times (redo)
- [ ] R1: Copy bug report works and shows frame times, memory and screen info
- [ ] R2: Swipe the app away from Recent apps mid-writing, reopen: last strokes are there, same page
- [ ] R3: Import a 200-page PDF; scroll top to bottom; pages are never blank for long
- [ ] R3: Pinch to 3× on a PDF page: text turns sharp after you lift your fingers
- [ ] R4: Highlight a paragraph, write over it, erase part of a stroke, undo it
- [ ] R5: Cover 20 answers with tape, swipe the app away, reopen: tapes are still hidden
- [ ] R5: In Review mode, scroll and tap 20 tapes: no marks appear
- [ ] R6: Jump to page 150 with the scrubber, then back with the pages panel
- [ ] Every release: install the new APK over the old one; all notebooks are still there
