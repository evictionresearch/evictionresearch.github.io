#!/usr/bin/env python3
"""Build the home page maps' data and wire it into them.

The map on the home page and the directory at /all_states/ must never disagree
about which states ERN has profiled or where a state's data lives, so the
roster is read out of all_states/index.html rather than restated by hand.
Per-profile coverage and date ranges come from the Eviction Data Atlas dataset
(library/data/eviction_data_atlas/atlas.json), which records what each
published profile actually covers.

The maps carry their data inline rather than fetching it. A browser treats
every file:// document as its own opaque origin and blocks same-directory
fetches, so a fetched map is a blank map whenever the page is opened straight
off disk instead of through a server. Inlining costs about 22KB and makes the
page work either way.

    python3 code/build_home_map_data.py

Writes assets/data/state-coverage.json as the public artifact, then inlines it
into maps/us-coverage-map.html, and inlines assets/data/hprm-metros.json
(written by code/render_hprm_national.mjs) into maps/us-hprm-map.html. It is
the only writer of those inline blocks; edit the sources and re-run.
"""
import html
import json
import os
import re

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DIRECTORY = os.path.join(REPO, 'all_states', 'index.html')
ATLAS = os.path.expanduser(
    '~/git/evictionresearch/library/data/eviction_data_atlas/atlas.json')
OUT = os.path.join(REPO, 'assets', 'data', 'state-coverage.json')
METROS = os.path.join(REPO, 'assets', 'data', 'hprm-metros.json')
COVERAGE_MAP = os.path.join(REPO, 'maps', 'us-coverage-map.html')
HPRM_MAP = os.path.join(REPO, 'maps', 'us-hprm-map.html')

FIPS = {
    'Alabama': '01', 'Alaska': '02', 'Arizona': '04', 'Arkansas': '05',
    'California': '06', 'Colorado': '08', 'Connecticut': '09', 'Delaware': '10',
    'District of Columbia': '11', 'Florida': '12', 'Georgia': '13', 'Hawaii': '15',
    'Idaho': '16', 'Illinois': '17', 'Indiana': '18', 'Iowa': '19', 'Kansas': '20',
    'Kentucky': '21', 'Louisiana': '22', 'Maine': '23', 'Maryland': '24',
    'Massachusetts': '25', 'Michigan': '26', 'Minnesota': '27', 'Mississippi': '28',
    'Missouri': '29', 'Montana': '30', 'Nebraska': '31', 'Nevada': '32',
    'New Hampshire': '33', 'New Jersey': '34', 'New Mexico': '35', 'New York': '36',
    'North Carolina': '37', 'North Dakota': '38', 'Ohio': '39', 'Oklahoma': '40',
    'Oregon': '41', 'Pennsylvania': '42', 'Rhode Island': '44',
    'South Carolina': '45', 'South Dakota': '46', 'Tennessee': '47', 'Texas': '48',
    'Utah': '49', 'Vermont': '50', 'Virginia': '51', 'Washington': '53',
    'West Virginia': '54', 'Wisconsin': '55', 'Wyoming': '56',
}

# What each published ERN profile actually covers. Every line is grounded in the
# matching record under national.ern.profiles in atlas.json; the wording is
# condensed for a one-line readout, and the spans are asserted against the
# dataset below so a refreshed atlas cannot leave a stale claim on the page.
PROFILE_NOTES = {
    '53': ('Statewide, county level', 'January 2016 - April 2026'),
    '27': ('Statewide, county and census tract', 'January 2017 - March 2026'),
    '41': ('Statewide, county and census tract', '2017 - March 2024'),
    '18': ('Statewide, county and census tract', '2016 - April 2022'),
    '10': ('Statewide, all three counties', '2016 - April 2022'),
    '06': ('Nine-county Bay Area', '2017 - October 2021'),
    '24': ('Baltimore City, census tract', 'January 2018 - July 2019'),
    # The Dayton page contradicts itself on dates (title 2017-2021, body
    # 2015-2022), so the readout states coverage and leaves the span to the
    # profile itself rather than pick a side.
    '39': ('Dayton metro, census tract', None),
}

KIND_LABEL = {
    'ern': 'ERN state profile',
    'lsc': 'Public data elsewhere',
    'other': 'Public data elsewhere',
    'none': 'No public eviction data',
}


def inline(html_path, name, payload):
    """Replace the generated <script type="application/json"> block in place."""
    begin = '<!-- BEGIN generated: %s -->' % name
    end = '<!-- END generated: %s -->' % name
    body = json.dumps(payload, sort_keys=True, separators=(',', ':'))
    # A literal "</script>" inside the JSON would close the block early.
    body = body.replace('<', '\\u003c')
    block = '%s\n<script type="application/json" id="%s">%s</script>\n%s' % (
        begin, name, body, end)
    src = open(html_path, encoding='utf-8').read()
    i, j = src.find(begin), src.find(end)
    if i < 0 or j < 0:
        raise SystemExit('markers for %r not found in %s' % (name, html_path))
    out = src[:i] + block + src[j + len(end):]
    open(html_path, 'w', encoding='utf-8').write(out)
    return len(body)


def strip(markup):
    return html.unescape(re.sub(r'<[^>]+>', '', markup)).strip()


def main():
    directory = open(DIRECTORY, encoding='utf-8').read()
    rows = re.findall(
        r'<tr><th scope="row">(.*?)</th><td>(.*?)</td><td>(.*?)</td></tr>',
        directory, re.S)
    if len(rows) != 51:
        raise SystemExit('expected 51 states in all_states/index.html, found %d' % len(rows))

    atlas = json.load(open(ATLAS, encoding='utf-8'))
    spans = {p['state']: p for p in atlas['national']['ern']['profiles']}
    abbr = {
        '53': 'WA', '27': 'MN', '41': 'OR', '18': 'IN',
        '10': 'DE', '06': 'CA', '24': 'MD', '39': 'OH',
    }

    states = {}
    counts = {}
    for name, source_cell, kind_cell in rows:
        name = strip(name)
        fips = FIPS[name]
        kind = re.search(r'dot-(\w+)', kind_cell)
        kind = kind.group(1) if kind else 'other'
        counts[kind] = counts.get(kind, 0) + 1

        link = re.search(r'href="([^"]+)"[^>]*>(.*?)</a>', source_cell, re.S)
        record = {
            'name': name,
            'kind': 'ern' if kind == 'ern' else ('none' if kind == 'none' else 'other'),
            'status': KIND_LABEL[kind],
            'source': strip(link.group(2)) if link else strip(source_cell),
            'url': link.group(1) if link else None,
        }

        if kind == 'ern':
            coverage, span = PROFILE_NOTES[fips]
            atlas_span = spans[abbr[fips]]['time_span']
            if span:
                years = re.findall(r'\b(?:19|20)\d{2}\b', span)
                missing = [y for y in years if y not in atlas_span]
                if missing:
                    raise SystemExit(
                        'atlas time span for %s (%r) no longer supports the years '
                        'the page claims (%r) - update PROFILE_NOTES'
                        % (name, atlas_span, span))
            record['coverage'] = coverage
            record['span'] = span
            record['note'] = '%s · %s' % (coverage, span) if span else coverage
        elif kind == 'none':
            record['note'] = 'No public eviction data in our directory of state sources.'
        else:
            record['note'] = 'Public eviction data published elsewhere: %s.' % record['source']

        states[fips] = record

    payload = {
        'built_by': 'code/build_home_map_data.py',
        'roster_from': 'all_states/index.html',
        'profiles_from': 'eviction_data_atlas/atlas.json (%s)' % atlas['built_from'],
        'counts': counts,
        'states': states,
    }
    with open(OUT, 'w', encoding='utf-8') as fh:
        json.dump(payload, fh, indent=1, sort_keys=True)
        fh.write('\n')
    print('wrote %s' % os.path.relpath(OUT, REPO))
    print('  ' + ' '.join('%s=%d' % kv for kv in sorted(counts.items())))

    n = inline(COVERAGE_MAP, 'state-coverage', payload)
    print('inlined %d bytes into %s' % (n, os.path.relpath(COVERAGE_MAP, REPO)))

    metros = json.load(open(METROS, encoding='utf-8'))
    n = inline(HPRM_MAP, 'hprm-metros', metros)
    print('inlined %d bytes (%d metros) into %s'
          % (n, len(metros), os.path.relpath(HPRM_MAP, REPO)))


if __name__ == '__main__':
    main()
