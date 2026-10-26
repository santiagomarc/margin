# Margin — Study Notes & PDF App Plan

Oct 26, 2026 · @marc

## Key decisions

Build Margin (working name) as an installable web app (PWA) in TypeScript. The $100 credit only pays for Claude Code cloud sessions, and those run on Linux VMs that can install, build, test and deploy a web app end to end. They cannot run Xcode or the iOS Simulator, so a native iPad app would leave Claude writing Swift it can never compile or check.

A PWA also fits your setup. You already write TypeScript, it runs on an iPad (Safari passes Apple Pencil pressure through Pointer Events), an Android tablet, or your MacBook, and you can install it to the home screen so it opens full-screen and works offline.

**Open question:** which device will you actually write on? Your MacBook Air M3 and iPhone 13 have no stylus, so pen testing needs a tablet. The plan assumes an iPad or Android tablet with a stylus.

| Layer | Choice | Why |
| --- | --- | --- |
| UI | TypeScript + React + Vite | Fast dev server and build. No server rendering needed, so Next.js would add weight for nothing. |
| State | Zustand | Small store, easy to keep the canvas out of React re-renders. |
| Ink | Canvas 2D + perfect-freehand | Turns pen points plus pressure into smooth, variable-width stroke outlines. |
| PDF viewing | pdf.js (pdfjs-dist) | Renders PDF pages to canvas and gives the text layer for search. |
| PDF export | pdf-lib | Writes your ink and tape onto a copy of the PDF for sharing. |
| Storage | IndexedDB via Dexie | Stores notebooks, pages, strokes and PDF files locally; works offline. |
| Offline + install | vite-plugin-pwa | Service worker and manifest so it installs and opens with no internet. |
| Tests | Vitest + Playwright | Both run inside a cloud session, so Claude can check its own work. |
| Hosting | GitHub Pages or Vercel, free tier | Every merge to main redeploys; you open the URL on your tablet. |
| Sync (later) | Supabase | You already know it; added only after the local app is solid. |

If you later want a native iPad version, the path is SwiftUI + PencilKit + PDFKit, built on your Mac in Xcode. The data model below is designed so notes could be exported to it.

## Setup: GitHub + the $100 cloud credit

The credit is for Claude Code cloud sessions: Claude works on your GitHub repo inside an Anthropic-hosted VM, pushes a branch, and you merge it as a pull request. It applies automatically, and after it runs out or expires (Nov 5, 3:59 PM Manila time) your normal plan usage takes over. ([Claude Code on the web docs](https://code.claude.com/docs/en/web-quickstart))

1. **Create the repo.** On [github.com/new](https://github.com/new), make a private repo named `margin`. Tick "Add a README" so the repo has a main branch.
2. **Connect GitHub.** Open [claude.ai/code](https://claude.ai/code), sign in, and follow the prompt to install the Claude GitHub App. Give it access to the `margin` repo.
3. **Create a cloud environment.** When prompted, name it `margin` and set Network access to **Trusted**. Trusted allows the npm registry and GitHub, which is all this project needs to install packages. ([cloud environments](https://code.claude.com/docs/en/cloud-environments))
4. **Add the plan to the repo.** Export this doc as Markdown and commit it as `docs/PLAN.md`. Every session reads it, so you never re-explain the project.
5. **Run Session 0** (prompt in the Session prompts section). It scaffolds the app, writes a short `CLAUDE.md` with project rules, and sets up auto-deploy to GitHub Pages.
6. **Turn on Pages.** In the repo, go to Settings → Pages and set Source to "GitHub Actions". Each merge to main then publishes the app at `https://<your-username>.github.io/margin/`.
7. **Loop per feature.** Start a new session → Claude builds one feature and runs tests → open the PR from claude.ai/code → read the diff → merge → test on your tablet from the Pages URL → report bugs in the next session.

**Credit rules**

- **One feature per session.** A session's cost grows with how much context it carries and how many turns it runs, so short, focused sessions stretch the credit furthest.
- **Point, don't paste.** Tell Claude which section of `docs/PLAN.md` to build instead of pasting the plan into the prompt.
- **Spend the credit on the hard parts first:** the ink engine, PDF rendering, tape, and storage. Styling and small UI tweaks can wait for your regular plan after Nov 5.
- **Parallel sessions only for separate features.** Two sessions at once burn the credit twice as fast and can conflict on the same files.
- **Check the balance daily** on the usage page you screenshotted. If a model picker is offered, heavier models spend the credit faster; use them for the ink and PDF engines, not for buttons and menus.
- **First-session check:** ask Claude to run `check-tools` to see what's preinstalled. If Playwright can't download its browser under Trusted access, keep end-to-end tests local and run only Vitest in the cloud.

## Feature scope

The MVP (built with the credit, by Nov 5) is a notebook you can write in, a PDF you can mark up, and tape you can hide and reveal. Everything marked "After" waits until the core feels fast on your tablet.

| Area | Feature | What it does | When |
| --- | --- | --- | --- |
| Ink | Pen | Pressure-sensitive width, color palette, 3 saved size presets per tool | MVP |
| Ink | Highlighter | See-through color drawn under the ink so text stays readable; hold at the end to snap to a straight line | MVP |
| Ink | Eraser | Two modes: whole-stroke eraser, and partial eraser that cuts strokes where it touches | MVP |
| Ink | Lasso | Select strokes and images to move, resize, recolor, copy, paste or delete | MVP |
| Ink | Undo / redo | Every action reversible, including tape and page changes | MVP |
| Ink | Pen-only mode | Stylus draws, fingers only scroll and zoom (palm rejection) | MVP |
| Ink | Shape snap | Hold at the end of a stroke to turn it into a line, arrow, rectangle or ellipse | After |
| Tape | Tape tool | Draw a band over text; it becomes an opaque strip | MVP |
| Tape | Tap to reveal | Finger tap toggles one tape between hidden and peeked | MVP |
| Tape | Hide all / reveal all | One button resets every tape on the page or notebook | MVP |
| Tape | Tape styles | Solid colors and a few patterns | After |
| Tape | Study mode | Steps through tapes in order; you mark each "got it" or "missed" | After |
| Tape | Review missed | List of missed tapes, scheduled for review using the spaced-repetition logic from COGNIT | After |
| Page | Paper templates | Blank, lined, grid, dotted | MVP |
| Page | Pages | Vertical scrolling pages; add, delete, reorder | MVP |
| Page | Zoom and pan | Pinch to zoom, two-finger pan | MVP |
| Page | Text boxes | Typed text you can move and resize | After |
| Page | Images | Paste or insert a photo or screenshot, then move and resize it | After |
| PDF | Import | Open a PDF into a new notebook; every pen tool works on its pages | MVP |
| PDF | Thumbnails | Side panel of page previews to jump around | MVP |
| PDF | Insert blank page | Add a writing page between PDF pages | MVP |
| PDF | Search | Find typed text inside the PDF | After |
| PDF | Export | Save a new PDF with your ink and tape baked in | After |
| Library | Notebooks + subjects | Folders per subject, recent list, rename, duplicate, delete | MVP |
| Library | Backup | Export and import the whole library as one file | After |
| Sync | Cloud sync | Same notebooks on several devices through Supabase | After |
| Search | Handwriting search | Recognize handwriting so it can be searched | After |

Not planned: audio recording. It adds a large feature for little reviewer value.

## Architecture and data model

Each page is a stack of canvases, and only the top one redraws while you write. Strokes are saved as small arrays of numbers, not images, so notebooks stay light and every stroke can still be erased, moved or recolored.

**Terms used here**

- **Stroke:** one pen-down to pen-up line, stored as a list of points. Each point is x, y and pressure (0 to 1, how hard the stylus presses).
- **Page coordinates:** positions measured in PDF points (1/72 inch) on the page itself, so zooming changes how strokes are drawn but never the stored numbers.
- **Bounding box (bbox):** the smallest rectangle around a stroke. Checking boxes first makes erasing and lasso fast, because most strokes are ruled out without testing every point.
- **Web Worker:** a background thread in the browser. pdf.js runs there so PDF rendering never freezes the pen.

**Data model** (IndexedDB tables through Dexie, one row per object)

```ts
Subject  { id, name, color, order }
Notebook { id, subjectId, title, kind: 'notes' | 'pdf', pdfFileId?, pageIds: string[], createdAt, updatedAt }
PdfFile  { id, blob, pageCount, sha256 }            // stored once; pages point to it
Page     { id, notebookId, width, height,
           background: { type: 'template', template: 'blank' | 'lined' | 'grid' | 'dotted' }
                     | { type: 'pdf', pageIndex: number } }
Stroke   { id, pageId, tool: 'pen' | 'highlighter', color, size,
           points: Float32Array,                     // x, y, pressure repeated
           bbox: [minX, minY, maxX, maxY], createdAt }
Tape     { id, pageId, points: Float32Array, width, style, hidden: boolean,
           study?: { lastResult: 'got' | 'missed', dueAt?: number } }
// After MVP: TextBox, Image
```

Strokes and tapes are indexed by `pageId`, so opening a page is one query. Pages are ordered by the `pageIds` array, so reordering pages rewrites one row instead of every page.

**How tape works**

1. With the Tape tool, the stylus draws a thick band (a stroke with square ends) and saves it as a `Tape` with `hidden: true`.
2. A finger tap that moves less than about 10 px and lifts within 250 ms counts as a tap, not a scroll.
3. The tap point is tested against each tape's bounding box, then its exact outline. A hit flips `hidden`.
4. Hidden tape draws fully opaque. Peeked tape draws as a faint outline so you still see where the answer was.
5. Hide all / reveal all sets `hidden` on every tape of the page or notebook in one database write.

**Code layout**

```text
src/
  app/        library and notebook screens
  input/      pointer events, tap vs. drag, pinch zoom, pen-only mode
  tools/      pen, highlighter, eraser, lasso, tape
  canvas/     layer renderer, stroke cache, hit testing
  pdf/        pdf.js worker wrapper, page bitmap cache
  store/      Zustand slices (tool settings, open notebook, selection)
  db/         Dexie schema and migrations
  history/    undo/redo as reversible commands
  ui/         toolbar, color palette, thumbnails
```

## Performance plan

The app feels fast if the line appears under the pen tip with no lag and big PDFs scroll smoothly. Both come from doing as little work as possible per frame, which is one screen refresh: about 16 ms at 60 Hz.

**Targets** (checked with the browser's Performance panel on your tablet)

| Measure | Target |
| --- | --- |
| Frame time while writing | Under 16 ms, no dropped frames |
| Open a 200-page PDF to first visible page | Under 1 second |
| Open a 50-page handwritten notebook | Under 1 second |
| Tap on tape to reveal | Visible on the next frame |

**Writing**

- **Draw only the live stroke each frame.** The stroke being written sits on its own top canvas. On pen-up it is drawn once into the ink layer and the top canvas is cleared, so old strokes are never redrawn while writing.
- **Capture every stylus sample.** A stylus reports points faster than the screen refreshes. `getCoalescedEvents()` returns the in-between points so curves stay smooth; `getPredictedEvents()` guesses the next point to cut visible lag. Use both where the browser supports them and fall back cleanly where it doesn't.
- **Keep React out of the drawing path.** Pointer handling, tools and canvas drawing are plain TypeScript. React only draws the toolbar, menus and library, so a state change never re-renders the page.
- **Stop the browser interfering.** `touch-action: none` on the canvas blocks scroll and zoom gestures under the pen; turning off text selection and the long-press menu stops iPad Safari popups while writing.
- **Shrink strokes after pen-up.** Remove points that add nothing to the shape (Ramer–Douglas–Peucker simplification with a tiny tolerance), then save as a `Float32Array`.
- **Save after, not during.** Writes to IndexedDB are batched a moment after pen-up, never mid-stroke.

**Pages and PDFs**

- **Only build what's on screen.** Pages more than one screen away hold no canvas. iPad Safari caps total canvas memory, so canvases for far pages are released (width and height set to 0).
- **pdf.js already parses in its own worker.** Each page is rendered once at the current zoom and kept as an `ImageBitmap` (a ready-to-draw image), so scrolling back costs nothing.
- **Cheap zoom, sharp finish.** During a pinch the page is scaled with a CSS transform (instant but blurry). When the fingers lift, visible pages re-render sharp at the new zoom.
- **Fast eraser and lasso.** Each stroke's bounding box is checked first, so only strokes near the pen are tested point by point. A spatial index (rbush) handles pages with thousands of strokes.
- **Thumbnails at low resolution,** generated in idle time, never while writing.

## Build phases

Eight focused sessions fit before the credit expires on Nov 5 at 3:59 PM, about one a day, with Nov 5 morning kept free for fixes. Each session ends with a merged PR and a quick test on your tablet before the next one starts.

| Session | Target date | Builds | Done when |
| --- | --- | --- | --- |
| 0. Scaffold | Oct 26–27 | Vite + React + TS, PWA setup, Dexie schema, Vitest, GitHub Pages deploy, `CLAUDE.md` | The Pages URL opens a blank app you can install to the home screen |
| 1. Ink engine | Oct 27–28 | Pointer input, pressure pen, live and ink layers, pen-only mode, undo/redo | Writing on one page feels instant on your tablet |
| 2. Pages + library | Oct 28–29 | Subjects, notebooks, paper templates, scrolling pages, zoom and pan, autosave | Notes survive closing and reopening the app |
| 3. Highlighter + eraser | Oct 29–30 | Highlighter under ink, whole-stroke and partial eraser, color palette, size presets | You can mark up and correct a full page |
| 4. Lasso | Oct 30–31 | Select, move, resize, recolor, copy, paste, delete | You can rearrange a page's notes |
| 5. PDF | Nov 1–2 | PDF import, page bitmap cache, thumbnails, insert blank page | A 200-page lecture PDF scrolls smoothly and takes ink |
| 6. Tape | Nov 2–3 | Tape tool, tap to reveal, hide all / reveal all | You can cover answers on a reviewer and quiz yourself |
| 7. Speed + fixes | Nov 3–4 | Measure against the targets, fix what misses, fix tablet bugs | All four targets in the Performance plan pass |
| Buffer | Nov 5 AM | Leftover fixes | Credit expires 3:59 PM |

**After Nov 5** (your regular plan): study mode and missed-tape review, shape snap, text boxes, images, PDF search and export, library backup, then Supabase sync.

If a session runs over, drop Session 4 (lasso) to after Nov 5 rather than squeezing tape or PDF. Those two are the reason you're building this.

## Session prompts

Start each one as a new cloud session on the `margin` repo. Each prompt names the plan sections to read instead of repeating them, which keeps sessions short.

**Session 0: Scaffold**

```text
Read docs/PLAN.md: Key decisions, Architecture and data model, Performance plan.
Scaffold the app:
- Vite + React + TypeScript (strict), Zustand, Dexie, vite-plugin-pwa, Vitest.
- Dexie schema from the data model (Subject, Notebook, PdfFile, Page, Stroke, Tape), with a test that writes and reads each table.
- Folder layout from "Code layout", with placeholder modules.
- GitHub Actions workflow: run tests, then deploy dist/ to GitHub Pages on every push to main. Set Vite base to /margin/.
- CLAUDE.md, under 40 lines: stack, folders, commands, and rules (keep React out of the drawing path, store page coordinates, every feature gets tests, run npm test and npm run build before finishing).
- Run check-tools and tell me if Playwright browsers can be installed here.
Open a PR when done.
```

**Session 1: Ink engine**

```text
Read CLAUDE.md, the Ink rows of the Feature scope table, and "Writing" in the Performance plan.
Build the ink engine on one fixed page:
- Pointer Events input, using getCoalescedEvents and getPredictedEvents when available.
- Pen tool with perfect-freehand and pressure. Live canvas for the current stroke, ink canvas for finished strokes, both scaled by devicePixelRatio.
- Pen-only mode: pointerType "pen" draws, "touch" never draws.
- Undo/redo as reversible commands in src/history.
- Simplify points on pen-up, then save the stroke to Dexie.
- Tests for simplification, undo/redo, and stroke save/load.
Open a PR with a short list of what I should test on my tablet.
```

**Session 2: Pages and library**

```text
Read CLAUDE.md, the Page and Library rows of Feature scope, and "Pages and PDFs" in the Performance plan.
Build: subjects and notebooks screen; paper templates (blank, lined, grid, dotted); vertical scrolling pages with add/delete/reorder; only pages near the screen hold a canvas; pinch zoom (CSS transform during the gesture, sharp redraw after); two-finger pan; autosave.
Tests for page ordering and notebook CRUD. Open a PR.
```

**Session 3: Highlighter and eraser**

```text
Read CLAUDE.md and the Ink rows of Feature scope.
Build: highlighter layer drawn under ink with hold-to-straighten; whole-stroke eraser; partial eraser that splits strokes; color palette; 3 size presets per tool saved in settings. Use bounding boxes before point tests.
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
Build: import a PDF into a new notebook (store the file once in PdfFile); render visible pages with pdf.js and cache them as ImageBitmaps; release far pages; thumbnail panel generated in idle time; insert a blank page between PDF pages. All existing tools must work on PDF pages.
Tests with a small sample PDF in test fixtures. Open a PR.
```

**Session 6: Tape**

```text
Read CLAUDE.md, the Tape rows of Feature scope, and "How tape works" in Architecture.
Build: Tape tool; finger tap to toggle one tape; hidden tape fully opaque, peeked tape as a faint outline; hide all and reveal all per page and per notebook; undo support.
Tests for tap detection and tape hit testing. Open a PR.
```

**Session 7: Speed and fixes**

```text
Read CLAUDE.md and the Performance plan targets.
My tablet test results: <paste what lagged, what broke, device and browser>.
Fix the bugs, then find and fix the slowest code paths for each target. Report which targets you could and couldn't verify in this environment. Open a PR.
```

**Bug report template** (for any session)

```text
Device and browser: <e.g. iPad 9th gen, Safari>
What I did: <steps>
What happened: <result>
What I expected: <result>
```

## Risks and testing

The biggest risk is losing notes, not lag: iPad Safari can clear a website's stored data if you don't visit it for about a week. Installing the app to the home screen avoids that, and a backup export covers the rest.

| Risk | What happens | Fix |
| --- | --- | --- |
| Storage cleared by Safari | Notebooks vanish after a week of not opening the site in the browser | Always use the home-screen install; call `navigator.storage.persist()`; move library backup earlier if you rely on it for exams |
| No stylus device to test on | Pen feel can't be judged; bugs found late | Borrow a tablet or test on one before Session 1 merges |
| Canvas memory limit on iPad | Safari reloads the page on huge PDFs | Only visible pages hold canvases (Performance plan) |
| Web can't reach some Pencil features | No double-tap to switch tools like native apps have | On-screen tool toggle within thumb reach |
| Credit runs out early | Tape or PDF unfinished | Build order already puts them before lasso; check the balance daily |
| Merging without reading | Bugs pile up across sessions | Read each diff and run the checklist before the next session |
| Copying the original app | Trouble if you ever publish it | Original name, icon and visuals; build the features, not their look |

**Tablet checklist** (run after every merge from Session 1 on)

- [ ] Write a full page fast: no lag, no gaps in lines
- [ ] Rest your palm on the screen while writing: no stray marks
- [ ] Undo 20 times, then redo 20 times
- [ ] Erase part of a stroke, then undo it
- [ ] Import a 200-page PDF and scroll top to bottom
- [ ] Cover 20 answers with tape, close the app, reopen: tapes are still hidden
- [ ] Turn on airplane mode: the app opens and saves notes
