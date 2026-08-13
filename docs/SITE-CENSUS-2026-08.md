# ERN Site Census and Publication Plan (August 10, 2026)

> Companion to `docs/DESIGN-STATE-2026-07.md`. That doc covers *how the site should
> look*. This one covers *what exists, what the public can actually reach, and in
> what order to close the gap.*
>
> Every claim below was checked on 2026-08-10 by one of three methods, marked in
> the tables: **[live]** an HTTP request to evictionresearch.net, **[git]** a read
> of the repository at a named branch, **[api]** the GitHub Pages configuration API.
> Nothing here is inferred from memory.

---

## The one-paragraph version

The site does not have a content problem. It has a publication problem. Eleven
finished or near-finished pieces of work exist and cannot be reached by a member
of the public, and in every case the cause is mechanical rather than editorial:
an unmerged pull request, an unmerged branch, a disabled Pages setting, or a
missing link. Separately, four repositories are publicly serving broken or
template placeholder pages under the evictionresearch.net domain. Almost all of
this is recoverable in a few sittings, and the highest-value single action
(merging PR #54) unblocks three finished report pages at once.

---

## Part 1. Census

### 1.1 Main site, `evictionresearch.github.io`

The live site is served from the `main` branch. Working branch `reports-2026-07`
is 12 commits ahead of it **[git]** and carries PR #54, open since 2026-07-15 **[api]**.

| Page | On `main` (live)? | On branch? | Status |
|---|---|---|---|
| `index.html` | yes | modified | live, current version is older |
| `about.html` | yes | modified | live |
| `news.html` | yes (34 cards) | modified (40 cards) | live, 6 cards behind |
| `research.html` | yes | modified | live |
| `resources.html` | yes | modified | live |
| `methodology.html` | yes | modified | live |
| `maps.html` | yes | modified | live |
| `cityscape-2024.html` | yes | modified | live, mis-citation fix is on the branch only |
| `glossary.html` | **no** | added | **404 live** **[live]** |
| `understanding-eviction.html` | **no** | added | **404 live** **[live]** |
| `state-eviction-timeframes/` | **no** | added | **404 live** **[live]** |

Also stuck behind PR #54: the entire **Reports** nav dropdown, canonical tags on
eight pages, and the Washington 673k correction.

**Readiness of the three unpublished pages.** All three are complete and
internally sound. `understanding-eviction.html` has 17 finished sections with
claim-sentence headings; `state-eviction-timeframes/` has 5. Eight verification
memos in `docs/verification-2026-07/` back the underlying claims. A full internal
link and asset check across all 11 pages returned zero real breakages (two hits
were false positives, a JavaScript template string in `research.html` and a
`tel:211` link in `resources.html`). Confidence: high, verified this session.

**Uncommitted on the working branch.** `news.html` has 28 unstaged lines adding a
"Washington Joins the Eviction Data Response Network" card, carrying its own
inline note that the image is a placeholder borrowed from the 2024 NLP card.

**Orphaned map files.** Five of six standalones in `maps/` have no inbound link
from anywhere on the site (`pre`, `post`, `last_year`, `dur`, `all`). Only
`us_map.html` is used, as the iframe on Plate III **[git]**.

### 1.2 Report and profile sites, separate repositories on the same domain

Nineteen repositories have GitHub Pages enabled **[api]**. All resolve under
evictionresearch.net paths. The front page reaches eight of them.

**Reachable from the front page** (nav dropdown, the Plate III state map, and the
footer all list the same eight): California, Delaware, Indiana, Maryland
(`/maryland/report/baltimore.html`), Minnesota, Ohio (`/ohio/dayton.html`),
Oregon, Washington. Plus National HPRM from Plate I, and HUD ERA and Bay Area
HPRM from Plate IV cards.

**Live and finished, but unreachable from the main site** **[live + git]**:

| What | URL | Size | Reachable from |
|---|---|---|---|
| Cook County Illinois Eviction Filings | `/illinois/` | 18 KB | nowhere |
| Why Washington's eviction filings are at record highs | `/washington/report/determinants/` | 65 KB | nowhere |
| How ICE increased evictions (Minnesota) | `/minnesota/news/2026-05-18_...html` | 75 KB | nowhere |
| ERA Working Paper, Ch. 2 County-Level Analysis (PDF) | `/hud-era/reports/final/...pdf` | 6.5 MB | nowhere |
| Baltimore Evictions presentation | `/maryland/presentation/baltimore_presentation.html` | 8.9 MB | nowhere |
| Menlo Park Anti-Displacement Existing Conditions Report | `/hprm/sanmateo/planning/jurisdictions/menlopark/sandagindex.html` | 86 KB | nowhere |
| HPRM Maps Directory | `/hprm/maps/` | 22 KB | inside HPRM only |
| HPRM Map 2019 and Map 2022 | `/hprm/map-2019.html`, `map-2022.html` | 22 KB each | inside HPRM only |
| Background: USEDR | `/hprm/background-usedr.html` | 33 KB | inside HPRM only |

Two notes on that table. The Menlo Park report is served from a file named
`sandagindex.html`, and the page title and the filename disagree; that needs a
human look before it is linked anywhere. Illinois is a complete profile built
from the same template as the already-published Delaware and Indiana profiles,
with four substantive claim-sentence findings, so by the standard already applied
to its siblings it is ready.

**Reachable only through News**: `/washington/report/State_of_Evictions_2020/`
(the full 2020 UW report, six chapters) and the Oregon Racial Disparities Q1 2024
PDF. Both are linked from `news.html` and nowhere else **[git]**.

**Bay Area HPRM, the case you raised.** `/hprm/bay/` is live and healthy, 67 KB,
titled "Bay Area Housing Precarity Risk Model" **[live]**. You were right that it
is hard to get to. It appears in exactly one place on the front page, as the
middle card of three under Plate IV "Recent Work" (`index.html:380`), plus one
link in `news.html`. It is not in the nav, not in the Reports dropdown, not in
Maps and Profiles, and not linked from the Plate I HPRM section, which points
only at the national model. Because Plate IV is a rotating "recent work" shelf,
the Bay Area model loses its only front-page entry point the moment three newer
items appear.

**Built but with no publication path at all.** Florida has a complete
`index.html` in the repository (18.5 KB, "Florida Eviction Filings", same
template and same five-section structure as Illinois and Delaware) and GitHub
Pages is **disabled** for the repository **[api]**. It cannot be reached by any
URL.

### 1.3 Finished work sitting on unmerged branches

Comparison is against each repository's actual published branch, read from the
Pages API rather than assumed **[api + git]**.

| Repo | Published branch | Branch with the work | Commits ahead | What is stranded |
|---|---|---|---|---|
| california | `main` | `consolidate-eva` | 25 | `index.html` grows 14 KB to **112 KB**, plus a new `lockouts.html`. Includes Eva Winter's copy edits (July 2026) and your grammar and accuracy passes on top. |
| ohio | `main` | `qs-migration` | 48 | An `index.html` (18 KB) covering **Columbus and Dayton**; Julia Greenberg's commit reads "finished adding Columbus to ohio profile". |
| indiana | `main` | `qs-migration` | 36 | `index.html` grows 18 KB to 25 KB, plus `indexOREX.html` (Riya Patwa, 2023). |
| minnesota | `main` | `qs-migration` | 8 | `index.html` grows 170 KB to **241 KB**, plus `index.v2.html` (86 KB), your June 2026 "cross-aisle MN eviction profile", plus Eva's text edits. |
| maryland | `master` | `qs-migration` | 1 | Data pipeline code only. Nothing publishable. |

**California is the largest single gap on the whole site.** The live California
profile is a 14 KB stub. The version with human editing from two people is eight
times larger and has been sitting unmerged since 2026-07-14.

**A hazard in Ohio.** The published `main` branch has `dayton.html` (4.8 MB) and
**no** `index.html`. The `qs-migration` branch has `index.html` and **no**
`dayton.html` **[git]**. These branches diverged rather than progressed, so a
naive merge in either direction destroys a live page. This one needs to be done
by hand.

**Uncommitted page content in state repos.** Washington has an unstaged edit to
`index.qmd` and `index.html` adding a "The report that started this work" callout
that links the 2020 State of Evictions report; it reads as finished. HPRM has
unstaged edits to `docs/index.html`, both map pages, and `EXPLAINER.qmd`, plus an
untracked `review_maplibre/` directory and `HPRM_3.0_MUST_DO.md`. The uncommitted
changes in Minnesota, Oregon, Illinois, and HUD ERA are R scripts and data, not
page content.

### 1.4 Broken and placeholder pages currently served under evictionresearch.net

These are public right now **[live]**.

| URL | What a visitor sees |
|---|---|
| `/lsc/` | A broken build. Raw Pandoc template variables leaked into the HTML and render on the page as literal text: `$LSC Nationwide Evictions$`, `$for(author-meta)$`, `$if(date-meta)$`. |
| `/missouri/` | Boilerplate reading "The UDP Repository Template. Use this repository as a template for all other UDP repositories." |
| `/presentations/` | A 1.9 KB stub. |
| `/projects/` | GitHub's "Site not found" 404, despite Pages being enabled and pointed at a `/docs` folder that does not exist. |
| `/ohio/` | A 4.2 KB rendered README, not a profile. The real Ohio content is at `/ohio/dayton.html`. |
| `/maryland/` | A 4.6 KB stub. The real content is at `/maryland/report/baltimore.html`. |
| `/hprm/sanmateo/.../brisbane/` | A page whose own title is "Jurisdiction-Specific Report Template". |

Also worth a decision: `/hud-era/reports/r1_eda/` and `/r2_validation/` publicly
serve internal exploratory and validation outputs (individual files up to 6 MB,
covering roughly a dozen states). They are not linked from anywhere and they read
as working documents rather than publications.

---

## Part 2. Why work keeps going missing

Three structural causes, all fixable.

**Report discovery is duplicated across four surfaces that have drifted apart.**
A state profile has to be listed in the nav dropdown (`index.html:142`), in the
interactive map (`maps/us_map.html`), in the footer (`index.html:608`), and in
`news.html`. Adding a report means four edits in two file formats, so in practice
some get one or two and none get all four. Illinois got zero.

**"Recent work" is doing the job of an index.** Plate IV is the only front-page
route to Bay Area HPRM and HUD ERA. A shelf that rotates by design cannot also be
the permanent home for a flagship tool.

**Publication state lives in per-repository Git settings that nothing surfaces.**
Whether a finished report is public depends on which branch that particular
repository publishes from, and those differ (`main` for most, `master` for
Illinois, Maryland, and Washington). There is no single place that answers "is
this live?", which is how California ended up eight times smaller in public than
in the repository for a month.

---

## Part 3. Strategy

Four principles, in priority order.

**1. Ship what is already written before writing anything new.** Nothing on the
proposed roadmap adds as much to the site as merging PR #54 and the California
branch. That is roughly 200 KB of human-edited, fact-checked content that already
exists.

**2. Build one canonical report index, and let every other surface read from it.**
A single list, maintained in one place, that carries every report and profile with
its title, year, geography, type, and URL. The nav, the front page, and the News
page all present that same list. This is the change that stops the next Illinois
from happening.

**3. Nothing broken stays on the domain.** A visitor who finds `/lsc/` sees raw
template code under the ERN name. De-publishing takes minutes and is independent
of every other decision here.

**4. Institutional accuracy ships on its own track.** The affiliation fixes are
the only item with an outside party waiting on them, and they carry no aesthetic
risk, so they should not be queued behind design decisions.

---

## Part 4. Ordered task list

Sequenced so that each phase is independently shippable. Effort estimates are
rough working sessions, not hours.

### Phase 0. Land what is already finished

*Unblocks three report pages. Do this first.*

1. Resolve the uncommitted `news.html` EDRN card. Either source the dedicated
   EDRN or Housing Futures Center graphic the inline note asks for, or accept the
   borrowed image and delete the note. Commit.
2. Re-read PR #54's diff against `main` once, top to bottom, with attention to
   the eight modified legacy pages rather than the three new ones.
3. Merge PR #54.
4. Verify live: `glossary.html`, `understanding-eviction.html`, and
   `state-eviction-timeframes/` should all return 200, and the Reports dropdown
   should appear in the header sitewide.

### Phase 1. Institutional accuracy

*Berkeley Brand Protection Project #0946. Independent of all design work.*

**Status of #0946, verified from email 2026-08-10.** The request is stalled, not
approved and not denied. Timeline: on 2026-05-20 Caitlin Conway of Brand
Protection replied asking three clarifying questions. Tim answered on 2026-06-09
with the endorsement letter from David Harding, then Chair of Sociology,
attached. One minute later the same
mailbox sent an automated notice that, effective 2026-05-01, BCBP had become the
Business Contracts Office, that Caitlin Conway and Eryn Hong had **moved to
Marketing and Brand in the Office of Strategic Communications**, and that
`bcbp@berkeley.edu` "will eventually be sunsetted." There has been no substantive
reply in the two months since. The answer almost certainly landed in a mailbox
nobody owns any more.

**Two consequences that change the work below.**

First, the Berkeley wordmark is on the live site right now (`index.html:583`
footer, `about.html:553` funders row) while permission to use it is still
pending. That is the opposite of the intended sequence.

Second, two of Caitlin's three questions were *about the website itself*, and
both remain unfixed today. She asked what the University's role is as an
"organizational collaborator & funder" as stated on `about.html` (that is
`AFFILIATION-BRAND-FIXES.md` item 1), and she flagged that the CDSS page still
lists ERN under the College of Computing, Data Science & Society (checklist item
7). Fixing those is not merely good practice, it is answering an open question
from the reviewer.

Recommended immediate action, ahead of the code changes: re-send the 2026-06-09
reply to a live address. Either resubmit through the Permission Request
Smartsheet form referenced in the transition notice, or write directly to Caitlin
Conway and Eryn Hong at Strategic Communications, referencing Project #0946 and
noting that the original answer went to the sunsetting BCBP mailbox.

5. Apply `AFFILIATION-BRAND-FIXES.md` items 1 through 3. All are still unapplied,
   verified today: the canonical relationship statement appears nowhere in any
   HTML file on the site, the UC Berkeley logo still sits in the
   "Organizational Collaborators & Funders" row (`about.html:553`, inside the
   section spanning lines 531 to 564), and the footer still reads
   "© 2026 Eviction Research Network, UC Berkeley Department of Sociology"
   (`index.html:641`, `about.html:636`).
6. Fix `index.html:193`, which currently reads "the academic arm of CiDR Lab,
   housed in UC Berkeley's Department of Sociology". This conflicts with the
   canonical statement, and it places CiDR Lab on a page that carries the Berkeley
   wordmark (`index.html:583`), against the explicit guardrail in the fixes doc.
7. Leave two checklist items open pending outside parties: BIDS affiliation
   language (Kirstie) and the approved Berkeley wordmark (Brand Protection).

### Phase 2. Stop serving broken pages

*Fast, low risk, no dependencies. Can be done in one sitting.*

8. Disable GitHub Pages for `lsc`, `missouri`, `presentations`, and `projects`,
   or repair them. Recommendation: disable now, repair later if wanted. LSC in
   particular is a broken Pandoc build, not a content problem.
9. Decide what `/ohio/` and `/maryland/` should serve. Right now both roots are
   stubs while the real content sits one level down. Simplest fix is a redirect
   from each root to the real page.
10. Decide whether `/hud-era/reports/r1_eda/` and `/r2_validation/` should remain
    publicly accessible. If yes, they need an index and a framing note. If no,
    move them out of the published path.
11. Remove or de-publish the `brisbane` jurisdiction template page, which
    currently serves under the HPRM path with "Template" in its title.

### Phase 3. Publish the finished state work

*Ordered by value recovered.*

12. **California.** Merge `consolidate-eva` into `main`. Verify `/california/`
    grows to the full profile and that `/california/lockouts.html` resolves.
    This is the single biggest recovery on the site.
13. **Minnesota.** Decide first whether `index.v2.html` supersedes `index.html`
    or sits beside it, then merge `qs-migration` into `main`. Do not merge before
    that decision, because the branch contains both.
14. **Illinois.** No merge needed, it is already live. Add it to the eight-state
    lists in Phase 4.
15. **Florida.** Enable GitHub Pages on the repository, confirm `/florida/`
    resolves, then add it to the lists.
16. **Ohio.** Hand merge only. `main` has `dayton.html` and no `index.html`;
    `qs-migration` has `index.html` and no `dayton.html`. The goal is a single
    branch carrying both the Columbus and Dayton content. Confirm the 2023
    Columbus figures are still ones you want to publish before doing the work.
17. **Indiana.** Decide whether the 2023 `qs-migration` work is still wanted. If
    yes, merge. If no, close the branch so it stops registering as pending.
18. **Washington.** Commit the finished "The report that started this work"
    callout, which also gives the 2020 State of Evictions report a permanent
    inbound link.

### Phase 4. One report index

*The structural fix. This is where the Bay Area HPRM problem actually gets solved.*

19. Write a single machine-readable list of every published report and profile
    (title, year, geography, type, URL, one-line description). A small JSON or
    YAML file in the main repo is enough. Seed it from the census in Part 1.
20. Rebuild the four discovery surfaces to read from that list rather than each
    carrying its own copy: the nav dropdowns, `maps/us_map.html`, the footer, and
    the `news.html` cards.
21. Decide the top-level split. Currently "Maps & Profiles" holds state profiles
    and "Reports" holds the three main-site report pages, but HPRM, HUD ERA, the
    Washington determinants report, and the 2020 State of Evictions report fit
    neither cleanly. This is open decision 5 in `DESIGN-STATE-2026-07.md` and
    should be settled here rather than separately.
22. Give Bay Area HPRM and National HPRM permanent homes in the nav, and link Bay
    Area from the Plate I HPRM section so the two models sit together. Plate IV
    then goes back to being a rotating shelf rather than the only route in.

### Phase 5. Wire in the orphans

*Depends on Phase 4 existing. Each is a single entry in the list.*

23. Add to the index: Washington determinants, the 2020 State of Evictions
    report, the Minnesota ICE article, the HPRM maps directory and both map
    years, USEDR background, the ERA working paper PDF, and the Oregon Racial
    Disparities PDF.
24. Resolve the Menlo Park report before listing it. The filename
    (`sandagindex.html`) and the page title (Menlo Park) disagree, and the News
    page separately carries a "San Diego Anti-Displacement Study" entry. Confirm
    which report is which.
25. Decide the fate of the Baltimore presentation (8.9 MB). Presentations may
    warrant their own category rather than sitting with reports.
26. Decide on the five orphaned `maps/*.html` files in the main repo: link,
    keep as embed-only, or archive. This is open decision from the July audit and
    is now the last unresolved reachability item on the main site.

### Phase 6. Hygiene and documentation

*Carried forward from `DESIGN-STATE-2026-07.md`, unchanged.*

27. Decide the fate of `_prototype-v6/`, then delete `_prototype-v1` through
    `v6`, `html5up-spectral/` and its zip, `archive/`, `assetsx/`, and
    `index.html.pre-v5b.bak`. Git history preserves all of it.
28. Settle the two-template split (Bootstrap front page against Spectral content
    pages) and the TOC and reading-progress pattern question.
29. Rewrite `docs/WEBDESIGN.md` to match reality, and retire both
    `DESIGN-STATE-2026-07.md` and this file into it.

---

## Decisions needed from you

These block specific tasks and cannot be resolved from the repository.

1. Minnesota: does `index.v2.html` replace `index.html` or sit beside it? (blocks 13)
2. Ohio: are the 2023 Columbus figures still publishable? (blocks 16)
3. Indiana: is the 2023 branch work still wanted? (blocks 17)
4. HUD ERA: should the internal EDA and validation reports stay public? (blocks 10)
5. Menlo Park or San Diego: which report is `sandagindex.html`? (blocks 24)
6. Is the top-level split "Maps & Profiles" against "Reports" still right once
   HPRM, HUD ERA, and the standalone reports are added? (blocks 21)
