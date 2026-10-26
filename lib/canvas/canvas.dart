/// Page layer painters, the per-page stroke picture cache and hit testing.
///
/// Layer stack, bottom to top: background, highlighter, ink, tape, live
/// stroke; each in its own RepaintBoundary. See "Writing" in docs/PLAN.md.
library;
