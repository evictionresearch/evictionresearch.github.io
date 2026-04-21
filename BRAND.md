# Eviction Research Network — Brand Style Guide

This document defines the canonical brand colors, typography, and usage guidelines for the
Eviction Research Network (ERN) website and affiliated projects. Keep in sync with
[`cidrlab.github.io/BRAND.md`](https://github.com/cidrlab/cidrlab.github.io/blob/main/BRAND.md).

---

## Colors

| Role | Hex | CSS Variable | Usage |
|---|---|---|---|
| Accent red | `#F9322B` | `--accent-color` | Buttons, links, highlights, borders, icon accents |
| Dark navy | `#19222C` | `--heading-color` | Page headings, header/footer backgrounds, dark surfaces |
| Medium blue | `#223754` | `--default-color` | Body text, secondary headings, nav surfaces |
| Light blue | `#e8eef4` | `--background-color` (`.light-background`) | Alternating section backgrounds |
| White | `#ffffff` | `--background-color`, `--surface-color` | Default page background, cards |

### Notes
- The accent red `#F9322B` is the canonical value. Earlier ERN templates used `#ee3029` — **do not use the old value**.
- The dark navy `#19222C` is used for `.dark-background` elements (header, footer). Earlier templates used `#364d59` for default text — **do not use the old value**.
- The light blue `#e8eef4` is a cool tint derived from the medium blue, used to visually distinguish alternating content sections without clashing with the red accent.

---

## Typography

| Role | Font | CSS Variable |
|---|---|---|
| Body / default | Open Sans | `--default-font` |
| Headings, navigation, labels, pills | Roboto | `--heading-font`, `--nav-font` |

All fonts loaded via Google Fonts CDN.

> **2026-04-20:** Poppins dropped from ERN stack (was `--nav-font`). Roboto now drives nav/labels in addition to headings. Rationale: one fewer render-blocking font family for PageSpeed. CiDR Lab is separately on Poppins-only — no web-font overlap between the two brands.

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

In `assets/css/main.css`:

```css
:root {
  --default-font:   "Open Sans", system-ui, sans-serif;
  --heading-font:   "Roboto", sans-serif;
  --nav-font:       "Poppins", sans-serif;

  --background-color: #ffffff;
  --default-color:    #223754;   /* medium blue */
  --heading-color:    #19222C;   /* dark navy   */
  --accent-color:     #F9322B;   /* accent red  */
  --surface-color:    #ffffff;
  --contrast-color:   #ffffff;
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
