# Eviction Research Network -- Web Design Architecture

> Site: [evictionresearch.net](https://evictionresearch.net)
> Repository: `evictionresearch.github.io`
> Last updated: February 2026

---

## Template & Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Template | [HTML5 UP Spectral](https://html5up.net/spectral) | CCA 3.0 licensed; customized by Tim Thomas & Danny Rothschild |
| CSS preprocessor | SASS (`.scss`) | Source in `assets/sass/`, compiled to `assets/css/main.css` |
| CSS framework | Custom (Spectral) | Flexbox-based layout, no Bootstrap dependency |
| JavaScript | jQuery + plugins | `jquery.scrollex`, `jquery.scrolly`, `breakpoints`, `browser`, `util` |
| Icons | Font Awesome 5 | Loaded via `fontawesome-all.min.css` |
| Typography | Open Sans (Google Fonts) | Weights: 400 (normal), 600 (bold), 800 (extrabold) |
| Analytics | Google Tag Manager + gtag | GTM-PGPM9JT, G-8J4LNG1PPR |
| Hosting | GitHub Pages | Static HTML, no build step required |

---

## Page Inventory

| File | Route | Layout Type | Description |
|------|-------|-------------|-------------|
| `index.html` | `/` | Landing (`body.landing`) | Full-width hero + spotlights + team + CTA |
| `methodology.html` | `/methodology.html` | Article | Data collection methodology documentation |
| `resources.html` | `/resources.html` | Article | Eviction help resources for tenants |
| `research.html` | `/research.html` | Article | Links to other eviction research |
| `news.html` | `/news.html` | Article | News and media coverage |
| `maps.html` | `/maps.html` | Article | Interactive maps page |
| `maps/us_map.html` | `/maps/us_map.html` | Embedded iframe | US map visualization (embedded in index.html) |

---

## Landing Page Anatomy (`index.html`)

The landing page follows a vertical scroll narrative composed of numbered sections, each wrapped in a distinct visual style.

```
+------------------------------------------+
|  #header (fixed, transparent on landing)  |
+------------------------------------------+
|  #banner (full-viewport hero)            |
|    - Stacked logo                        |
|    - University tagline                  |
|    - Blue Sky social link                |
|    - "Learn More" scroll indicator       |
+------------------------------------------+
|  #one .wrapper.style1.special            |
|    "Research for social good."           |
|    Mission statement paragraph           |
+------------------------------------------+
|  #two .wrapper.alt.style2               |
|    section.spotlight (HPRM model)        |
|    section.spotlight (State maps)        |
|    section.spotlight (Earlier work)      |
+------------------------------------------+
|  #three .wrapper.style3.special          |
|    UC Berkeley Team (photo grid)         |
|    Research Collaborators                |
|    Expert Collaborators                  |
|    Student Alumni                        |
|    Organizational Collaborators & Funders|
+------------------------------------------+
|  #cta .wrapper.style4                    |
|    "Want to collaborate?" + email CTA    |
+------------------------------------------+
|  #footer                                 |
|    Social icons + copyright              |
+------------------------------------------+
```

### Section Details

#### Header (`#header.alt`)

- **Position**: Fixed at top, `3em` height
- **Behavior on landing**: Transparent background (`.alt` class), becomes opaque on scroll via `scrollex`
- **Logo**: ERN banner logo (`EvictionStudy_logo_v09_1A_LOGO_BANNER_REV.png`, 300px wide)
- **Navigation**: Hamburger menu toggle (`.menuToggle`) opens a slide-out panel (`#menu`) from the right
- **Menu panel**: Teal (`accent1`) background, `20em` wide, slides in with CSS transition

#### Banner (`#banner`)

- **Layout**: Full viewport height, centered content, dark overlay on background image
- **Content**: Stacked version of logo (400px), university tagline, Blue Sky link, scroll-down arrow
- **Animation**: Content fades in on page load (controlled by `.is-preload` class removal)
- **Scroll indicator**: `.more.scrolly` link with down-arrow icon, smooth-scrolls to `#one`

#### Section One (`#one`) -- Mission Statement

- **Classes**: `.wrapper.style1.special`
- **Background**: Teal/accent1 (`#21b2a6`) with semi-transparent overlay
- **Layout**: Centered text within `.inner` container, `header.major` for heading
- **Content**: "Research for social good." heading + mission description paragraph

#### Section Two (`#two`) -- Spotlights

- **Classes**: `.wrapper.alt.style2`
- **Background**: Dark (`#19222C`)
- **Contains**: Three `section.spotlight` elements (see Spotlight Pattern below)

#### Section Three (`#three`) -- Team & Collaborators

- **Classes**: `.wrapper.style3.special`
- **Background**: Purple-blue (`accent5`, `#505393`)
- **Layout**: Multiple `header.major` blocks, each containing a `ul.features` grid
- **Subsections**:
  - UC Berkeley Team (photo grid with names, titles, affiliations)
  - Research Collaborators (same photo grid format)
  - Expert Collaborators (text list)
  - Student Alumni (text list)
  - Organizational Collaborators & Funders (`ul.icons` with logo images)

#### CTA Section (`#cta`)

- **Classes**: `.wrapper.style4`
- **Background**: Transparent (inherits page background gradient)
- **Layout**: Two-column flex -- header text on left, stacked action buttons on right
- **Content**: "Want to collaborate?" heading, description, email button (`.button.fit.primary`)

#### Footer (`#footer`)

- **Social icons**: Twitter, Email (`.icons` list with Font Awesome)
- **Copyright**: "2022 The Eviction Research Network"
- **Credits**: urbandisplacement.org, HTML5 UP, Danny Rothschild

---

## The Spotlight Pattern

The spotlight is the signature content layout of this site -- alternating image+text blocks that create visual rhythm while presenting key research areas.

### HTML Structure

```html
<section id="two" class="wrapper alt style2">

  <section class="spotlight">
    <div class="image">
      <img src="images/example.png" alt="..." />
    </div>
    <div class="content">
      <h2>Title</h2>
      <p>Description text...</p>
    </div>
  </section>

  <section class="spotlight">
    <!-- Same structure; CSS reverses the layout for even items -->
  </section>

</section>
```

### CSS Behavior

| Property | Value | Notes |
|----------|-------|-------|
| Display | `display: flex` | Horizontal layout at desktop |
| Image width | 40% of container | Fixed ratio via flex-basis |
| Content width | 60% of container | Remaining flex space |
| Image order | `order: 1` (odd), reversed for even | `:nth-child(2n)` sets `flex-direction: row-reverse` |
| Content padding | `2em 4em 0.1em 4em` | Generous horizontal padding |
| Background | Progressive darkening | Each spotlight: `rgba(0,0,0, 0.075 * n)` where n = child index |
| Responsive | Stacks vertically | Below `medium` breakpoint (980px), image sits above content |

### Progressive Background Darkening

Each spotlight gets slightly darker than the one above it, creating a visual "deepening" effect as the user scrolls:

- Spotlight 1: `rgba(0, 0, 0, 0.075)`
- Spotlight 2: `rgba(0, 0, 0, 0.150)`
- Spotlight 3: `rgba(0, 0, 0, 0.225)`

### Current Spotlight Content

1. **National Housing Precarity Risk Model (HPRM)** -- Bay Area map image linking to HPRM tool, with description of the risk model
2. **State Eviction Maps & Profiles** -- Embedded US map iframe, with links to California, Delaware, Indiana, Minnesota, Ohio, Oregon, Washington
3. **Earlier Work & Reports** -- MLK mural photo, with links to Dayton, Bay Area, Baltimore, and Washington State research

---

## Wrapper Style System

The Spectral template uses numbered `.wrapper.styleN` classes to create distinct visual sections with different background colors.

| Class | Background | Used For |
|-------|-----------|----------|
| `.wrapper.style1` | Teal (`#21b2a6` / accent1) | Mission statement section |
| `.wrapper.style2` | Dark charcoal (`#19222C`) | Spotlight container |
| `.wrapper.style3` | Purple-blue (`#505393` / accent5) | Team & collaborators |
| `.wrapper.style4` | Transparent (inherits gradient) | CTA section |
| `.wrapper.style5` | White (`#ffffff` / accent7) | Content pages (articles) |
| `.wrapper.alt` | Modifier that darkens backgrounds | Combined with style2 for spotlights |
| `.wrapper.special` | Centers all child text | Used with style1, style3 |

---

## Color Palette

Source: `assets/sass/libs/_vars.scss`

| Name | Hex | Usage |
|------|-----|-------|
| Background | `#2e3842` | Page background, header |
| Foreground | `#ffffff` | Body text (white-on-dark) |
| accent1 | `#21b2a6` | Teal -- style1 wrapper, menu panel, links |
| accent2 | `#00ffcc` | Cyan -- feature icons |
| accent3 | `#00f0ff` | Bright cyan -- hover states |
| accent4 | `#76ddff` | Light blue -- secondary elements |
| accent5 | `#505393` | Purple-blue -- style3 wrapper |
| accent6 | `#ed4933` | Red -- primary buttons, CTA |
| accent7 | `#ffffff` | White -- style5 wrapper (content pages) |

---

## Typography

| Property | Value |
|----------|-------|
| Font family | `'Open Sans', Helvetica, sans-serif` |
| Base size | `15pt` (xlarge), `13pt` (large), `12pt` (medium), `11pt` (small) |
| Body weight | 400 (normal) |
| Bold weight | 600 |
| Heading weight | 800 (extrabold) |
| Letter spacing (body) | `0.075em` |
| Letter spacing (headings) | `0.225em` |
| Text transform (headings) | `uppercase` |
| Line height | `1.65` |

---

## Responsive Breakpoints

Source: `assets/sass/libs/_vars.scss` and `main.js`

| Name | Range | Key Changes |
|------|-------|-------------|
| xlarge | 1281px -- 1680px | Base layout |
| large | 981px -- 1280px | Reduced font size (13pt) |
| medium | 737px -- 980px | Spotlights stack vertically, hamburger menu, font 12pt |
| small | 481px -- 736px | Compact spacing, font 11pt |
| xsmall | 0 -- 480px | Minimal padding, single-column |

---

## JavaScript Behavior

Scripts loaded in order at page bottom (render-blocking, traditional approach):

1. **jQuery** (`jquery.min.js`) -- DOM manipulation foundation
2. **Scrollex** (`jquery.scrollex.min.js`) -- Scroll-position event triggers
3. **Scrolly** (`jquery.scrolly.min.js`) -- Smooth scroll for anchor links (`.scrolly` class)
4. **Browser** (`browser.min.js`) -- Browser and OS detection
5. **Breakpoints** (`breakpoints.min.js`) -- Responsive breakpoint event system
6. **Util** (`util.js`) -- Template utility functions
7. **Main** (`main.js`) -- Site-specific initialization

### Key Behaviors

- **Preload animation**: `body.is-preload` class removed after 100ms, triggering CSS fade-in transitions
- **Mobile detection**: `body.is-mobile` class added when breakpoint <= medium or touch device detected
- **Smooth scrolling**: Elements with `.scrolly` class smooth-scroll to their `href` target with configurable offset
- **Menu panel**: Right-side slide-out panel with 500ms animation, closes on click/swipe
- **Header transparency**: On landing pages, `#header.alt` class is removed when the banner section scrolls out of viewport (via `scrollex`), making the header opaque
- **Iframe resizing**: Custom `resizeIframe()` function adjusts embedded map iframe height to match content

---

## Content Page Layout

Non-landing pages (`methodology.html`, `resources.html`, `research.html`, `news.html`) share a consistent article layout:

```
+------------------------------------------+
|  #header (fixed, opaque -- no .alt class) |
+------------------------------------------+
|  article#main                            |
|    header (page title banner)            |
|    .wrapper.style5 (white background)    |
|      .inner (max-width content area)     |
|        Page content...                   |
+------------------------------------------+
|  #footer                                 |
+------------------------------------------+
```

- **Body class**: `is-preload` (no `.landing` class -- shorter header padding)
- **Header**: Opaque (no `.alt` modifier), same nav structure
- **Content wrapper**: `.wrapper.style5` provides a white background with dark text for readability
- **Inner container**: Max-width constrained content area with comfortable reading width

---

## Directory Structure

```
evictionresearch.github.io/
├── index.html                 # Landing page
├── methodology.html           # Methodology article
├── resources.html             # Eviction help article
├── research.html              # Other research article
├── news.html                  # News article
├── maps.html                  # Maps page
├── maps/
│   └── us_map.html            # Embedded US map
├── assets/
│   ├── css/
│   │   ├── main.css           # Compiled stylesheet (~4000 lines)
│   │   ├── noscript.css       # No-JS fallback styles
│   │   ├── fontawesome-all.min.css
│   │   └── images/            # CSS background SVGs (arrow, bars, close)
│   ├── js/
│   │   ├── jquery.min.js
│   │   ├── jquery.scrollex.min.js
│   │   ├── jquery.scrolly.min.js
│   │   ├── browser.min.js
│   │   ├── breakpoints.min.js
│   │   ├── util.js
│   │   └── main.js
│   ├── sass/
│   │   ├── main.scss          # SASS entry point
│   │   └── libs/
│   │       ├── _vars.scss     # Color palette, font, size variables
│   │       ├── _functions.scss
│   │       ├── _mixins.scss
│   │       ├── _breakpoints.scss
│   │       ├── _html-grid.scss
│   │       └── _vendor.scss
│   ├── webfonts/              # Font Awesome webfont files
│   └── ern_logo/              # Logo variations (banner, stacked, square)
├── images/                    # Content images (maps, photos, logos)
│   ├── photos/                # Team member headshots
│   └── logos/                 # Partner/funder organization logos
├── archive/                   # Archived assets
├── code/                      # Analysis code
├── data/                      # Data files
├── html5up-spectral/          # Original unmodified template
├── html5up-spectral.zip       # Template download archive
├── CNAME                      # Custom domain: evictionresearch.net
├── LICENSE.txt                # CCA 3.0 license
└── README.md
```

---

## Design Vocabulary Reference

| Term | Meaning in This Site |
|------|---------------------|
| **Wrapper** | A full-width section container with a colored background (`.wrapper.styleN`) |
| **Spotlight** | An alternating image+content card within the `.style2` wrapper |
| **Banner** | The full-viewport hero section with logo and tagline |
| **Panel** | The slide-out navigation menu from the right edge |
| **Features** | A grid list of items (team photos, capabilities) using `ul.features` |
| **Icons** | A horizontal list of linked images/icons using `ul.icons` |
| **Special** | A wrapper modifier that centers all child text |
| **Alt** | A wrapper modifier that applies a darker variant of the style |
| **Major** | A header modifier (`header.major`) that adds extra spacing and decorative lines |
| **Scrolly** | A class that enables smooth-scroll behavior on anchor links |
| **Inner** | The max-width content container inside a wrapper (`.inner`) |
