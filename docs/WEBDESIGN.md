# Eviction Research Network -- Web Design Architecture

> Site: [evictionresearch.net](https://evictionresearch.net)
> Repository: `evictionresearch.github.io`
> Last updated: February 2026

---

## Template & Technology Stack

The landing page (`index.html`) was migrated from HTML5 UP Spectral to UpConstruction (Bootstrap 5) in February 2026. Content pages (`methodology.html`, `resources.html`, etc.) still use the old Spectral HTML structure but load the new CSS -- see [Content Page Layout](#content-page-layout-transitional) for details.

| Layer | Technology | Notes |
|-------|-----------|-------|
| Template | [UpConstruction](https://bootstrapmade.com/upconstruction-bootstrap-construction-website-template/) | BootstrapMade, Bootstrap v5.3.3 |
| CSS framework | Bootstrap 5.3.3 | Grid, utilities, navbar, cards |
| Animation | AOS (Animate on Scroll) | Fade-in / slide effects on scroll |
| Lightbox | GLightbox | Image/media overlays |
| Slider | Swiper | Hero carousel |
| Layout | Isotope + imagesLoaded | Filterable grid layout (available, not currently used) |
| Counter | PureCounter | Animated number counters (available, not currently used) |
| Icons | Font Awesome 6 (Free) | Loaded via `assets/vendor/fontawesome-free/` |
| Icons (nav) | Bootstrap Icons | `bi-chevron-down`, `bi-list`, `bi-arrow-right`, etc. |
| Typography | Google Fonts | Roboto, Open Sans, Poppins |
| Hosting | GitHub Pages | Static HTML, no build step required |
| Previous template | HTML5 UP Spectral | Backed up in `assetsx/`; still used by content pages |

---

## Page Inventory

| File | Route | Template | Description |
|------|-------|----------|-------------|
| `index.html` | `/` | UpConstruction (Bootstrap 5) | Landing page: hero, mission, HPRM, maps, news |
| `methodology.html` | `/methodology.html` | Spectral (legacy) | Data collection methodology documentation |
| `resources.html` | `/resources.html` | Spectral (legacy) | Eviction help resources for tenants |
| `research.html` | `/research.html` | Spectral (legacy) | Links to other eviction research |
| `news.html` | `/news.html` | Spectral (legacy) | News and media coverage |
| `maps.html` | `/maps.html` | Spectral (legacy) | Interactive maps page |
| `maps/us_map.html` | `/maps/us_map.html` | Leaflet standalone | US map visualization (embedded in index.html via iframe) |
| `maps/pre.html` | `/maps/pre.html` | Leaflet standalone | Pre-pandemic map visualization |
| `maps/post.html` | `/maps/post.html` | Leaflet standalone | Post-pandemic map visualization |
| `maps/last_year.html` | `/maps/last_year.html` | Leaflet standalone | Last-year map visualization |
| `maps/dur.html` | `/maps/dur.html` | Leaflet standalone | Duration map visualization |
| `maps/all.html` | `/maps/all.html` | Leaflet standalone | All-data map visualization |

---

## Landing Page Anatomy (`index.html`)

The landing page uses the UpConstruction template with Bootstrap 5 grid layout. Each section is a `<section>` with a descriptive id and CSS class.

```
+----------------------------------------------------------+
|  #header (fixed-top, Bootstrap navbar)                    |
|    - ERN banner logo                                      |
|    - Dropdown nav: Maps, Methodology, Resources, Contact  |
|    - Mobile: hamburger toggle (bi-list icon)              |
+----------------------------------------------------------+
|  #hero (full-viewport, dark background, carousel)         |
|    - Stacked logo (from assetsx/ern_logo/)                |
|    - "University of California, Berkeley"                 |
|    - Bluesky link                                         |
|    - "Learn More" button -> #get-started                  |
|    - Background: seattle_air.png in carousel              |
+----------------------------------------------------------+
|  #get-started (two-column)                                |
|    Left: "RESEARCH FOR SOCIAL GOOD" + mission text        |
|    Right: bannersmall.jpg image                           |
+----------------------------------------------------------+
|  #national-housing-precarity-risk-model (two-column)      |
|    Left: bay_hprm.png linked to /hprm/                   |
|    Right: HPRM description + "Learn More" link            |
+----------------------------------------------------------+
|  #constructions (two-column)                              |
|    Left: "State Projects" text                            |
|    Right: maps/us_map.html iframe                         |
+----------------------------------------------------------+
|  #recent-blog-posts (three-column card grid)              |
|    - National data report (Tim Thomas & Alex Ramiller)    |
|    - Oregon report (Tim Thomas & Hannah Moore)            |
|    - Portland study (Farrington, Cholula, Bates)          |
|    - "For more research & news" link                      |
+----------------------------------------------------------+
|  <!-- #features (Methodology) — commented out -->         |
+----------------------------------------------------------+
|  #footer (dark-background)                                |
|    - ERN stacked logo                                     |
|    - Urban Displacement Project link                      |
|    - Social: Twitter/X, Email                             |
|    - Useful Links: Home, Resources, Other Research        |
|    - Copyright: Eviction Research Network                 |
|    - Credits: BootstrapMade                               |
+----------------------------------------------------------+
|  #scroll-top (floating button)                            |
|  #preloader (removed on page load)                        |
+----------------------------------------------------------+
```

### Section Details

#### Header (`#header`)

- **Position**: Fixed at top (`fixed-top`), flex layout
- **Container**: `.container-fluid.container-xl` for responsive width
- **Logo**: ERN banner logo (`images/ern_logo/1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER.png`)
- **Navigation** (`#navmenu`): Bootstrap responsive navbar with dropdowns
  - Home (active)
  - Maps & Profiles (dropdown): California, Delaware, Indiana, Maryland, Minnesota, Ohio, Oregon, Washington
  - Methodology
  - Resources (dropdown): Eviction Help, Other Eviction Research
  - Contact (mailto link)
- **Mobile**: Hamburger icon (`.mobile-nav-toggle`, `bi-list` / `bi-x`) toggles `.mobile-nav-active` on body
- **Scroll behavior**: Body gets `.scrolled` class when `window.scrollY > 100`

#### Hero (`#hero`)

- **Classes**: `.hero.section.dark-background`
- **Layout**: Full viewport, centered content over carousel background
- **Content**: Stacked logo (400px, from `assetsx/ern_logo/`), university tagline, Bluesky link, "Learn More" button
- **Carousel**: Bootstrap carousel (`#hero-carousel`) with `data-bs-ride="carousel"` and 5s interval; currently one slide (`images/seattle_air.png`)
- **"Learn More"**: `.btn-get-started` linking to `#get-started`

#### Get Started (`#get-started`) -- Mission Statement

- **Classes**: `.get-started.section`
- **Layout**: Two-column Bootstrap grid (`col-lg-6` + `col-lg-6`)
- **Left column**: "RESEARCH FOR SOCIAL GOOD" heading + mission description
- **Right column**: `images/bannersmall.jpg` image

#### National Housing Precarity Risk Model (`#national-housing-precarity-risk-model`)

- **Classes**: `.national-housing-precarity-risk-model.section`
- **Title**: `<div class="container section-title"><h2>...</h2></div>` pattern
- **Layout**: Two-column grid with image on left, text on right
- **Image**: `images/bay_hprm.png` linked to `https://evictionresearch.net/hprm/`, styled with `object-fit: cover` and scale transform
- **Content**: HPRM description + "Learn More" link

#### State Eviction Maps (`#constructions`)

- **Classes**: `.constructions.section`
- **Layout**: Two-column grid with text on left, map on right
- **Left**: "State Projects" heading, eviction trends description, prompt to interact with map
- **Right**: `maps/us_map.html` embedded via iframe in `.map-container` with `.map-overlay` prompt

#### Recent Research & News (`#recent-blog-posts`)

- **Classes**: `.recent-blog-posts.section`
- **Layout**: Three-column card grid (`col-xl-4 col-md-6`)
- **Card pattern**: `.post-item` with `.post-img` (image + date badge), `.post-content` (meta with author/category, description, "Read More" link)
- **Featured items**:
  1. National data report (2024) -- Tim Thomas & Alex Ramiller -- HUD Cityscape publication
  2. Oregon report (May 2024) -- Tim Thomas & Hannah Moore -- Oregon racial disparities
  3. Portland study (2024) -- Farrington, Cholula, & Bates -- Portland eviction disparities
- **Footer link**: "For more research & news" linking to `research.html`

#### Methodology (`#features`) -- Commented Out

- Currently commented out in the HTML (`<!-- ... -->`)
- Contains a Bootstrap tabbed interface with four tabs: Data Providers, Geocoding, Data Cleaning, Demographic Estimation
- Each tab has a two-column layout with text + image
- May be re-enabled in a future update

#### Footer (`#footer`)

- **Classes**: `.footer.dark-background`
- **Layout**: Multi-column grid (`col-lg-3`, `col-lg-2`)
- **Content**:
  - ERN stacked logo (`images/ern_logo/1A/...STACK_REV.png`)
  - Urban Displacement Project link
  - Social icons: Twitter/X (`bi-twitter-x`), Email (`bi-envelope`)
  - Useful Links: Home, Resources, Other Eviction Research
- **Copyright**: "Eviction Research Network" (no year specified)
- **Credits**: "Designed by BootstrapMade"

---

## Section Layout Patterns

The UpConstruction template uses a consistent set of Bootstrap-based layout patterns across sections.

### Two-Column Section Pattern

Most content sections use a two-column Bootstrap grid:

```html
<section id="section-name" class="section-name section">
  <div class="container section-title">
    <h2>Section Title</h2>
  </div>
  <div class="container">
    <div class="row justify-content-between gy-4 align-items-center">
      <div class="col-lg-6">
        <!-- Image or text content -->
      </div>
      <div class="col-lg-6">
        <!-- Text or image content -->
      </div>
    </div>
  </div>
</section>
```

- Uses `col-lg-6` for a 50/50 split at large viewports; stacks vertically below `lg` (992px)
- `gy-4` provides vertical gutter spacing when stacked
- `align-items-center` vertically centers content
- `section-title` container provides consistent heading placement

### Card Grid Pattern

Used for the Research & News section:

```html
<div class="row gy-5">
  <div class="col-xl-4 col-md-6">
    <div class="post-item position-relative h-100">
      <div class="post-img position-relative overflow-hidden">
        <img src="..." class="img-fluid" alt="">
        <span class="post-date">Date</span>
      </div>
      <div class="post-content d-flex flex-column">
        <div class="meta d-flex align-items-center">...</div>
        <p>Description</p>
        <a href="..." class="readmore stretched-link">Read More</a>
      </div>
    </div>
  </div>
</div>
```

- Three columns at `xl` (1200px+), two columns at `md` (768px+), single column below
- `.post-item` with `.h-100` ensures equal-height cards
- `.stretched-link` makes the entire card clickable
- `.post-date` badge overlays the image

### Section Title Pattern

Consistent heading across sections:

```html
<div class="container section-title">
  <h2>Title Text</h2>
</div>
```

---

## Color Palette

Source: `assets/css/main.css` CSS custom properties (`:root` variables)

### Global Colors

| Variable | Value | Usage |
|----------|-------|-------|
| `--background-color` | `#ffffff` | Page background |
| `--default-color` | `#364d59` | Body text (dark blue-gray) |
| `--heading-color` | `#52565e` | Headings and subheadings |
| `--accent-color` | `#ee3029` | Brand color -- buttons, links, CTAs (red) |
| `--surface-color` | `#ffffff` | Card and element backgrounds |
| `--contrast-color` | `#ffffff` | Text on accent/dark backgrounds |

### Navigation Colors

| Variable | Value | Usage |
|----------|-------|-------|
| `--nav-color` | `rgba(255,255,255,0.55)` | Default nav link color (semi-transparent white) |
| `--nav-hover-color` | `#ffffff` | Nav link hover/active state |
| `--nav-mobile-background-color` | `#ffffff` | Mobile menu background |
| `--nav-dropdown-background-color` | `#ffffff` | Dropdown menu background |
| `--nav-dropdown-color` | `#212529` | Dropdown link text |
| `--nav-dropdown-hover-color` | `#ee3029` | Dropdown link hover (matches accent) |

### Section Presets

| Class | Background | Text | Usage |
|-------|-----------|------|-------|
| (default) | `#ffffff` | `#364d59` | Most sections (get-started, HPRM, constructions, blog posts) |
| `.dark-background` | `#060606` | `#ffffff` | Hero section, footer |
| `.light-background` | `#f4f7f6` | (inherits) | Alternate section backgrounds |

---

## Typography

Source: `assets/css/main.css` CSS custom properties

| Property | Value |
|----------|-------|
| Default font (`--default-font`) | `"Open Sans", system-ui, -apple-system, "Segoe UI", Roboto, "Helvetica Neue", Arial, "Noto Sans", "Liberation Sans", sans-serif` |
| Heading font (`--heading-font`) | `"Roboto", sans-serif` |
| Nav font (`--nav-font`) | `"Poppins", sans-serif` |
| Google Fonts loaded | Roboto (100--900), Open Sans (300--800), Poppins (100--900) |
| Body text color | `#364d59` (dark blue-gray) |
| Heading text color | `#52565e` (medium gray) |

---

## Responsive Breakpoints

Bootstrap 5.3.3 default breakpoints:

| Name | Min width | CSS class prefix | Key changes |
|------|-----------|------------------|-------------|
| xs | 0 | (none) | Single column, mobile nav |
| sm | 576px | `.col-sm-` | Small devices |
| md | 768px | `.col-md-` | Blog cards go to 2 columns |
| lg | 992px | `.col-lg-` | Two-column section layouts activate |
| xl | 1200px | `.col-xl-` | Blog cards go to 3 columns; desktop nav |
| xxl | 1400px | `.col-xxl-` | Max container width |

Navigation switches from dropdown desktop menu to hamburger mobile menu at the `xl` breakpoint (1200px), controlled by `.d-xl-none` on the mobile toggle.

---

## JavaScript Behavior

Scripts loaded at the end of `<body>`, all from `assets/vendor/` or `assets/js/`:

| Script | Purpose |
|--------|---------|
| `bootstrap.bundle.min.js` | Bootstrap 5 components (navbar, dropdowns, carousel, collapse) |
| `validate.js` (php-email-form) | Contact form validation (available, not currently used) |
| `aos.js` | Animate on Scroll -- fade/slide effects triggered by scroll position |
| `glightbox.min.js` | Lightbox overlays for images and media |
| `imagesloaded.pkgd.min.js` | Detect when images finish loading (used by Isotope) |
| `isotope.pkgd.min.js` | Filterable masonry/grid layouts |
| `swiper-bundle.min.js` | Touch-friendly slider/carousel |
| `purecounter_vanilla.js` | Animated number counters |
| `main.js` | Site initialization (see below) |

### Key Behaviors (from `main.js`)

- **Scroll class**: Adds `.scrolled` to `<body>` when scrolled past 100px (used by header styling)
- **Mobile nav**: Toggles `.mobile-nav-active` on body, swaps hamburger icon between `bi-list` and `bi-x`
- **Dropdown toggle**: Mobile dropdown menus toggle `.active` and `.dropdown-active` classes
- **Preloader**: `#preloader` element removed on page load
- **Scroll-to-top**: `#scroll-top` button fades in/out based on scroll position, smooth-scrolls to top on click
- **AOS init**: Initializes AOS with 600ms duration, ease-in-out easing, one-time animation
- **GLightbox init**: Activates lightbox on `.glightbox` elements
- **Isotope init**: Initializes filterable grid layouts on `.isotope-layout` elements (data attributes configure layout mode, default filter, sort)
- **Swiper init**: Initializes sliders on `.init-swiper` elements (reads config from `.swiper-config` child)
- **PureCounter init**: Initializes animated counters

---

## Content Page Layout (Transitional)

The content pages (`methodology.html`, `resources.html`, `research.html`, `news.html`) are in a **transitional state**: their HTML still uses the old Spectral template structure, but they now load the new UpConstruction `assets/css/main.css`.

### What This Means

- HTML comments say "Spectral by HTML5 UP" and the markup uses Spectral conventions (`.is-preload`, `#page-wrapper`, Spectral navigation)
- CSS loaded is the UpConstruction stylesheet, not the original Spectral one
- The old Spectral CSS (`assetsx/css/main.css`) and JS (`assetsx/js/`) are preserved but not referenced by these pages
- Visual appearance may differ from the original Spectral styling since the CSS classes no longer match

### Content Page Structure (Legacy Spectral HTML)

```
+------------------------------------------+
|  #header (Spectral-style, not Bootstrap)  |
|    - ERN banner logo (300px)              |
|    - Navigation list                      |
+------------------------------------------+
|  article#main                            |
|    header (page title)                   |
|    .wrapper.style5 (content wrapper)     |
|      .inner (content area)               |
|        Page content...                   |
+------------------------------------------+
|  #footer (Spectral-style)                |
+------------------------------------------+
```

### Recommendation

These pages should eventually be migrated to the UpConstruction template to match the landing page, using the same `#header`, `#navmenu`, `<main>`, and `#footer` structure.

---

## Directory Structure

```
evictionresearch.github.io/
├── index.html                 # Landing page (UpConstruction / Bootstrap 5)
├── methodology.html           # Methodology article (legacy Spectral HTML)
├── resources.html             # Eviction help article (legacy Spectral HTML)
├── research.html              # Other research article (legacy Spectral HTML)
├── news.html                  # News article (legacy Spectral HTML)
├── maps.html                  # Maps page (legacy Spectral HTML)
├── maps/
│   ├── us_map.html            # Embedded US map (Leaflet)
│   ├── pre.html               # Pre-pandemic map
│   ├── post.html              # Post-pandemic map
│   ├── last_year.html         # Last-year map
│   ├── dur.html               # Duration map
│   ├── all.html               # All-data map
│   └── us_map_files/          # Leaflet dependencies (JS, CSS)
├── assets/
│   ├── css/
│   │   ├── main.css           # UpConstruction stylesheet (~3195 lines)
│   │   └── noscript.css       # No-JS fallback styles
│   ├── js/
│   │   └── main.js            # UpConstruction site initialization
│   ├── img/                   # UpConstruction template images
│   │   ├── team/              # Team member photos (new)
│   │   ├── hero-carousel/     # Hero background images
│   │   ├── blog/              # Blog post images
│   │   └── projects/          # Project images
│   ├── scss/                  # SCSS source (Readme.txt only)
│   └── vendor/                # Third-party libraries
│       ├── bootstrap/         # Bootstrap 5.3.3 (CSS + JS)
│       ├── bootstrap-icons/   # Bootstrap Icons
│       ├── aos/               # Animate on Scroll
│       ├── fontawesome-free/  # Font Awesome 6
│       ├── glightbox/         # GLightbox
│       ├── swiper/            # Swiper slider
│       ├── isotope-layout/    # Isotope grid
│       ├── imagesloaded/      # imagesLoaded utility
│       ├── purecounter/       # PureCounter
│       └── php-email-form/    # Form validation
├── assetsx/                   # Backup of old Spectral template assets
│   ├── css/                   # Old Spectral main.css + noscript.css
│   ├── js/                    # jQuery, scrollex, scrolly, etc.
│   ├── sass/                  # SASS source (vars, mixins, etc.)
│   ├── ern_logo/              # Logo variations
│   └── webfonts/              # Font Awesome 5 webfonts
├── images/                    # Content images
│   ├── photos/                # Team member headshots (legacy)
│   ├── logos/                 # Partner/funder organization logos
│   ├── ern_logo/              # ERN logo variations (1A, 1Av2)
│   ├── about_page/            # Background/decorative images
│   └── archivephoto/          # Archived photos
├── archive/                   # Archived logo assets
├── code/                      # Analysis code (R scripts, etc.)
├── data/                      # Data files
├── html5up-spectral/          # Original unmodified Spectral template
├── html5up-spectral.zip       # Template download archive
├── CNAME                      # Custom domain: evictionresearch.net
├── LICENSE.txt                # CCA 3.0 license
├── README.md
└── docs/
    └── WEBDESIGN.md           # This file
```

---

## Design Vocabulary Reference

| Term | Meaning in This Site |
|------|---------------------|
| **Section** | A full-width `<section>` element with a descriptive id and matching CSS class |
| **Section Title** | A `<div class="container section-title"><h2>` block used for consistent headings |
| **Hero** | The full-viewport opening section with logo, tagline, and carousel background |
| **Dark Background** | A section preset (`.dark-background`) that inverts colors for dark sections |
| **Post Item** | A card component (`.post-item`) used in the Research & News grid |
| **Navmenu** | The Bootstrap responsive navigation bar (`#navmenu`) |
| **Mobile Nav Toggle** | The hamburger icon (`.mobile-nav-toggle`) that shows/hides mobile navigation |
| **Scroll Top** | A floating button (`#scroll-top`) that smooth-scrolls to the top of the page |
| **Preloader** | A loading indicator (`#preloader`) removed after the page fully loads |
| **AOS** | Animate on Scroll -- triggers CSS animations when elements enter the viewport |
| **Container** | Bootstrap's `.container` class providing responsive max-width centering |
| **Wrapper** | (Legacy Spectral) Full-width section container with `.wrapper.styleN` classes -- still used in content pages |
| **Spotlight** | (Legacy Spectral) Alternating image+text card -- no longer used in `index.html` |
