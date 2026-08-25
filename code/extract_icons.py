#!/usr/bin/env python3
"""Print the four About-page icons as SVG path data.

    python3 code/extract_icons.py

Reads them out of the Bootstrap Icons font this repo already vendors, so the
paths in _extensions/ern/about/template.html are the real icons rather than
hand-copied approximations. Needs fonttools and brotli, which are not project
dependencies; run it in a throwaway venv when an icon has to change.

Font units run y-up from the baseline and SVG runs y-down, so each outline is
flipped into a 16x16 viewBox on the way out.
"""
import re
from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.misc.transform import Transform

WANT = ['layers', 'map', 'people', 'megaphone']
import json
codes = json.load(open('assets/vendor/bootstrap-icons/bootstrap-icons.json'))

f = TTFont('assets/vendor/bootstrap-icons/fonts/bootstrap-icons.woff2')
cmap, gs = f.getBestCmap(), f.getGlyphSet()
upem = f['head'].unitsPerEm
scale = 16.0 / upem
desc = abs(f['hhea'].descent) * scale

def tidy(d):
    # two decimals is well below a pixel at the size these render
    d = re.sub(r'-?\d+\.\d+', lambda m: f'{float(m.group()):.2f}'.rstrip('0').rstrip('.'), d)
    return re.sub(r'\s+', ' ', d).strip()

for name in WANT:
    pen = SVGPathPen(gs)
    gs[cmap[codes[name]]].draw(TransformPen(pen, Transform(scale, 0, 0, -scale, 0, 16 - desc)))
    print(f'{name}\t{tidy(pen.getCommands())}')
