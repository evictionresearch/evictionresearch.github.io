# ERN Website — Design Decision State (July 16, 2026)

> Written to be the single pickup point for the design pass. Start here.
> Branch context: `reports-2026-07` is the **superset tip** — every other
> branch (main, qs-migration, all brand/*, style/dubois-revision,
> ern-glossary-probe) is fully merged into it (verified: 0 commits ahead each).
> PR #54 carries it against main. Design work should branch from here.

## Decided (settled — do not relitigate)

| Decision | Where recorded |
|---|---|
| Inter only, all weights; no display companion font (2026-04-29) | `BRAND.md`; canonical: `cidrlab/library/brand/ern/BRAND.md` |
| WCAG-split reds: `#F9322B` graphics-only, `#CC2118` text/links/buttons; muted `#586573`; navy `#19222C`; tint `#e8eef4` | `BRAND.md` |
| Du Bois lineage, "spirit not surface": claim-sentence titles, numbered **Figures** (renamed from "plates" 2026-06-28), interpretive descriptions; no cream/sepia/serif | `evictionresearch/library/dubois_lineage.md` |
| Front page = v5b design (May 12 "finalize webpage"); `data-header-style="plate"` | `index.html`, `assets/css/v5b.css` |
| WCAG 2.1 AA sitewide (Berkeley dap requirement) | `BRAND.md` accessibility notes |

## Open decisions (the actual design agenda)

1. **Berkeley affiliation fixes — INSTITUTIONAL, DO FIRST.**
   `AFFILIATION-BRAND-FIXES.md` (2026-05-21, Brand Protection Project #0946)
   is still **unapplied**: the canonical relationship statement ("a research
   program led by Dr. Tim Thomas… Department of Sociology… not a separate
   legal entity") appears nowhere on the site; the UC Berkeley logo placement
   and footer copyright still imply the wrong relationship. Verified absent
   from `about.html`/`index.html` on 2026-07-16.
2. **Prototype v6 — adopt, harvest, or retire.** `_prototype-v6/` ("Evidence
   that keeps pace with displacement." hero) post-dates v5b and has sat
   undecided since late April. Decide its fate; then delete the prototype
   directories either way (see #6).
3. **Two-template split.** `index.html` = UpConstruction/Bootstrap 5; content
   pages = legacy Spectral markup with v5b.css overlaid (per `docs/WEBDESIGN.md`,
   itself stale — Feb 2026). Unify on one system or explicitly bless the split.
4. **New-page patterns → house system?** `state-eviction-timeframes/` uses its
   own self-contained style with a header Contents/scroll-spy TOC and
   reading-progress bar; `understanding-eviction.html` got a nav Contents
   dropdown. Decide whether the TOC/progress pattern becomes standard for
   long pages (it came from cidrlab `hprm_sanmateo` reports).
5. **Nav information architecture.** Now: Home · About · Maps & Profiles ·
   News · Methodology · Reports (added 2026-07) · Resources · Contact.
   Sanity-check ordering and whether Maps & Profiles vs Reports split is right.
6. **Repo hygiene.** Dead weight: `_prototype-v1..v6/`, `html5up-spectral/`
   (+ .zip), `archive/`, `assetsx/`, `index.html.pre-v5b.bak`. Delete on the
   design branch (git history preserves them).
7. **`docs/WEBDESIGN.md` rewrite.** Stale (Feb 2026): predates v5b, about,
   glossary, understanding-eviction, cityscape-2024, state-eviction-timeframes.
   Rewrite after decisions 2–5 land.

## Page inventory & reachability (audited 2026-07-16, this branch)

17 internal pages. **All 11 content pages reachable from the home page**
(about, cityscape-2024, glossary, maps, methodology, news, research,
resources, state-eviction-timeframes/, understanding-eviction, index).
Six `maps/*.html` standalones (us_map, pre, post, last_year, dur, all) have
no inbound `href` — us_map is iframed into index; the rest are legacy embeds
(two were retitled 2026-07-14 after carrying wrong "Oregon" titles). Decide:
link, keep as embeds-only, or archive.

External profile links on home (all to evictionresearch.net subpaths, separate
repos): california, delaware, indiana, maryland/report/baltimore, minnesota,
ohio/dayton, oregon, washington, hprm, hprm/bay, hud-era.

## Recent context (July 2026, PR #54 + library #133)

State Eviction Timeframes page (verified statutory clocks) + merged
Understanding Eviction (primer + research treatment, all claims verified);
Reports nav sitewide; canonicals added to 8 pages; Cityscape ch12 mis-citation
fixed in 4 places; verification evidence in `docs/verification-2026-07/`.
Washington 673k fix on `washington#32`. Issue library#111 ready to close on
#133 merge.

## Suggested sequence for the design branch

1. Branch `design-2026-08` (or similar) off `reports-2026-07`.
2. Apply AFFILIATION-BRAND-FIXES.md verbatim (about, footer, meta) — ships
   independently of aesthetics.
3. v6 verdict → template-split verdict → TOC-pattern verdict (each small PR
   or one series).
4. Repo hygiene deletions.
5. Rewrite WEBDESIGN.md to match reality; retire this file into it.
