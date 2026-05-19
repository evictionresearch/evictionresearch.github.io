# The Eviction Research Network

URL: [evictionresearch.net](https://evictionresearch.net)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10642019.svg)](https://doi.org/10.5281/zenodo.10642019)

ERN is the academic arm of the [CiDR Lab](https://cidrlab.org/), housed in UC Berkeley's Department of Sociology. This repository serves [evictionresearch.net](https://evictionresearch.net) as a static GitHub Pages site.

## Branding

Brand colors, typography, and logo assets are maintained centrally in the CiDR Lab library:

- **CiDR Lab + ERN brand library:** https://github.com/cidrlab/library
- **ERN brand guide:** https://github.com/cidrlab/library/blob/main/brand/ern/BRAND.md
- **Master brand guide:** https://github.com/cidrlab/library/blob/main/BRAND.md
- **Semantic color extension** (category tags, breadcrumb types): https://github.com/cidrlab/library/blob/main/brand/semantic-palette.md
- **Logo assets:** https://github.com/cidrlab/library/tree/main/brand/logos/ern_logo

Do not introduce local color or font overrides. If a project needs a semantic color not in the brand, extend `semantic-palette.md` in the library, not the site CSS.

### Deployed logo path

The site references ERN logos from `images/ern_logo/` (mirror of `library/brand/logos/ern_logo/`). The historical `assets/ern_logo/` and `assetsx/ern_logo/` paths are deprecated and have been removed.

## Web Design Strategy

### New state-pipeline websites

State-pipeline repos under `~/git/evictionresearch/` (washington, california, oregon, etc.) follow a shared design template:

1. Map
2. Counts over time (stacked area graph if more than one place)
3. Historical average during pandemic
4. One-year rates by time period (if multiple counties)
5. Rates by race — side-by-side bar graph
6. Ratio of race / white
7. Landlord-level patterns
8. Neighborhood trends
9. Model outputs (e.g., top predictors)

### Page-level design conventions

Site-wide structural patterns (header, footer, scroll behavior, Inter font, dual-logo footer, breadcrumb categories) are documented in [`docs/WEBDESIGN.md`](docs/WEBDESIGN.md).

## Repository structure

```
evictionresearch.github.io/
├── *.html                       # Top-level pages (index, about, methodology, research, ...)
├── assets/
│   ├── css/main.css             # Brand-aligned CSS variables (see library/BRAND.md)
│   ├── css/v5b.css              # v5b layer (hairline aesthetic, accent-deep)
│   ├── js/                      # Site JS
│   ├── vendor/                  # Bootstrap, FontAwesome, etc.
│   ├── img/                     # Favicon, hero photography
│   ├── data/                    # Embedded JSON used by pages
│   └── webfonts/                # FontAwesome webfont files
├── images/
│   ├── ern_logo/                # Deployed ERN logo (sync from library)
│   └── logos/                   # Berkeley wordmark, partner marks used inline
├── partner_logos/               # Partner organization logos
├── maps/                        # Embeddable map pages
├── code/                        # R scripts used to build map embeds
├── data/                        # Reference data (redlining, test maps)
└── docs/WEBDESIGN.md            # Page-level design conventions
```

## Branches

| Branch | Purpose |
|---|---|
| `main` | Deployed GitHub Pages site |
| `brand/v5b` | Current working line (matches main at HEAD) |
| `brand/library-consolidation` | Brand sweep PR — see [companion library PR](https://github.com/cidrlab/library) |
