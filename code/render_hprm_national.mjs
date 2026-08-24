// Render the real HPRM v5 (2022) composite score for all 83,500 census tracts
// into the national raster used by maps/us-hprm-map.html.
//
// Reproduce:
//
//   cd /tmp && mkdir -p hprm-build && cd hprm-build
//   npm install d3-geo d3-scale topojson-client @napi-rs/canvas
//   curl -o states-10m.json https://cdn.jsdelivr.net/npm/us-atlas@3.0.1/states-10m.json
//   bzcat ~/git/evictionresearch/hprm/data/hprm_v5_full_2022.geojson.bz2 > tracts.geojson
//   cp <repo>/code/render_hprm_national.mjs .        # node resolves
//                                                   # node_modules from the
//                                                   # script's own directory
//   TRACTS=tracts.geojson ATLAS=states-10m.json OUT=raw.png METROS=metros.json \
//     node --max-old-space-size=6144 render_hprm_national.mjs
//
//   # Flatten to the exact eleven colours the legend advertises. Median-cut
//   # quantisation drifts the brand red (only 55 tracts score 8, so it loses
//   # the vote), which would leave the map disagreeing with its own key.
//   magick -size 1x1 xc:'#FFFFFF' xc:'#F1F4F7' xc:'#DBE4EE' xc:'#B3C4D6' \
//     xc:'#8BA3BE' xc:'#647E9F' xc:'#415A7C' xc:'#223754' xc:'#7D2C31' \
//     xc:'#C0231C' xc:'#F9322B' +append palette.png
//   magick raw.png +dither -remap palette.png -depth 8 \
//     PNG8:<repo>/assets/img/hprm-tracts-2022.png
//   cp metros.json <repo>/assets/data/hprm-metros.json
//
// The raster is registered to the same d3 projection maps/us-hprm-map.html
// draws its state mesh with, so the two line up pixel-for-pixel. If you change
// the projection, the size, or the AK/HI exclusion here, change it there too.
//
// Two things about the source data drive the code below.
//
// 1. The GeoJSON (written out of sf) winds exterior rings counterclockwise in
//    lon/lat. d3-geo reads spherical polygons the other way round, so every
//    ring arrives describing the whole sphere minus the tract. Rewind first or
//    each fill paints the entire canvas.
// 2. Risk is concentrated in tracts that are geographically tiny. 98% of
//    tracts score 0-5 and cover almost all the land; the 1,551 tracts scoring
//    6+ are urban and sub-pixel at national scale. Drawing in file order at
//    true area hides exactly what the map is about, so high scores draw last
//    and every tract gets a minimum mark.
import fs from 'node:fs';
import readline from 'node:readline';
import { geoAlbers, geoPath, geoCentroid } from 'd3-geo';
import { scaleLinear } from 'd3-scale';
import * as topojson from 'topojson-client';
import { createCanvas } from '@napi-rs/canvas';

const W = 975, H = 610, SCALE = 3;
const LAND = '#f1f4f7';          // land with no score: unmapped tracts
const MIN_MARK = 1.5;            // px side for tracts below MIN_AREA
const MIN_AREA = 1.0;            // px^2
const TOP_FROM = 4;              // scores >= this are buffered and drawn last
const SKIP = new Set(['02', '15', '60', '66', '69', '72', '78']); // AK, HI, territories

const us = JSON.parse(fs.readFileSync(process.env.ATLAS || 'states-10m.json', 'utf8'));
const allStates = topojson.feature(us, us.objects.states);
const conusGeoms = us.objects.states.geometries.filter(g => !SKIP.has(g.id));
const conus = { type: 'FeatureCollection', features: allStates.features.filter(f => !SKIP.has(f.id)) };
const nation = topojson.merge(us, conusGeoms);

const proj = geoAlbers().fitSize([W, H], conus);

// The design's ramp, sampled at the nine integer scores the model actually
// produces: hprm_score = edr (0-4) + eer (0-4), so the surface is ordinal.
const ramp = scaleLinear()
  .domain([0, 2, 3.6, 5, 6.2, 7.2, 8])
  .range(['#dbe4ee', '#8BA3BE', '#4d688c', '#223754', '#8f2a2a', '#CC2118', '#F9322B'])
  .clamp(true);
const STEPS = Array.from({ length: 9 }, (_, i) => ramp(i));

function shoelace(ring) {
  let a = 0;
  for (let i = 0, n = ring.length - 1; i < n; i++) {
    a += ring[i][0] * ring[i + 1][1] - ring[i + 1][0] * ring[i][1];
  }
  return a;
}
// d3 wants the exterior ring clockwise in lon/lat and holes counterclockwise.
function rewind(geom) {
  const polys = geom.type === 'Polygon' ? [geom.coordinates] : geom.coordinates;
  for (const poly of polys) {
    for (let i = 0; i < poly.length; i++) {
      const want = i === 0 ? -1 : 1;
      if (Math.sign(shoelace(poly[i])) !== want) poly[i].reverse();
    }
  }
}

const canvas = createCanvas(W * SCALE, H * SCALE);
const ctx = canvas.getContext('2d');
ctx.scale(SCALE, SCALE);
const path = geoPath(proj, ctx);
const measure = geoPath(proj);

ctx.fillStyle = '#ffffff';
ctx.fillRect(0, 0, W, H);
ctx.beginPath(); path({ type: 'Feature', geometry: nation });
ctx.fillStyle = LAND; ctx.fill();

function paint(f, s) {
  const color = STEPS[s];
  ctx.beginPath();
  path(f);
  ctx.fillStyle = color;
  ctx.fill();
  // Same-colour hairline closes the sub-pixel cracks between neighbours.
  ctx.strokeStyle = color;
  ctx.lineWidth = 0.35;
  ctx.stroke();
  // Minimum mark: a tract below a few square pixels would otherwise disappear.
  if (measure.area(f) < MIN_AREA) {
    const c = measure.centroid(f);
    if (!Number.isNaN(c[0])) {
      ctx.fillRect(c[0] - MIN_MARK / 2, c[1] - MIN_MARK / 2, MIN_MARK, MIN_MARK);
    }
  }
}

const cbsa = new Map();
const drawn = new Array(9).fill(0);
const top = [];
let unmapped = 0, total = 0, minMarked = 0;

const rl = readline.createInterface({
  input: fs.createReadStream(process.env.TRACTS || 'tracts.geojson'),
  crlfDelay: Infinity
});

for await (const line of rl) {
  const t = line.trim().replace(/,$/, '');
  if (t.charCodeAt(0) !== 123 || t.indexOf('"Feature"') < 0) continue;
  let f;
  try { f = JSON.parse(t); } catch (e) { continue; }
  const p = f.properties;
  total++;
  rewind(f.geometry);

  if (p.map === true) {
    const s = Math.max(0, Math.min(8, Math.round(p.hprm_score)));
    if (measure.area(f) < MIN_AREA) minMarked++;
    if (s >= TOP_FROM) top.push([f, s]); else paint(f, s);
    drawn[s]++;
  } else {
    unmapped++;
  }

  // Metro roster, straight out of the dataset: real names, real centroids.
  if (p.cbsa_type === 'Metro' && p.cbsa_name) {
    let c = cbsa.get(p.cbsa_name);
    if (!c) { c = { name: p.cbsa_name, pop: 0, wx: 0, wy: 0, w: 0, x0: Infinity, y0: Infinity, x1: -Infinity, y1: -Infinity }; cbsa.set(p.cbsa_name, c); }
    c.pop += p.tract_pop_e || 0;
    const pt = proj(geoCentroid(f));
    if (pt) {
      const w = (p.tract_pop_e || 0) + 1;
      c.wx += pt[0] * w; c.wy += pt[1] * w; c.w += w;
      if (pt[0] < c.x0) c.x0 = pt[0];
      if (pt[1] < c.y0) c.y0 = pt[1];
      if (pt[0] > c.x1) c.x1 = pt[0];
      if (pt[1] > c.y1) c.y1 = pt[1];
    }
  }
}

// Highest risk paints last so a neighbouring low-score tract cannot bury it.
top.sort((a, b) => a[1] - b[1]).forEach(([f, s]) => paint(f, s));

// State hairlines and the national outline stay in the SVG overlay, not the
// raster. Keeping them out means the raster holds exactly eleven flat colours,
// so it can be remapped to an exact palette without the brand red drifting.

fs.writeFileSync(process.env.OUT || 'raw.png', canvas.encodeSync('png'));

const metros = [...cbsa.values()]
  .filter(c => c.w > 1 && c.pop >= 500000)
  .map(c => ({
    n: c.name,
    x: +(c.wx / c.w).toFixed(1),
    y: +(c.wy / c.w).toFixed(1),
    r: +Math.max(13, Math.min(64, Math.hypot(c.x1 - c.x0, c.y1 - c.y0) * 0.40)).toFixed(1)
  }))
  .sort((a, b) => a.n.localeCompare(b.n));

fs.writeFileSync(process.env.METROS || 'metros.json', JSON.stringify(metros));

console.log('tracts read:', total, '| scored + mapped:', drawn.reduce((a, b) => a + b, 0), '| unmapped:', unmapped);
console.log('per-score counts 0..8:', drawn.join(' '));
console.log('given a minimum mark:', minMarked, '(' + (100 * minMarked / (total - unmapped)).toFixed(1) + '% of mapped tracts)');
console.log('metros >= 500k:', metros.length);
