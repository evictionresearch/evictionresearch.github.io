# Eviction Research Network — Brand Style Guide

This document defines the canonical brand colors, typography, and usage guidelines for the
Eviction Research Network (ERN) website and affiliated projects. Keep in sync with
[`cidrlab.github.io/BRAND.md`](https://github.com/cidrlab/cidrlab.github.io/blob/main/BRAND.md).

---

## Colors

| Role | Hex | CSS Variable | Usage |
|---|---|---|---|
| Accent red — **graphics** | `#F9322B` | `--accent-color` / `--accent` | **Decorative graphics only** (map fills, markers, washes). Fails WCAG AA as small text (3.8:1) — never use for text, links, or button labels. |
| Accent red — **text / UI** | `#CC2118` | `--accent-deep` | Links, buttons, kickers, labels. Contrast-safe (5.5:1 white, 4.7:1 tint). Default red for anything readable. |
| Accent red — hover | `#B01D16` | `--accent-deeper` | Hover / active for red text and buttons. |
| Dark navy | `#19222C` | `--heading-color` | Page headings, header/footer backgrounds, dark surfaces |
| Medium blue | `#223754` | `--default-color` | Body text, secondary headings, nav surfaces |
| Muted slate | `#586573` | `--muted` | Secondary / caption text on light bg (6.0:1 white, 5.1:1 tint). Replaces `#6c7a89` (failed AA). |
| Light blue | `#e8eef4` | `--background-color` (`.light-background`) | Alternating section backgrounds |
| White | `#ffffff` | `--background-color`, `--surface-color` | Default page background, cards |

### Notes
- **Accessibility (WCAG 2.1 AA / Berkeley).** The brand red splits by use: `#F9322B` for *graphics only*; **`#CC2118` (`--accent-deep`) for all text, links, and buttons** (the bright red fails contrast as text at 3.8:1). Muted text is `#586573`, not `#6c7a89`. In-content links are underlined (1.4.1); no heading-level skips (1.3.1); shared-text card CTAs get a unique `aria-label`. Full rules + rationale: canonical guide → [`cidrlab/library/brand/ern/BRAND.md`](https://github.com/cidrlab/library/blob/main/brand/ern/BRAND.md) (Accessibility section).
- The accent red `#F9322B` is canonical **for graphics**. Earlier ERN templates used `#ee3029` — **do not use the old value**.
- The dark navy `#19222C` is used for `.dark-background` elements (header, footer). Earlier templates used `#364d59` for default text — **do not use the old value**.
- The light blue `#e8eef4` is a cool tint derived from the medium blue, used to visually distinguish alternating content sections without clashing with the red accent.
- **Deprecated:** `#6c7a89` (old muted, fails AA) → `#586573`; `#F9322B` *as text* → `#CC2118`.

---

## Typography

| Role | Font | CSS Variable |
|---|---|---|
| Body, headings, navigation, labels, pills | **Inter** | `--sans` (canonical); `--display` aliases to same |

All fonts loaded via Google Fonts CDN. Inter renders identically across Apple, PC, Linux, iOS, and Android because the browser fetches the same `.woff2` file regardless of OS.

### Weights in use
- **200 (Extra Light)** — major display headlines (h1, h2.section-title) — the hairline aesthetic
- **400 (Regular)** — body copy
- **500 (Medium)** — kickers, navigation, scope pills
- **600 (Semi Bold)** — buttons, paper-card readmore, em emphasis
- **700 (Bold)** — paper-card titles, strong emphasis, footer h4s

### OpenType features
Inter ships designed alternates that are part of its visual signature:

- `ss01` — single-storey "a" (more modern, geometric)
- `cv11` — curved style alternates

Apply via `font-feature-settings: "ss01", "cv11";` on `body` so the whole site picks them up.

> **2026-04-29:** Switched to Inter as the single brand family. Replaced the prior Open Sans (body) + Roboto (headings) stack. Rationale:
> 1. **Differentiation.** Eviction Lab and similar civic-data orgs lean on data-journalism fonts (Roboto, Helvetica-flavored families). Inter pulls ERN into the design-forward technical register (Vercel, Stripe, Figma, GitHub) — a meaningful brand pivot away from the EL collision space.
> 2. **One family.** Inter alone replaces two prior families, lowering render-blocking weight while expanding the available weight axis (true 200 Extra Light is not available in Open Sans).
> 3. **Hairline aesthetic.** Inter 200 is a real designed weight; Open Sans floors at 300, Roboto skips from 500 to 700. The v5b prototype hairline look originated as Inter 200 — switching back makes that aesthetic native rather than approximated.
> 4. **Cross-platform parity.** Loaded as a Google webfont, Inter renders identically on every platform.
>
> **2026-04-20:** (historical) Poppins dropped from ERN stack; Open Sans + Roboto adopted. Superseded by the 2026-04-29 Inter switch.

CiDR Lab remains on Poppins separately — the two brands do not share a webfont family.

---

## Logos

Logo files live in `assets/ern_logo/`. Use the appropriate variant:

| File | Usage |
|---|---|
| `1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER_REV.png` | Header (dark background) — horizontal banner, reversed/white |
| `1A/EvictionStudy_logo_v09_1A_LOGO_STACK_REV.png` | Footer (dark background) — stacked, reversed/white |
| `1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER.png` | Header (light background) — horizontal banner, standard |
| `1A/EvictionStudy_logo_v09_1A_LOGO_STACK.png` | Footer (light background) — stacked, standard |

Favicon: `https://evictionresearch.net/archive/png/ern_favicon.png`

---

## CSS Implementation

In `assets/css/main.css` and `assets/css/v5b.css`:

```css
:root {
  --sans:    "Inter", -apple-system, system-ui, "Helvetica Neue", Helvetica, Arial, sans-serif;
  --display: "Inter", -apple-system, system-ui, "Helvetica Neue", Helvetica, Arial, sans-serif;

  --background-color: #ffffff;
  --default-color:    #223754;   /* medium blue                       */
  --heading-color:    #19222C;   /* dark navy                         */
  --accent-color:     #F9322B;   /* accent red — GRAPHICS only        */
  --accent-deep:      #CC2118;   /* accent red — text/links/buttons (WCAG-safe) */
  --accent-deeper:    #B01D16;   /* accent red — hover/active         */
  --muted:            #586573;   /* secondary / caption text          */
  --surface-color:    #ffffff;
  --contrast-color:   #ffffff;
}

body {
  font-family: var(--sans);
  font-feature-settings: "ss01", "cv11";  /* Inter alternates */
}

.light-background {
  --background-color: #e8eef4;   /* light blue tint */
}

.dark-background {
  --background-color: #19222C;   /* dark navy */
  --default-color:    #ffffff;
  --heading-color:    #ffffff;
}
```

---

## Related Repos

- [`evictionresearch.github.io`](https://github.com/evictionresearch/evictionresearch.github.io) — ERN main site
- [`cidrlab.github.io`](https://github.com/cidrlab/cidrlab.github.io) — CiDR Lab site (shares brand colors)
- [`washington`](https://github.com/evictionresearch/washington) — reference implementation of UpConstruction template
- [`hud-era`](https://github.com/evictionresearch/hud-era) — ERA report page (`reports/index.html`)
