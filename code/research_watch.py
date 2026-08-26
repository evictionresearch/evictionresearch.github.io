#!/usr/bin/env python3
"""Keep the research section honest between visits.

Whenever a Claude Code session opens in this repo, the SessionStart hook in
.claude/settings.json runs `report`. If the research section is past due, it
prints a short brief asking whether to refresh it. Otherwise it prints nothing.

The section has two halves, scheduled separately in code/research-watch.json:

  links   every URL the site cites, checked for rot. Link rot is not
          hypothetical here: a previous sweep found catherinemcauleycenter.org
          redirecting tenants to a squatted domain.
  pubs    eviction scholarship published since the last sweep, from Crossref,
          minus whatever assets/data/research.json already holds.

Modes:
  report  fast, no network. What the hook calls. Prints the brief when due,
          then detaches the two checks so the next session opens with answers
          instead of another question.
  links   check every cited URL. Slow, network. Writes LINKS.md.
  pubs    ask Crossref what is new. Slow, network. Writes PUBS.md.
  ack     record the section as refreshed today. Takes links, pubs, or nothing
          for both. This is what clears the brief.
  status  show the schedule and what is outstanding.

Nothing here edits research.json or any page. It only ever reports.
"""

import concurrent.futures as futures
import difflib
import html
import json
import os
import re
import ssl
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import date, datetime, timedelta, timezone

SELF = os.path.abspath(__file__)
REPO = os.path.dirname(os.path.dirname(SELF))
STATE = os.path.join(REPO, "code", "research-watch.json")
WORK = os.path.join(REPO, "code", ".research-watch")
LINKS_MD = os.path.join(WORK, "LINKS.md")
PUBS_MD = os.path.join(WORK, "PUBS.md")
BIB = os.path.join(REPO, "assets", "data", "research.json")

UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 " \
     "(KHTML, like Gecko) Chrome/126.0 Safari/537.36"

# Public org address, for Crossref's polite pool. Not Tim's personal address.
CROSSREF_MAILTO = "evictions@berkeley.edu"

# Directories that hold dead prototypes, vendored themes, or archived copies.
# Their links are not the live site's problem.
SKIP_DIRS = re.compile(
    r"(^|/)(\.git|archive|assetsx|html5up-spectral|node_modules|_prototype[^/]*|"
    r"_extensions|\.research-watch|docs|data)(/|$)"
)

# A 403 or 429 from a live server means "not a robot, thanks", not "gone".
# LinkedIn answers 999 to anything without a browser session.
BOT_CODES = {401, 403, 405, 429, 503, 999}

# How Crossref is asked. Each framing pulls a different slice of the
# literature; together they cover more than any single query does.
QUERIES = [
    "eviction",
    "eviction filing court records",
    "eviction moratorium renters",
    "emergency rental assistance eviction",
    "right to counsel eviction tenants",
    "housing instability displacement renters",
    "landlord tenant court judgment",
    "residential displacement gentrification neighborhood",
]

# Relevance runs as three gates, in this order, because the vocabulary is
# shared with fields that have nothing to do with housing. Caches evict,
# landslides displace, clouds have tenants. OFF_TOPIC drops those first, which
# is what makes it safe to treat "eviction" itself as conclusive afterwards.
OFF_TOPIC = re.compile(
    r"\bcache|memory management|\bllm\b|\bgpu\b|smartphone|cloud comput|"
    r"multi-?tenant|\bpacket|\bquantum|photon|seismic|landslide|slope stability|"
    r"granular|\bsoil\b|borehole|sediment|glacier|tectonic|cartilage|humeral|"
    r"glenoid|hyoid|craniofacial|surger|surgical|catheter|aquaculture|salmon|"
    r"proteome|membrane protein|dictionary learning|grating|resonant cavity|"
    r"finite element|actuator|\bservo|\bpiston|serverless|keep-alive|"
    r"histone|chromatin|nucleosome|imbibition|\bgenome|transcript|"
    r"warranty (against|in) sale|civil code|sale contract",
    re.I,
)

# Unambiguous once the off-topic senses are gone. Any one of these is enough.
STRONG = re.compile(
    r"evict|unlawful detainer|renter|tenanc|landlord|rental assistance|"
    r"housing instab|housing insecur|housing precar|housing court|rent burden|"
    r"foreclos|homeless|gentrif|right to counsel|housing subsid|rent control|"
    r"section 8|housing voucher|eviction moratorium",
    re.I,
)

# Real terms of art here, but too common elsewhere to stand on their own.
WEAK = re.compile(r"displac|\btenant", re.I)

# What a weak hit has to land in before it counts.
CONTEXT = re.compile(
    r"\bhous\w*|\brent\w*|\btenan\w*|\blandlord|\bdwelling|\bapartment|"
    r"neighborhood|neighbourhood|\bresiden\w*|\burban\b|\bmortgage|"
    r"\bshelter|homeless|\bhousehold",
    re.I,
)


def relevant(text):
    if OFF_TOPIC.search(text):
        return False
    if STRONG.search(text):
        return True
    return bool(WEAK.search(text) and CONTEXT.search(text))

# Soft flag only. The state facet on the research page cannot represent
# non-US work, so these get marked for a decision rather than dropped.
NON_US = re.compile(
    r"\b(england|wales|scotland|britain|british|ireland|dublin|london|"
    r"australia|sydney|melbourne|canada|toronto|ontario|vancouver|quebec|"
    r"netherlands|amsterdam|germany|berlin|sweden|denmark|norway|finland|"
    r"spain|barcelona|madrid|france|paris|italy|milan|portugal|lisbon|"
    r"poland|warsaw|czech|hungary|austria|vienna|switzerland|belgium|"
    r"romania|ukraine|russia|turkey|istanbul|greece|athens|israel|palestine|"
    r"south africa|kenya|nigeria|ghana|ethiopia|uganda|tanzania|egypt|"
    r"india|delhi|mumbai|chennai|kolkata|bangalore|tamil ?nadu|"
    r"pakistan|sindh|karachi|lahore|bangladesh|dhaka|sri lanka|nepal|"
    r"china|shanghai|beijing|hong kong|taiwan|japan|tokyo|korea|seoul|"
    r"indonesia|jakarta|philippines|manila|vietnam|thailand|bangkok|"
    r"malaysia|singapore|brazil|s[aã]o paulo|chile|santiago|peru|lima|"
    r"colombia|bogot[aá]|argentina|buenos aires|mexico city|new zealand|"
    r"global south|jeonse)\b",
    re.I,
)

# Enough to override the flag above. A comparative paper that names US data is
# still worth reading even if it also names another country.
US_SIGNAL = re.compile(
    r"\bU\.?S\.?A?\b|united states|american\b|hud\b|census bureau|"
    r"american community survey|acs\b|eviction lab|county courts?\b",
    re.I,
)

DEFAULTS = {
    "interval_days": {"links": 30, "pubs": 30},
    # When Tim last signed off on the section. This, not the check date, is
    # what the brief counts from, so a background check cannot quietly answer
    # the question on his behalf.
    "links_last_reviewed": None,
    "pubs_last_reviewed": None,
    # When the automated check last ran. Evidence, not sign-off.
    "links_last_checked": None,
    "pubs_last_swept": None,
    # The link sweep and the Crossref query are read-only GETs against sources
    # this site already cites in public. Set false to be asked first instead.
    "auto_check": True,
}


# ---------------------------------------------------------------- state ----

def load_state():
    state = json.loads(json.dumps(DEFAULTS))
    try:
        with open(STATE) as fh:
            state.update(json.load(fh))
    except FileNotFoundError:
        pass
    for key, val in DEFAULTS["interval_days"].items():
        state["interval_days"].setdefault(key, val)
    return state


def save_state(state):
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    with open(STATE, "w") as fh:
        json.dump(state, fh, indent=2, sort_keys=True)
        fh.write("\n")


def days_since(stamp):
    if not stamp:
        return None
    try:
        then = date.fromisoformat(stamp)
    except ValueError:
        return None
    return (date.today() - then).days


def overdue(state, half):
    age = days_since(state.get(f"{half}_last_reviewed"))
    if age is None:
        return True, None
    return age >= state["interval_days"][half], age


# ---------------------------------------------------------------- links ----

def html_files():
    for root, dirs, names in os.walk(REPO):
        rel = os.path.relpath(root, REPO)
        if rel != "." and SKIP_DIRS.search(rel.replace(os.sep, "/")):
            dirs[:] = []
            continue
        for name in sorted(names):
            if name.endswith(".html") and not name.endswith(".bak"):
                yield os.path.join(root, name)


# Scanned tag by tag rather than attribute by attribute, so a preconnect can
# be told from a link. A bare origin under rel="preconnect" is a DNS warm-up,
# not a page, and fonts.googleapis.com answers 404 to a request for it.
TAG = re.compile(r"<([a-zA-Z][\w-]*)\b([^>]*)>")
ATTR = re.compile(
    r"""\b(?:href|src|data-src|poster)\s*=\s*(?:"([^"]*)"|'([^']*)')""", re.I)
REL = re.compile(r"""\brel\s*=\s*(?:"([^"]*)"|'([^']*)')""", re.I)
NOT_A_LINK = {"preconnect", "dns-prefetch", "preload", "prefetch",
              "modulepreload", "manifest"}

# An href assembled by JS at render time, not a path that exists on disk.
TEMPLATED = re.compile(r"\{\{|\$\{|<%|'\s*\+|\+\s*'")


def tag_links(text):
    for _, attrs in TAG.findall(text):
        rel = REL.search(attrs)
        if rel:
            words = (rel.group(1) or rel.group(2) or "").lower().split()
            if NOT_A_LINK & set(words):
                continue
        for dq, sq in ATTR.findall(attrs):
            yield dq or sq


def collect_links():
    """Return (external, internal_misses). Both keyed by URL/path, valued by
    the set of files that cite it."""
    external, internal = {}, {}
    for path in html_files():
        rel = os.path.relpath(path, REPO)
        try:
            with open(path, encoding="utf-8", errors="replace") as fh:
                text = fh.read()
        except OSError:
            continue
        for raw in tag_links(text):
            url = html.unescape(raw.strip())
            if not url or url.startswith(("#", "mailto:", "tel:", "javascript:",
                                          "data:", "//")):
                continue
            if TEMPLATED.search(url):
                continue
            if url.startswith(("http://", "https://")):
                external.setdefault(url.split("#")[0], set()).add(rel)
            else:
                internal.setdefault((rel, url.split("#")[0].split("?")[0]),
                                    None)
    try:
        with open(BIB) as fh:
            for item in json.load(fh)["items"]:
                url = (item.get("url") or "").strip()
                if url.startswith(("http://", "https://")):
                    external.setdefault(url.split("#")[0],
                                        set()).add("research.json")
    except (OSError, KeyError, ValueError):
        pass
    return external, internal


def resolve_internal(internal):
    misses = []
    for (src, target) in sorted(internal):
        if not target:
            continue
        base = os.path.dirname(os.path.join(REPO, src))
        if target.startswith("/"):
            cand = os.path.join(REPO, target.lstrip("/"))
        else:
            cand = os.path.normpath(os.path.join(base, target))
        if os.path.isdir(cand):
            cand = os.path.join(cand, "index.html")
        if not os.path.exists(cand):
            misses.append((src, target))
    return misses


def probe(url):
    ctx = ssl.create_default_context()
    for method in ("HEAD", "GET"):
        req = urllib.request.Request(url, method=method, headers={
            "User-Agent": UA,
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,"
                      "image/avif,image/webp,*/*;q=0.8",
            "Accept-Language": "en-US,en;q=0.9",
        })
        try:
            with urllib.request.urlopen(req, timeout=25, context=ctx) as resp:
                return resp.status, resp.geturl()
        except urllib.error.HTTPError as exc:
            if method == "HEAD":
                continue
            return exc.code, url
        except urllib.error.URLError as exc:
            reason = getattr(exc, "reason", exc)
            if method == "HEAD":
                continue
            return 0, f"{type(reason).__name__}: {reason}"
        except Exception as exc:
            if method == "HEAD":
                continue
            return 0, f"{type(exc).__name__}: {exc}"
    return 0, "no response"


def cmd_links(argv):
    os.makedirs(WORK, exist_ok=True)
    external, internal = collect_links()
    misses = resolve_internal(internal)

    results = {}
    with futures.ThreadPoolExecutor(max_workers=8) as pool:
        jobs = {pool.submit(probe, url): url for url in external}
        for job in futures.as_completed(jobs):
            results[jobs[job]] = job.result()

    dead, blocked, moved = [], [], []
    for url, (code, note) in sorted(results.items()):
        cites = ", ".join(sorted(external[url]))
        # Order matters. LinkedIn's 999 is a refusal, not a server fault, and
        # a numeric range test would swallow it.
        if code in BOT_CODES:
            blocked.append((url, code, cites))
        elif code == 0 or code >= 500 or code in (404, 410):
            dead.append((url, code, note, cites))
        elif note != url and code == 200 and changed_hands(url, note):
            moved.append((url, note, cites))

    today = date.today().isoformat()
    lines = [
        "<!-- ern-research-watch: links -->",
        f"# Cited links, checked {today}",
        "",
        f"{len(external)} external URLs across the site and the bibliography, "
        f"plus {len(internal)} internal references.",
        "",
        f"- {len(external) - len(dead) - len(blocked)} answered normally",
        f"- {len(dead)} failed",
        f"- {len(blocked)} refused a non-browser (bot protection, not rot)",
        f"- {len(misses)} internal paths point at nothing on disk",
        "",
        "A redirect to a different host is worth reading. That is how a lapsed",
        "domain gets handed to whoever bought it next.",
        "",
    ]
    if dead:
        lines += ["## Failed", ""]
        for url, code, note, cites in dead:
            label = code if code else note
            lines.append(f"- `{label}` <{url}>  \n  cited by {cites}")
        lines.append("")
    if misses:
        lines += ["## Internal paths with no file", ""]
        for src, target in misses:
            lines.append(f"- `{target}` in {src}")
        lines.append("")
    if moved:
        lines += ["## Now answering from a different host", ""]
        for url, final, cites in moved:
            lines.append(f"- <{url}>  \n  lands on <{final}>  \n  cited by {cites}")
        lines.append("")
    if blocked:
        lines += ["## Refused a non-browser", "",
                  "Unverified, not confirmed dead. Open by hand if one matters.",
                  ""]
        for url, code, cites in blocked:
            lines.append(f"- `{code}` <{url}>")
        lines.append("")

    with open(LINKS_MD, "w") as fh:
        fh.write("\n".join(lines))

    state = load_state()
    state["links_last_checked"] = today
    state["links_last_result"] = {"checked": len(external), "failed": len(dead),
                                  "blocked": len(blocked),
                                  "internal_missing": len(misses)}
    save_state(state)
    return 0


# A DOI landing on its publisher is the DOI working, not a domain changing
# hands. Same for any other resolver.
RESOLVERS = {"doi.org", "dx.doi.org", "hdl.handle.net", "purl.org",
             "www.doi.org", "doi.acm.org", "bit.ly", "tinyurl.com",
             "ow.ly", "t.co", "lnkd.in"}


def _host(url):
    try:
        return urllib.parse.urlparse(url).netloc.lower().replace("www.", "")
    except ValueError:
        return url


def _domain(url):
    """Last two labels. Enough to tell blog.safecast.org from safecast.org
    (same owner) apart from a domain that has actually changed hands."""
    return ".".join(_host(url).split(":")[0].split(".")[-2:])


def changed_hands(url, final):
    if _host(url) in RESOLVERS or urllib.parse.urlparse(url).netloc.lower() \
            in RESOLVERS:
        return False
    return _domain(url) != _domain(final)


# ----------------------------------------------------------------- pubs ----

def normalize(title):
    return re.sub(r"[^a-z0-9]+", " ", (title or "").lower()).strip()


def strip_jats(text):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", text or "")).strip()


def crossref(query, since, rows=100):
    params = urllib.parse.urlencode({
        "query.bibliographic": query,
        "filter": f"from-created-date:{since},type:journal-article",
        "rows": rows,
        "sort": "created",
        "order": "desc",
        "select": "DOI,title,author,container-title,published,abstract,URL",
        "mailto": CROSSREF_MAILTO,
    })
    req = urllib.request.Request(
        "https://api.crossref.org/works?" + params,
        headers={"User-Agent": f"{UA} (mailto:{CROSSREF_MAILTO})"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return json.load(resp)["message"]["items"]


def cmd_pubs(argv):
    os.makedirs(WORK, exist_ok=True)
    state = load_state()
    since = None
    for i, arg in enumerate(argv):
        if arg == "--since" and i + 1 < len(argv):
            since = argv[i + 1]
    if not since:
        since = state.get("pubs_last_swept") or \
            (date.today() - timedelta(days=90)).isoformat()

    with open(BIB) as fh:
        bib = json.load(fh)
    have_titles = {normalize(i["title"]) for i in bib["items"]}
    have_dois = {m.group(1).lower() for i in bib["items"]
                 for m in [re.search(r"doi\.org/(.+)$", i.get("url") or "")]
                 if m}

    floor = date.today().year - 2
    seen, seen_titles, candidates, errors = set(), set(), [], []
    for query in QUERIES:
        try:
            items = crossref(query, since)
        except Exception as exc:
            errors.append((query, f"{type(exc).__name__}: {exc}"))
            continue
        for it in items:
            doi = (it.get("DOI") or "").lower()
            if not doi or doi in seen or doi in have_dois:
                continue
            title = (it.get("title") or [""])[0]
            norm = normalize(title)
            if not norm or norm in have_titles:
                continue
            year = (it.get("published", {}).get("date-parts") or [[None]])[0][0]
            if not year or year < floor:
                continue
            abstract = strip_jats(it.get("abstract"))
            blob = f"{title} {abstract}"
            if not relevant(blob):
                continue
            if any(difflib.SequenceMatcher(None, norm, h).ratio() > 0.92
                   for h in have_titles):
                continue
            if norm in seen_titles:
                continue
            seen.add(doi)
            seen_titles.add(norm)
            authors = "; ".join(
                f"{a.get('given', '')} {a.get('family', '')}".strip()
                for a in (it.get("author") or [])[:6]) or "unlisted"
            candidates.append({
                "doi": doi,
                "title": title,
                "authors": authors,
                "venue": (it.get("container-title") or [""])[0],
                "year": year,
                "url": it.get("URL") or f"https://doi.org/{doi}",
                "abstract": abstract[:400],
                "found_by": query,
                "non_us": bool(NON_US.search(blob)) and not US_SIGNAL.search(blob),
            })

    candidates.sort(key=lambda c: (c["non_us"], -c["year"], c["venue"],
                               c["title"]))
    today = date.today().isoformat()
    lines = [
        "<!-- ern-research-watch: pubs -->",
        f"# Crossref candidates, swept {today}",
        "",
        f"Registered with Crossref since {since}, across {len(QUERIES)} "
        f"framings, minus the {len(bib['items'])} entries already in "
        "assets/data/research.json.",
        "",
        f"**{len(candidates)} to review.** Nothing here is vetted. Crossref "
        "supplies the metadata; relevance and quality are a judgment call, and "
        "the state facet on the research page cannot represent non-US work.",
        "",
    ]
    if errors:
        lines += ["## Queries that failed", ""]
        lines += [f"- `{q}` — {e}" for q, e in errors] + [""]
    for c in candidates:
        flag = "  `non-US?`" if c["non_us"] else ""
        lines += [
            f"### {c['title']}{flag}",
            f"{c['authors']}  ",
            f"*{c['venue']}* ({c['year']}) · <{c['url']}>  ",
            f"found by `{c['found_by']}`",
            "",
        ]
        if c["abstract"]:
            lines += [f"> {c['abstract']}", ""]

    with open(PUBS_MD, "w") as fh:
        fh.write("\n".join(lines))

    state["pubs_last_swept"] = today
    state["pubs_last_result"] = {"candidates": len(candidates), "since": since,
                                 "query_errors": len(errors)}
    save_state(state)
    return 0


# --------------------------------------------------------------- report ----

def read_session_id():
    """Hooks are handed a JSON payload on stdin. Use its session id so a
    mid-session compaction does not re-print the brief."""
    if sys.stdin is None or sys.stdin.isatty():
        return None
    try:
        return json.loads(sys.stdin.read() or "{}").get("session_id")
    except Exception:
        return None


def stamp_path(name):
    return os.path.join(WORK, name)


def read_stamp(name):
    try:
        with open(stamp_path(name)) as fh:
            return fh.read().strip()
    except OSError:
        return ""


def write_stamp(name, value):
    os.makedirs(WORK, exist_ok=True)
    with open(stamp_path(name), "w") as fh:
        fh.write(value)


def spawn(mode):
    try:
        subprocess.Popen([sys.executable, SELF, mode],
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                         stdin=subprocess.DEVNULL, start_new_session=True)
        return True
    except Exception:
        return False


def summarize(state):
    out = []
    lr = state.get("links_last_result")
    if lr and os.path.exists(LINKS_MD):
        bits = [f"{lr['checked']} URLs", f"{lr['failed']} failed"]
        if lr.get("internal_missing"):
            bits.append(f"{lr['internal_missing']} internal paths missing")
        out.append(f"- `code/.research-watch/LINKS.md`, checked "
                   f"{state.get('links_last_checked')} · " + ", ".join(bits))
    pr = state.get("pubs_last_result")
    if pr and os.path.exists(PUBS_MD):
        out.append(f"- `code/.research-watch/PUBS.md`, swept "
                   f"{state.get('pubs_last_swept')} · {pr['candidates']} "
                   f"Crossref candidates since {pr['since']}")
    return out


def cmd_report(argv):
    session = read_session_id()
    state = load_state()

    due_links, age_links = overdue(state, "links")
    due_pubs, age_pubs = overdue(state, "pubs")
    if not (due_links or due_pubs):
        return 0

    if session and session == read_stamp("last-briefed-session"):
        return 0

    today = date.today().isoformat()
    started = []
    if state.get("auto_check", True) and read_stamp("last-spawn") != today:
        write_stamp("last-spawn", today)
        if due_links and spawn("links"):
            started.append("links")
        if due_pubs and spawn("pubs"):
            started.append("pubs")

    def row(name, due, age, half):
        if not due:
            return None
        when = "never" if age is None else f"{age} days ago"
        return f"| {name} | {when} | every {state['interval_days'][half]} days |"

    rows = [r for r in (row("Links", due_links, age_links, "links"),
                        row("Publications", due_pubs, age_pubs, "pubs")) if r]

    out = [
        "<!-- ern-research-watch -->",
        "# The research section is due for a refresh",
        "",
        "Ask Tim whether he wants it run before starting other work in this",
        "repo, then wait for his answer. Do not touch assets/data/research.json",
        "or any cited link without it.",
        "",
        "| Half | Last reviewed | Interval |",
        "|---|---|---|",
    ] + rows + [""]

    evidence = summarize(state)
    if evidence:
        out += ["Evidence already on disk. Read it before asking, so the",
                "question arrives with numbers rather than a shrug.", ""]
        out += evidence + [""]
    if started:
        out += [f"Running now in the background: {', '.join(started)}. "
                "Results land in", "code/.research-watch/ and will be here "
                "next session.", ""]
    elif not evidence:
        out += ["No evidence gathered yet. To collect it:", "",
                "    python3 code/research_watch.py links",
                "    python3 code/research_watch.py pubs", ""]

    out += [
        "Refreshing means two things. Confirm every cited URL still resolves to",
        "what it claims, and look for eviction research published since the last",
        "sweep. Crossref metadata is authoritative for citations; a search",
        "snippet is not, and a DOI must never be written from memory.",
        "",
        "When it is done and Tim has seen it: `python3 code/research_watch.py ack`",
    ]
    sys.stdout.write("\n".join(out) + "\n")
    if session:
        write_stamp("last-briefed-session", session)
    return 0


def cmd_ack(argv):
    halves = [a for a in argv if a in ("links", "pubs")] or ["links", "pubs"]
    state = load_state()
    today = date.today().isoformat()
    for half in halves:
        state[f"{half}_last_reviewed"] = today
    save_state(state)
    write_stamp("last-briefed-session", "")
    print(f"Marked reviewed today: {', '.join(halves)}.")
    print(f"Next brief in {min(state['interval_days'][h] for h in halves)} days.")
    return 0


def cmd_status(argv):
    state = load_state()
    print(f"state    : {os.path.relpath(STATE, REPO)}")
    print(f"reports  : {os.path.relpath(WORK, REPO)}/")
    print(f"auto     : {'on' if state.get('auto_check', True) else 'off'}"
          "  (set auto_check false in the state file to be asked first)")
    print()
    for half, label in (("links", "Links"), ("pubs", "Publications")):
        due, age = overdue(state, half)
        when = "never" if age is None else f"{age} days ago"
        print(f"{label:<14} reviewed {when:<16} "
              f"every {state['interval_days'][half]} days   "
              f"{'DUE' if due else 'ok'}")
    print()
    for key in ("links_last_checked", "links_last_result",
                "pubs_last_swept", "pubs_last_result"):
        if state.get(key) is not None:
            print(f"  {key:<20} {json.dumps(state[key])}")
    return 0


MODES = {"report": cmd_report, "links": cmd_links, "pubs": cmd_pubs,
         "ack": cmd_ack, "status": cmd_status}

if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else "report"
    if mode not in MODES:
        print(f"usage: {os.path.basename(SELF)} [{'|'.join(MODES)}]",
              file=sys.stderr)
        sys.exit(2)
    sys.exit(MODES[mode](sys.argv[2:]))
