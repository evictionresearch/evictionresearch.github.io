# ERN Web Design Architecture

This file used to be a 479-line description of the site's UpConstruction /
Bootstrap 5 build, with the content pages on legacy Spectral markup. That
stack is no longer how the main pages are built, and the file had been stale
since February 2026. It is now a pointer.

**The canonical site design system lives in the ERN library:**

→ [`evictionresearch/library/standards/ern-site-design-2026.md`](https://github.com/evictionresearch/library/blob/main/standards/ern-site-design-2026.md)

Maintain design decisions there, not here.

## What that file covers

- The stack: Quarto `.qmd` sources, a full custom pandoc template per page
  under `_extensions/ern/`, and `assets/css/ern-2026.css` as the whole design
  system. No Bootstrap, no `main.css`, no vendor bundle.
- The design tokens, transcribed from the stylesheet, including
  `--red-on-dark: #ff706a` for red on the navy ground.
- The one-red decision of 2026-08-24 and the WCAG 2.1 AA position it takes,
  with the measured ratios and the April 26, 2027 Berkeley deadline.
- Which pages are on the 2026 system, which are still legacy, and the one
  page that is self-contained.
- Components, the two breakpoints, and the deprecated colour list.

## Still in this repo

- [`design-handoff-2026-08/`](./design-handoff-2026-08/) — the August 2026
  design review that produced the system. Read it for layout and intent; its
  colour tokens are superseded by `ern-2026.css`.
- [`DESIGN-STATE-2026-07.md`](./DESIGN-STATE-2026-07.md) — the July decision
  state. Superseded on colour and on the template split, kept as the record of
  what was open at the time.
- [`SITE-DEFINITION-2026-08.md`](./SITE-DEFINITION-2026-08.md) and
  [`SITE-CENSUS-2026-08.md`](./SITE-CENSUS-2026-08.md) — what the site is for,
  and what is on it.

## Why this file exists at all

Downstream references still link to `docs/WEBDESIGN.md`, so it remains as a
redirect. The previous contents are in git history.
