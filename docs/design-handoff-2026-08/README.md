# Handoff: ERN home page + national maps

## Overview

A rebuild of the Eviction Research Network home page (`evictionresearch.github.io`) in the house style established by the Washington state profile, replacing the legacy UpConstruction/Bootstrap hero and mixed-generation styling.

The page presents three things in order:

1. **Eviction data across the US** — an interactive coverage map of what eviction data exists in every state (the Eviction Data Atlas, under development)
2. **HPRM 2.0** — the national housing precarity risk map
3. **Our research** — three lead publications

Followed by a short "what we do" statement and a partner/collaboration CTA.

## About the design files

The files in this bundle are **design references created in HTML** — prototypes showing intended look and behavior, not production code to copy directly. The task is to recreate them in the target environment.

Two of them are exceptions worth noting: `us-coverage-map.html` and `us-hprm-map.html` are **working D3 implementations**, not mockups. Their geometry, projection, interaction, and color logic can be ported nearly as-is; only the *data* needs replacing (see "Data status" below). The `.dc.html` files are page-layout references — recreate their markup in the site's own templating (the live site is Jekyll/static HTML + CSS).

## Fidelity

**High-fidelity.** Final colors, typography, spacing, and interactions. Recreate pixel-accurately. Every value used is listed under "Design tokens."

---

## Data status — read before implementing

| Element | Status | What's needed |
|---|---|---|
| Coverage map state roster | **Real** — from `evictionresearch.github.io/code/us_state_map_urls.r`, roster of 2026-08-13 | Confirm the 8 red profile states are all actually published (CA was listed as in-progress; MD is Baltimore-only, OH is Dayton-only) |
| Coverage map per-state notes | **Written for the mock**, based on real profile facts | Replace with real per-state metadata (source name, geography, currency, link) from the Atlas dataset in `evictionresearch/library/data/eviction_data_atlas/` |
| HPRM map surface | **Synthetic** — illustrative speckle around ~115 real metro coordinates | Replace with real HPRM 2.0 tract scores. This is the single most important follow-up. |
| Research card copy | **Real** findings, condensed | Verify titles/venues against the publication list |
| Atlas counts ("200 sources", "50 states and D.C.") | **Real** — July 2026 census | Refresh date + counts on each rebuild |
| "Last updated August 2026" | Placeholder date | Wire to the Atlas dataset's actual build date |

The HPRM map carries a visible disclosure in its footnote: *"Design placeholder. The live model scores 83,500 census tracts; the neighborhood pattern here is illustrative, standing in until the tract layer is wired up."* **Do not remove that line until real tract data is in.**

---

## Screens / views

### Home page (single scrolling page)

Max content width **1240px**, centered, `padding: 0 40px` (20px below 900px).

#### 1. Header (sticky)

- `position: sticky; top: 0; z-index: 50`
- Background `rgba(255,255,255,0.94)`, `backdrop-filter: saturate(180%) blur(12px)`
- Bottom border `1px solid rgba(25,34,44,0.10)`
- Inner: `min-height: 84px`, `padding: 16px 40px`, flex, space-between
- Left: ERN banner logo, `height: 44px`
- Right nav: Maps & Profiles · HPRM · Research · About — `13px / 500`, color `#19222C`, hover `#CC2118`; then a Contact button — `12px / 600`, `letter-spacing: 0.06em`, uppercase, white on `#CC2118`, `padding: 10px 18px`, `radius: 4px`, hover `#B01D16`
- HPRM nav item links to `https://evictionresearch.net/hprm/`
- **Below 1000px** the nav wraps to a second row (`width: 100%`, `gap: 14px 18px`, font 12.5px) rather than hiding

#### 2. Atlas section

Two columns, `grid-template-columns: 0.85fr 1.6fr`, `gap: 56px`, `align-items: center`. Stacks to one column below 1000px. Section padding `64px 40px 56px`.

Left column:
- H1 "Eviction data across the **US.**" — Inter 200, 52px, `line-height: 1.05`, `letter-spacing: -0.026em`; "US." in weight 600 (`<em>` with `font-style: normal`)
- Subtitle — 18px, `line-height: 1.6`, `#223754`: "An atlas of eviction data across the US showing what's available."
- Status badge — inline-flex, 11.5px / 600, `letter-spacing: 0.12em`, uppercase, `#CC2118`, `1px solid rgba(204,33,24,0.4)`, `radius: 3px`, `padding: 6px 11px`: "Under development"
- Note — 14.5px, `#586573`: "We're still building this out — states and sources are being added as we verify them. Check back for more data."
- Meta line — 12.5px, `#586573`, `border-top: 1px solid rgba(25,34,44,0.10)`, `padding-top: 12px`: "Last updated **August 2026** · 200 sources across 50 states and D.C."
- Button "Preview the atlas →" — filled `#CC2118`, white, 13px / 600, uppercase, `letter-spacing: 0.06em`, `padding: 13px 24px`, `radius: 4px`, hover `#B01D16`

Right column: `us-coverage-map.html` in an iframe (see "Maps" below).

#### 3. HPRM section

Full-bleed band, background `rgba(232,238,244,0.45)`. Inner padding `56px 40px`.

- H2 "The Housing Precarity **Risk Model.**" — Inter 200, 40px, `letter-spacing: -0.024em`
- Subtitle — 17px, `#223754`, max 72ch: "HPRM 2.0 scores every neighborhood in the country for eviction risk and market displacement risk on one scale, designed on decades of gentrification, displacement, and housing precarity research."
- Map card — `<a href="https://evictionresearch.net/hprm/">` wrapping the iframe; white background, `1px solid rgba(25,34,44,0.10)`, `radius: 4px`, `padding: 20px 22px`; border becomes `#CC2118` on hover
- Button "Explore the model →" — filled `#CC2118`, `margin-top: 26px`, same button spec as above, links to the HPRM URL

#### 4. Research section

White ground, padding `64px 40px`.

- H2 "Our **research.**" — Inter 200, 40px
- Three cards, `grid-template-columns: 1fr 1fr 1fr`, `gap: 36px`; single column below 900px. Each card is a link with no border or background:
  - Kicker — 11px / 600, `letter-spacing: 0.14em`, uppercase, `#CC2118` ("Working paper · 2026" / "State profile · 2026" / "Cityscape (HUD) · 2024")
  - Title — 20px / 600, `line-height: 1.35`, `#19222C`
  - Body — 14.5px, `line-height: 1.6`, `#223754`
  - "Read more →" — 12px / 600, uppercase, `letter-spacing: 0.05em`, `#CC2118`
- Button "All research →" — ghost: transparent, `1.5px solid #19222C`, `#19222C` text; fills navy with white text on hover; `margin-top: 36px`

Card copy is in the DC file; carry it over verbatim.

#### 5. Mission

Tint band `rgba(232,238,244,0.45)`, padding `56px 40px`.

- Eyebrow "Research for social good" — 11px / 800, `letter-spacing: 0.28em`, uppercase, `#CC2118`
- H2 "What we **do.**" — Inter 200, 40px
- Two paragraphs, 16.5px, `line-height: 1.7`, `#223754`, max 72ch — the client-supplied ERN description, verbatim. Do not rewrite.

#### 6. Partner CTA

Navy `#19222C`, padding `56px 40px`, flex row with wrap, space-between.

- Eyebrow "Partner with ERN" — 11px / 800, `letter-spacing: 0.28em`, uppercase, `#ff706a`
- H2 "Working on eviction where the data is thin?" — Inter 200, 36px, white
- Body 15.5px, `rgba(255,255,255,0.86)`
- Primary "Start a conversation →" (`mailto:evictions@berkeley.edu`) — filled `#CC2118`, hover `#B01D16`
- Secondary "See our impact →" — transparent, `1.5px solid rgba(255,255,255,0.5)`, white; inverts to white background / navy text on hover

#### 7. Footer

Navy `#19222C`, `border-top: 1px solid rgba(255,255,255,0.15)`, padding `44px 40px`.

- Column 1: reversed ERN logo (40px), then two paragraphs at 13px / 12.5px in `#8BA3BE` — the affiliation statement and collaborator list
- Columns 2–4: Data / Research / Contact link groups. Group headers 11px / 700, `letter-spacing: 0.1em`, uppercase, `#8BA3BE`; links 13.5px white, hover `#ff706a`
- Bottom bar: `border-top: 1px solid rgba(255,255,255,0.15)`, `padding: 18px 40px`, 12px `#8BA3BE`, copyright left / "Accessibility · Privacy" right

**Affiliation wording is canonical** — from `evictionresearch/library/ORG.md`. Do not paraphrase: "A research program led by Dr. Tim Thomas in the UC Berkeley Department of Sociology, its academic home. Affiliated with the Berkeley Institute for Data Science." Never write "housed in." IGS, CDSS, and UDP are **not** current affiliations; UDP appears only in the collaborator line.

---

## Maps

Both maps are standalone HTML documents embedded via iframe. They are self-contained: D3 7.9.0 + topojson-client 3.1.0 from unpkg (with SRI hashes), geometry from `us-atlas@3.0.1` on jsDelivr, Inter from Google Fonts.

### Iframe embedding contract

This is load-bearing — it went through several failed iterations. The pattern that works:

```html
<iframe src="us-coverage-map.html" scrolling="no"
        width="100%" height="800"
        style="display:block; width:100%; max-width:100%; height:800px; border:none; overflow:hidden;">
</iframe>
```

- **No `aspect-ratio`** on the iframe. With an explicit pixel height set by JS, an active `aspect-ratio` derives *width* from height and blows the frame past its container.
- Width is pinned by both the HTML `width="100%"` attribute and CSS `max-width:100%`, so it survives even if an inline style declaration is dropped.
- Each map posts its measured height to the parent; the parent resizes the frame:

```js
// child (in each map file)
function postH() {
  var h = Math.ceil(document.body.getBoundingClientRect().height);
  parent.postMessage({ ernMap: 'us-coverage-map.html', h: h }, '*');
}
if (window.ResizeObserver) new ResizeObserver(postH).observe(document.documentElement);
window.addEventListener('resize', postH);
window.addEventListener('load', postH);
setTimeout(postH, 400); setTimeout(postH, 1600);

// parent
window.addEventListener('message', function (e) {
  var d = e && e.data;
  if (!d || !d.ernMap || !d.h) return;
  document.querySelectorAll('iframe[src]').forEach(function (f) {
    if (f.getAttribute('src').indexOf(d.ernMap) !== 0) return;
    f.style.aspectRatio = 'auto';
    f.style.width = '100%';
    f.style.height = (d.h + 4) + 'px';
  });
});
```

Notes: measure `document.body.getBoundingClientRect().height`, **not** `documentElement.scrollHeight` — the latter is floored by the iframe viewport, so the frame can only ratchet larger and never shrink. Observe `documentElement`, and also listen for `resize`; a `ResizeObserver` on `body` does not fire for width-only changes in this nesting.

If the site prefers no iframes, inline both scripts and skip the whole handshake — the height problem only exists because of the iframe.

### `us-coverage-map.html` — eviction data coverage

- Projection `d3.geoAlbersUsa().fitSize([975, 610], states)`, `states-10m.json`
- Fills: ERN profile states `#F9322B`; states with public data elsewhere `#223754`; no public data `#ffffff` with `#b7c2cd` stroke. All other strokes white, 1px.
- Roster (FIPS): profiles `53 41 06 27 18 39 24 10` (WA OR CA MN IN OH MD DE); no data `01 19 20 28 46` (AL IA KS MS SD); everything else navy
- Interaction: hover tooltip (dark navy chip, follows cursor), click selects and fills a readout panel below the map (state name 19px/600, status note 13px, contextual link). States are `tabindex="0"` with `role="button"` and `aria-label`, and respond to Enter/Space and focus.
- A "Find your state" `<select>` mirrors the map. **It is filtered to features that actually render** (`path(d)` non-null) — `states-10m` includes five territories that `geoAlbersUsa` drops; unfiltered they produce dead options and inherit a false "data linked" status.
- Legend above the map; readout panel below, separated by a hairline.

### `us-hprm-map.html` — HPRM 2.0 risk surface

- Same projection and size. Land is filled `#f4f6f9`; everything is clipped to a `topojson.merge` of all states so no speckle lands in the ocean.
- Color ramp (`d3.scaleLinear`, domain `[0, 2, 3.6, 5, 6.2, 7.2, 8]`, clamped):
  `#dbe4ee → #8BA3BE → #4d688c → #223754 → #8f2a2a → #CC2118 → #F9322B`
- **Synthetic surface:** ~115 real metro coordinates (name, state, lat, lon, weight) each seed a deterministic Gaussian scatter of small rects — count `30 + weight*520`, sigma `5 + weight*34`, score falling off with distance from center — plus 2,600 low-value rural marks. Seeded PRNG (mulberry32), so it renders identically every load.
- Interaction: a transparent hit rect over the map finds the nearest metro; within its radius it draws a navy halo ring and shows the metro name ("Los Angeles, CA"). Click anywhere calls `window.open('https://evictionresearch.net/hprm/', '_top')`.
- **Replacing with real data:** swap the generated `pts` arrays for tract geometry (GeoJSON or vector tiles), keep the ramp, and change the hover lookup from nearest-metro to feature-under-cursor. Everything else — projection, clipping, state mesh overlay, resize handshake, click-through — stays. At 83,500 tracts, consider canvas rendering or PMTiles + MapLibre instead of SVG.

---

## Interactions & behavior

- Smooth in-page anchor scrolling; section anchors use `scroll-margin-top: 100px` to clear the sticky header
- Link hover: `#CC2118 → #B01D16`. Nav hover: `#19222C → #CC2118`
- Filled buttons darken on hover; ghost buttons fill solid
- Research cards are whole-card links
- Map card border goes red on hover
- No entrance animations, no parallax, no carousel

## Responsive behavior

| Breakpoint | Change |
|---|---|
| ≤ 1000px | Header nav wraps to a second row; atlas section stacks to one column |
| ≤ 900px | Page padding 40px → 20px; H1 52px → 36px; research grid to one column |

Maps are fluid at every width via the height handshake.

## State management

Almost none — this is a static page. The only stateful pieces are inside the maps: coverage map holds a `selected` state FIPS (drives the readout panel and the `.sel` stroke, kept in sync with the `<select>`), and the HPRM map holds a transient hovered-metro index.

---

## Design tokens

### Color

| Token | Hex | Use |
|---|---|---|
| Brand red | `#F9322B` | Graphics only — map fills, rules, display-size type. **Never** body text or small UI. |
| Accent deep | `#CC2118` | Every readable red: links, kickers, buttons, badges. AA at 5.5:1 on white. |
| Accent press | `#B01D16` | Hover/press on red |
| Ink | `#19222C` | Headings, dark grounds, footer, nav |
| Body navy | `#223754` | Body copy, secondary map fill |
| Muted | `#586573` | Captions, metadata. AA at 6.0:1. |
| Steel | `#8BA3BE` | Muted text **on dark only**; mid-ramp fill |
| Tint | `rgba(232,238,244,0.45)` | Alternating section bands |
| Red on dark | `#ff706a` | Eyebrows and link hover on navy |
| Hairline (light) | `rgba(25,34,44,0.10)` | Borders, rules |
| Hairline (dark) | `rgba(255,255,255,0.15)` | Borders on navy |

The `#F9322B` / `#CC2118` split is a WCAG requirement, not a preference — brand red fails AA at body sizes. Berkeley's full-AA deadline is April 26, 2027.

### Type

Inter only, weights 200/400/500/600/700/800, `font-feature-settings: 'ss01','cv11'`.

| Role | Spec |
|---|---|
| H1 | 200, 52px, `line-height: 1.05`, `letter-spacing: -0.026em` |
| H2 | 200, 40px, `line-height: 1.06`, `letter-spacing: -0.024em` |
| H2 (on navy) | 200, 36px, `letter-spacing: -0.022em` |
| Card title | 600, 20px, `line-height: 1.35` |
| Lede | 400, 18px, `line-height: 1.6` |
| Body | 400, 16–16.5px, `line-height: 1.65–1.7` |
| Small body | 400, 14.5px, `line-height: 1.6` |
| Meta | 400, 12.5–13px |
| Kicker | 600, 11px, `letter-spacing: 0.14em`, uppercase |
| Eyebrow | 800, 11px, `letter-spacing: 0.28em`, uppercase |
| Button | 600, 13px, `letter-spacing: 0.06em`, uppercase |
| Nav | 500, 13px |

Emphasis pattern used throughout: `<em style="font-style: normal; font-weight: 600">` on the last word or phrase of a hairline heading. Numerals use `font-variant-numeric: tabular-nums`.

Note: the attached design system documents an older Open Sans + Roboto era. This page follows the newer Inter-only spec from the source repos, which is what has been approved.

### Spacing, radius, shadow

- Content max-width 1240px; section padding `56–64px` vertical, `40px` horizontal
- Radii: 4px buttons and cards, 3px badges, 2px plate frames. No pills.
- Borders 1px hairline; 1.5px on buttons and plate frames
- Shadows: none on this page

## Assets

- `assets/ern/banner-1A.png` — horizontal logo, light backgrounds, 44px tall
- `assets/ern/banner-1A-rev.png` — reversed, footer, 40px tall

Both from `cidrlab/library/brand/logos/ern_logo/`. No icon font — the only glyph used is the `→` character in links and buttons.

## Files

| File | What it is |
|---|---|
| `ERN Home Page.dc.html` | The approved home page — layout, copy, all styling inline |
| `us-coverage-map.html` | Working D3 coverage map (real roster) |
| `us-hprm-map.html` | Working D3 HPRM map (synthetic surface) |
| `ERN Home Page v5 plates.dc.html` | Alternate direction — Du Bois plate treatment with the four P's, "what works" section, and appendices. Client liked it; parked for a later page. |
| `ERN Design Review.dc.html` | Full design-review canvas: the three-generation comparison, Eviction Lab collision check, and all magazine directions with annotations |

The `.dc.html` files open directly in a browser. Styling is inline by construction — extract to the site's stylesheet when porting.

---

## Suggested next steps

1. Port the home page into the site repo, retiring the UpConstruction hero and the legacy `main.css` dependency for this page
2. Patch `v5b.css` and `hud-era.css`: add `--accent-deep: #CC2118` / `--accent-deeper: #B01D16` (replacing `#D6231C`), repoint kickers/buttons/links, swap `--muted: #6c7a89 → #586573`, underline in-content prose links
3. Wire the coverage map to the real Atlas dataset (per-state source, geography, currency, URL)
4. Replace the HPRM surface with real tract scores and remove the placeholder disclosure
5. Build the Atlas page behind "Preview the atlas →" (the plate/register treatments in the review canvas are the reference)
6. Reconcile the profile roster — the map claims 8 states; confirm which are actually published before launch
