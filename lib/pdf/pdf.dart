/// pdfrx wrapper and the LRU cache of rendered page images.
///
/// Renders off the UI thread; pages far from the screen release their
/// images. See "Pages and PDFs" in docs/PLAN.md. Session 5.
library;
