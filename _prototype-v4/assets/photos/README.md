# Photo assets for v4 prototype

The v4 prototypes expect two photographs at fixed filenames. Drop your originals
here at the paths below; CSS handles desaturation/sizing automatically.

| File | Source | Used in |
|------|--------|---------|
| `door-410.jpg` | Tim's photograph of King County eviction warning, 2017 | Front page hero, HUD-ERA cover |
| `mlk-mural.jpg` | Baltimore "Keep the Dream Alive" mural | Front page essay block, Minnesota race section |

**Recommended dimensions:** at least 2400px on the long edge for retina display.
The CSS sets `object-fit: cover` so any aspect ratio works, but landscape
(`door-410.jpg`) and landscape-or-portrait (`mlk-mural.jpg`) are what the layout
expects.

**Format:** JPG (smaller) or WebP (smallest). Avoid PNG — the file sizes will be
large and there's no transparency benefit for full-frame photographs.

**B&W treatment:** the CSS applies `filter: grayscale(100%) contrast(1.05)` site-wide.
You can drop in color or B&W originals; either becomes B&W in the prototype. If
you have already-B&W scans, even better.

**Where the files actually go in three repos:**

```
evictionresearch.github.io/_prototype-v4/assets/photos/door-410.jpg
evictionresearch.github.io/_prototype-v4/assets/photos/mlk-mural.jpg
minnesota/_prototype-v4/assets/photos/mlk-mural.jpg     (sym-link or copy ok)
hud-era/_prototype-v4/assets/photos/door-410.jpg        (sym-link or copy ok)
```

If a photo is missing, the prototype shows a styled placeholder block with the
expected filename — the layout doesn't break.
