# Margin — Study Notes & PDF App Plan

Oct 26, 2026 · @marc

## Key decisions

Build Margin (working name) as a native Android app in **Flutter**, tuned for the device you'll actually use: a **Huawei MediaPad T3 on Android 7**, written on with a **finger**. The 8- and 10-inch T3 have a Snapdragon 425, 2–3 GB of RAM and a 1280×800 screen, so every choice below favours doing less work per frame and using little memory.

Why Flutter:

- **Not a web app.** The last Chrome for Android 7 is Chrome 119 (2023), so a web app would be stuck on an old browser forever, and PDF rendering in JavaScript (pdf.js) is slow on this chip.
- **Not Kotlin.** Native Kotlin would be a little faster to start and use a little less memory, but drawing and PDF speed would be about the same (both use the GPU and PDFium). Flutter wins on what this project needs: Claude can run its tests and render screenshots inside a cloud session, and the same code can later be built for iPad on your MacBook.
- **Flutter on Android 7.** Flutter supports Android 5 and up. On Android 7 it uses its OpenGL renderer (the Vulkan renderer is for Android 10 and up).

| Layer | Choice | Why |
| --- | --- | --- |
| Language + UI | Dart + Flutter (stable 3.47.x), Android only for now, minSdk 24 | Compiles to native ARM code and draws with its own engine; no browser in the way. |
| State | Built-in `ChangeNotifier` / `ValueNotifier` | No extra package. Canvas layers repaint through their own notifiers, so tool or menu changes never rebuild the page. |
| Ink | `CustomPainter` + `perfect_freehand` | Turns finger points into smooth, variable-width stroke outlines. Width comes from writing speed, since a finger has no pressure. |
| PDF viewing | `pdfrx` (bundles PDFium) | PDFium is the C++ engine inside Chrome's PDF viewer; renders off the UI thread and gives text for search later. |
| PDF export (later) | `pdf` package | Writes pages with your ink and tape baked in. Whether the original text stays selectable is decided when export is built. |
| Storage | SQLite via `drift` | Typed tables and migrations; stroke points stored as compact binary. PDFs are copied once into app storage as files. |
| File import | `file_picker` | Opens PDFs from Downloads, Drive, etc. |
| Spatial index | `rbush` | Fast eraser and lasso hit testing on pages with thousands of strokes. |
| Tests | `flutter_test`: unit, widget and golden (screenshot) tests | All run inside a cloud session with no device or emulator, so Claude can check its own work and look at screens. |
| Delivery | GitHub Actions → signed release APK on a GitHub Release | Every push to main builds a new APK; you download it on the tablet and install it over the old one. |
| Sync (later) | Supabase (`supabase_flutter`) | You already know it; added only after the local app is solid. |

If you later want an iPad version, Flutter builds for iOS on your MacBook with Xcode. Most code carries over; the input rules gain Apple Pencil support (pressure, pen-only mode), which the data model already has room for.

## Setup: GitHub + the $100 cloud credit

The credit is for Claude Code cloud sessions: Claude works on your GitHub repo inside an Anthropic-hosted VM, pushes a branch, and you merge it as a pull request. It applies automatically, and after it runs out or expires (Nov 5, 3:59 PM Manila time) your normal plan usage takes over. ([Claude Code on the web docs](https://code.claude.com/docs/en/web-quickstart))

1. **Create the repo.** (done) Private repo `margin` with a main branch.
2. **Connect GitHub.** (done) Claude GitHub App installed with access to `margin` at [claude.ai/code](https://claude.ai/code).
3. **Cloud environment.** The current environment reaches the Flutter SDK download and pub.dev, so sessions can install Flutter and run tests. It blocks `dl.google.com` (Android build tools), which is fine: GitHub Actions builds the APK. Allow `dl.google.com` under the environment's Allowed domains only if you want APKs built inside sessions too. ([cloud environments](https://code.claude.com/docs/en/cloud-environments#network-access))
4. **Add the plan to the repo.** (done) This file, `docs/PLAN.md`. Every session reads it, so you never re-explain the project.
5. **Run Session 0** (prompt in the Session prompts section). It scaffolds the app, writes a short `CLAUDE.md`, adds a startup hook that installs Flutter in each session, and sets up the APK build.
6. **Add the signing secrets.** Session 0 creates one signing key and tells you which secrets to add in the repo under Settings → Secrets and variables → Actions. Keep a copy of the key somewhere safe (a password manager). Every APK must be signed with this same key, or Android refuses to install updates.
7. **Prepare the tablet.** Turn on Settings → Security → Unknown sources (on Android 7 it's one switch). Sign in to GitHub in Chrome on the tablet, since the repo is private.
8. **Loop per feature.** Start a new session → Claude builds one feature and runs tests → open the PR from claude.ai/code → read the diff → merge → GitHub builds the APK → on the tablet, open the repo's Releases page, download the APK, install over the old one → report bugs in the next session.

**Credit rules**

- **One feature per session.** A session's cost grows with how much context it carries and how many turns it runs, so short, focused sessions stretch the credit furthest.
- **Point, don't paste.** Tell Claude which section of `docs/PLAN.md` to build instead of pasting the plan into the prompt.
- **Spend the credit on the hard parts first:** the ink engine, PDF rendering, tape, and storage. Styling and small UI tweaks can wait for your regular plan after Nov 5.
- **Parallel sessions only for separate features.** Two sessions at once burn the credit twice as fast and can conflict on the same files.
- **Check the balance daily** on the usage page. If a model picker is offered, heavier models spend the credit faster; use them for the ink and PDF engines, not for buttons and menus.
- **Judge speed only on the release APK.** Debug builds are many times slower and say nothing about how the app really feels.

## Feature scope

The MVP (built with the credit, by Nov 5) is a notebook you can write in with your finger, a PDF you can mark up, and tape you can hide and reveal. Everything marked "After" waits until the core feels fast on the T3. The look is inspired by Notability (clean toolbar along the top, paper-first pages), with an original name, icon and visuals.

| Area | Feature | What it does | When |
| --- | --- | --- | --- |
| Ink | Pen | Width follows writing speed (fingers have no pressure), color palette, 3 saved size presets per tool | MVP |
| Ink | Highlighter | See-through color drawn under the ink so text stays readable; hold at the end to snap to a straight line | MVP |
| Ink | Eraser | Two modes: whole-stroke eraser, and partial eraser that cuts strokes where it touches | MVP |
| Ink | Lasso | Select strokes and images to move, resize, recolor, copy, paste or delete | MVP |
| Ink | Undo / redo | Every action reversible, including tape and page changes | MVP |
| Ink | Finger gestures | One finger uses the current tool; two fingers scroll and zoom; a stroke is dropped if a second finger lands mid-stroke | MVP |
| Ink | Shape snap | Hold at the end of a stroke to turn it into a line, arrow, rectangle or ellipse | After |
| Ink | Stylus support | Pressure-based width and pen-only mode (palm rejection), for an active stylus or iPad | After |
| Tape | Tape tool | Draw a band over text; it becomes an opaque strip | MVP |
| Tape | Tap to reveal | Finger tap toggles one tape between hidden and peeked | MVP |
| Tape | Review mode | Drawing turns off: one finger scrolls and taps only flip tape, so quizzing yourself never leaves marks | MVP |
| Tape | Hide all / reveal all | One button resets every tape on the page or notebook | MVP |
| Tape | Tape styles | Solid colors and a few patterns | After |
| Tape | Study mode | Steps through tapes in order; you mark each "got it" or "missed" | After |
| Tape | Review missed | List of missed tapes, scheduled for review using the spaced-repetition logic from COGNIT | After |
| Page | Paper templates | Blank, lined, grid, dotted | MVP |
| Page | Pages | Vertical scrolling pages; add, delete, reorder | MVP |
| Page | Zoom and pan | Pinch to zoom, two-finger pan | MVP |
| Page | Text boxes | Typed text you can move and resize | After |
| Page | Images | Paste or insert a photo or screenshot, then move and resize it | After |
| PDF | Import | Open a PDF into a new notebook; every tool works on its pages | MVP |
| PDF | Thumbnails | Side panel of page previews to jump around | MVP |
| PDF | Insert blank page | Add a writing page between PDF pages | MVP |
| PDF | Search | Find typed text inside the PDF | After |
| PDF | Export | Save a new PDF with your ink and tape baked in | After |
| Library | Notebooks + subjects | Folders per subject, recent list, rename, duplicate, delete | MVP |
| Library | Backup | Export and import the whole library as one file | After (first thing after Nov 5) |
| Sync | Cloud sync | Same notebooks on several devices through Supabase | After |
| Search | Handwriting search | Recognize handwriting so it can be searched | After |

Not planned: audio recording. It adds a large feature for little reviewer value.

## Architecture and data model

Each page is a stack of layers, and only the top one repaints while you write. Strokes are saved as small arrays of numbers, not images, so notebooks stay light and every stroke can still be erased, moved or recolored.

**Terms used here**

- **Stroke:** one finger-down to finger-up line, stored as a list of points. Each point is x, y and pressure (0 to 1). With a finger, "pressure" is computed from writing speed while you write.
- **Page coordinates:** positions measured in PDF points (1/72 inch) on the page itself, so zooming changes how strokes are drawn but never the stored numbers.
- **Bounding box (bbox):** the smallest rectangle around a stroke. Checking boxes first makes erasing, lasso and tape taps fast, because most strokes are ruled out without testing every point.
- **RepaintBoundary:** a Flutter widget that gives its child its own GPU layer, so repainting one layer never repaints the others.
- **Background thread:** pdfrx renders PDF pages off the UI thread, so PDF rendering never freezes your finger's line.

**Layer stack per page** (bottom to top): background (paper template or PDF page image) → highlighter → ink → tape → live stroke. Each is its own `RepaintBoundary` + `CustomPainter`.

**Data model** (SQLite tables through drift, one row per object)

```dart
Subject  { id, name, color, order }
Notebook { id, subjectId, title, kind: notes | pdf, pdfFileId?, pageIds: List<String>, createdAt, updatedAt }
PdfFile  { id, path, pageCount, sha256 }            // file copied once into app storage; pages point to it
Page     { id, notebookId, width, height,
           background: template(blank | lined | grid | dotted)
                     | pdf(pageIndex) }
Stroke   { id, pageId, tool: pen | highlighter, color, size,
           points: Float32List,                     // x, y, pressure repeated; stored as a BLOB
           bbox: [minX, minY, maxX, maxY], createdAt }
Tape     { id, pageId, points: Float32List, width, style, hidden: bool,
           study?: { lastResult: got | missed, dueAt? } }
// After MVP: TextBox, Image
```

Strokes and tapes are indexed by `pageId`, so opening a page is one query. Pages are ordered by the `pageIds` list, so reordering pages rewrites one row instead of every page. Storing pressure per point keeps the format ready for a real stylus later.

**How finger input works**

1. Drawing uses a raw `Listener`, not `GestureDetector`. A gesture detector waits until the finger has moved about 18 px before it reports a drag, which would make every stroke start late.
2. One finger down: the current tool starts at once.
3. A second finger lands while drawing: the in-progress stroke is dropped (it never reaches undo history or the database) and the touch becomes scroll and pinch zoom.
4. A finger touch that moves less than about 10 px and lifts within 250 ms is a **tap**, not a stroke (see How tape works).
5. Width from speed is computed while writing and stored as each point's pressure. Rendering then uses the stored values, so simplifying points after the stroke ends never changes how it looks.
6. There is no palm rejection with a finger. Keep your hand off the screen, or use Review mode when only reading.

**How tape works**

1. With the Tape tool, a finger drag draws a thick band (a stroke with square ends) and saves it as a `Tape` with `hidden: true`.
2. A tap (step 4 above) is tested against each tape's bounding box, then its exact outline. A hit flips `hidden`. In the pen and highlighter tools, a tap on a tape flips it instead of drawing a dot.
3. Hidden tape draws fully opaque. Peeked tape draws as a faint outline so you still see where the answer was.
4. **Review mode** turns drawing off: one finger scrolls, taps flip tapes, and the toolbar shrinks to Hide all, Reveal all and Exit.
5. Hide all / reveal all sets `hidden` on every tape of the page or notebook in one database write.

**Code layout**

```text
lib/
  main.dart
  app/        library and notebook screens
  input/      raw pointer handling: draw vs. tap vs. two-finger scroll/zoom
  tools/      pen, highlighter, eraser, lasso, tape
  canvas/     layer painters, stroke picture cache, hit testing
  pdf/        pdfrx wrapper, page image cache
  state/      ChangeNotifiers: tool settings, open notebook, selection, review mode
  db/         drift tables and migrations
  history/    undo/redo as reversible commands
  ui/         toolbar, color palette, thumbnails, theme
test/         unit, widget and golden tests
.github/workflows/  analyze + test; signed release APK on main
```

## Performance plan

The app feels fast if the line appears under your finger with no lag and big PDFs scroll smoothly. Both come from doing as little work as possible per frame, which is one screen refresh: about 16 ms at 60 Hz. On a Snapdragon 425 there is little headroom, so these rules are not optional.

**Targets** (checked on the T3 with the release APK)

| Measure | Target |
| --- | --- |
| Frame time while writing | Under 16 ms, no dropped frames |
| Cold start to library | Under 2 seconds |
| Open a 200-page PDF to first visible page | Under 1 second |
| Open a 50-page handwritten notebook | Under 1 second |
| Tap on tape to reveal | Visible on the next frame |

The app gets a hidden setting that turns on Flutter's performance overlay (frame-time graphs drawn over the app), so frame times can be read on the tablet itself without a computer.

**Writing**

- **Repaint only the live stroke each frame.** The stroke being written sits on its own top layer. On finger-up it is added to the ink layer once and the live layer is cleared, so old strokes are never redrawn while writing.
- **Cache finished strokes.** Each page's ink is recorded into one `ui.Picture`; when a page passes a few hundred strokes it is flattened to an image, so the GPU draws one picture instead of every path.
- **Highlighter without darkening.** Highlighter strokes are drawn opaque into their own cached layer, and that whole layer is shown at partial opacity. Overlapping highlights stay even, and the cost is one composite, not one per stroke.
- **Keep widget rebuilds out of the drawing path.** Pointer handling, tools and painters are plain Dart objects. Painters repaint through a `Listenable`; widgets only draw the toolbar, menus and library, so a state change never rebuilds the page.
- **Use every touch sample.** Don't throttle or resample pointer events; more points means smoother curves.
- **Shrink strokes after finger-up.** Remove points that add nothing to the shape (Ramer–Douglas–Peucker simplification with a tiny tolerance), then save as a `Float32List`.
- **Save after, not during.** Database writes are batched a moment after finger-up in one transaction, never mid-stroke.
- **Keep effects simple.** No blur, shadows or saveLayer-heavy effects on the canvas. On Android 7, Flutter's OpenGL renderer can stutter the first time a new effect is drawn.

**Pages and PDFs**

- **Only build what's on screen.** Pages are built lazily (`ListView.builder`-style); pages more than one screen away hold no images, and their cached pictures are disposed. With 2–3 GB of RAM this is what keeps Android from killing the app.
- **PDF pages render off the UI thread** with pdfrx, once at the current zoom, and are kept in a small least-recently-used cache of page images, so scrolling back costs nothing.
- **Cheap zoom, sharp finish.** During a pinch the page layers are scaled with a transform (instant but blurry). When the fingers lift, visible PDF pages re-render sharp at the new zoom; ink is vector and redraws sharp from the cached picture.
- **Fast eraser and lasso.** Each stroke's bounding box is checked first, so only strokes near the finger are tested point by point. A spatial index (`rbush`) handles pages with thousands of strokes.
- **Thumbnails at low resolution,** generated in idle time, never while writing.
- **Fast start.** The first screen is the library list only; nothing from notebooks or PDFs loads until you open one.

## Build phases

Eight focused sessions fit before the credit expires on Nov 5 at 3:59 PM, about one a day, with Nov 5 morning kept free for fixes. Each session ends with a merged PR, a new APK, and a quick test on the T3 before the next one starts.

| Session | Target date | Builds | Done when |
| --- | --- | --- | --- |
| 0. Scaffold | Oct 26–27 | Flutter app, drift schema, tests, startup hook, signed APK build on GitHub Actions, `CLAUDE.md` | The APK from GitHub installs on the T3 and opens a blank library screen |
| 1. Ink engine | Oct 27–28 | Raw finger input, speed-based pen, live and ink layers, two-finger cancel, undo/redo | Writing with your finger on one page feels instant on the T3 |
| 2. Pages + library | Oct 28–29 | Subjects, notebooks, paper templates, scrolling pages, zoom and pan, autosave | Notes survive closing the app from Recent apps and reopening it |
| 3. Highlighter + eraser | Oct 29–30 | Highlighter under ink, whole-stroke and partial eraser, color palette, size presets | You can mark up and correct a full page |
| 4. Lasso | Oct 30–31 | Select, move, resize, recolor, copy, paste, delete | You can rearrange a page's notes |
| 5. PDF | Nov 1–2 | PDF import, page image cache, thumbnails, insert blank page | A 200-page lecture PDF scrolls smoothly and takes ink |
| 6. Tape | Nov 2–3 | Tape tool, tap to reveal, Review mode, hide all / reveal all | You can cover answers on a reviewer and quiz yourself |
| 7. Speed + fixes | Nov 3–4 | Measure against the targets, fix what misses, fix tablet bugs | All five targets in the Performance plan pass |
| Buffer | Nov 5 AM | Leftover fixes | Credit expires 3:59 PM |

**After Nov 5** (your regular plan): library backup first, then study mode and missed-tape review, shape snap, text boxes, images, PDF search and export, stylus support, then Supabase sync.

If a session runs over, drop Session 4 (lasso) to after Nov 5 rather than squeezing tape or PDF. Those two are the reason you're building this.

## Session prompts

Start each one as a new cloud session on the `margin` repo. Each prompt names the plan sections to read instead of repeating them, which keeps sessions short.

**Session 0: Scaffold**

```text
Read docs/PLAN.md: Key decisions, Architecture and data model, Performance plan.
Scaffold the app:
- Flutter app pinned to the current stable, Android only, minSdk 24. Packages: drift, pdfrx, perfect_freehand, file_picker, path_provider, rbush. Strict analysis options (flutter_lints, strict casts and inference).
- Drift schema from the data model (Subjects, Notebooks, PdfFiles, Pages, Strokes, Tapes), with a test that writes and reads each table using an in-memory database.
- Folder layout from "Code layout", with placeholder modules, an empty library screen, and one golden test of it.
- A SessionStart hook that installs the pinned Flutter SDK when missing and runs flutter pub get, so later sessions can test right away.
- GitHub Actions: on every push and PR run flutter analyze and flutter test; on push to main build a signed release APK and attach it to a GitHub Release.
- Create the signing key, never commit it, and tell me exactly which repo secrets to add.
- CLAUDE.md, under 40 lines: stack, folders, commands, and rules (keep widget rebuilds out of the drawing path, store page coordinates, every feature gets tests, run flutter analyze and flutter test before finishing).
Open a PR when done.
```

**Session 1: Ink engine**

```text
Read CLAUDE.md, the Ink rows of Feature scope, "How finger input works", and "Writing" in the Performance plan.
Build the ink engine on one fixed page:
- Raw pointer input with Listener (no gesture slop). One finger draws; a second finger drops the in-progress stroke.
- Pen tool with perfect_freehand. Width from writing speed, computed while writing and stored as each point's pressure.
- Live layer for the current stroke, cached ink layer for finished strokes, each in its own RepaintBoundary.
- Undo/redo as reversible commands in lib/history.
- Simplify points on finger-up, then save the stroke with drift.
- Hidden setting for the performance overlay.
- Unit tests for simplification, speed-to-width, undo/redo, and stroke save/load; a golden test of a page with sample strokes.
Open a PR with a short list of what I should test on my tablet.
```

**Session 2: Pages and library**

```text
Read CLAUDE.md, the Page and Library rows of Feature scope, "How finger input works", and "Pages and PDFs" in the Performance plan.
Build: subjects and notebooks screen; paper templates (blank, lined, grid, dotted); vertical scrolling pages with add/delete/reorder; only pages near the screen hold pictures or images; two-finger pinch zoom (transform during the gesture, sharp redraw after) and pan; autosave.
Tests for page ordering, notebook CRUD and the two-finger handover; golden tests of the library and each paper template. Open a PR.
```

**Session 3: Highlighter and eraser**

```text
Read CLAUDE.md, the Ink rows of Feature scope, and "Writing" in the Performance plan.
Build: highlighter layer under ink (opaque strokes in a cached layer shown at partial opacity) with hold-to-straighten; whole-stroke eraser; partial eraser that splits strokes; color palette; 3 size presets per tool saved in settings. Use bounding boxes before point tests.
Tests for stroke splitting and hit testing. Open a PR.
```

**Session 4: Lasso**

```text
Read CLAUDE.md and the Lasso row of Feature scope.
Build lasso selection of strokes: move, resize, recolor, copy, paste, delete, all undoable. Use rbush for hit testing.
Tests for selection and transforms. Open a PR.
```

**Session 5: PDF**

```text
Read CLAUDE.md, the PDF rows of Feature scope, and "Pages and PDFs" in the Performance plan.
Build: import a PDF into a new notebook (copy the file once into app storage, one PdfFile row); render visible pages with pdfrx off the UI thread and keep them in a small LRU image cache; release far pages; thumbnail panel generated in idle time; insert a blank page between PDF pages. All existing tools must work on PDF pages.
Tests with a small sample PDF in test fixtures. Open a PR.
```

**Session 6: Tape**

```text
Read CLAUDE.md, the Tape rows of Feature scope, "How finger input works", and "How tape works" in Architecture.
Build: Tape tool; finger tap to toggle one tape (also from pen and highlighter); hidden tape fully opaque, peeked tape as a faint outline; Review mode; hide all and reveal all per page and per notebook; undo support.
Tests for tap detection, tape hit testing and Review mode; golden tests of hidden and peeked tape. Open a PR.
```

**Session 7: Speed and fixes**

```text
Read CLAUDE.md and the Performance plan targets.
My tablet test results: <paste what lagged, what broke, performance overlay readings>.
Fix the bugs, then find and fix the slowest code paths for each target. Report which targets you could and couldn't verify in this environment. Open a PR.
```

**Bug report template** (for any session)

```text
Device: MediaPad T3 <8 or 10>, Android 7
App build: <release name from GitHub>
What I did: <steps>
What happened: <result>
What I expected: <result>
```

## Risks and testing

The biggest risk is losing notes, not lag. On Android, uninstalling the app deletes its data, and an APK signed with a different key can only be installed by uninstalling first. One fixed signing key from Session 0 prevents that; library backup (first after Nov 5) covers the rest.

| Risk | What happens | Fix |
| --- | --- | --- |
| Signing key lost or changed | Android refuses the update; uninstalling wipes all notes | One key from Session 0, stored as GitHub secrets plus your own copy; never uninstall to "fix" an install error |
| Android kills the app in the background (2–3 GB RAM, EMUI) | Last strokes lost; app restarts on the library | Save within a second of finger-up; reopen to the last notebook and page |
| Memory on big PDFs | App crashes or gets killed on a 200-page PDF | Only visible pages hold images; small LRU cache (Performance plan) |
| Fingers are blunt | Small handwriting is hard to write | Zoom in to write; a Notability-style zoom box can come after Nov 5 |
| Accidental marks while reviewing | Taps and scrolls leave dots and lines on your notes | Review mode; two-finger scroll; undo |
| No Android device in the cloud | Feel and speed can't be judged by Claude | Unit and golden tests in every session; tablet checklist after every merge |
| Old OpenGL renderer on Android 7 | Occasional first-time stutter | Simple canvas effects; measure in Session 7 |
| Credit runs out early | Tape or PDF unfinished | Build order already puts them before lasso; check the balance daily |
| Merging without reading | Bugs pile up across sessions | Read each diff and run the checklist before the next session |
| Copying the original app | Trouble if you ever publish it | Original name, icon and visuals; build the features, not their look |

**Tablet checklist** (run on the release APK after every merge from Session 1 on)

- [ ] Write a full page fast with your finger: no lag, no gaps in lines
- [ ] Start scrolling with two fingers mid-stroke: no stray line is left behind
- [ ] Undo 20 times, then redo 20 times
- [ ] Erase part of a stroke, then undo it
- [ ] Import a 200-page PDF and scroll top to bottom
- [ ] Cover 20 answers with tape, swipe the app away from Recent apps, reopen: tapes are still hidden
- [ ] In Review mode, tap 20 tapes: no marks appear
- [ ] Install the next APK over the old one: all notebooks are still there
