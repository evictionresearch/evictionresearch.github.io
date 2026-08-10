# What the ERN Website Should Be (August 10, 2026)

> The desk-clearing review. `SITE-CENSUS-2026-08.md` says what exists and what is
> reachable. `DESIGN-STATE-2026-07.md` listed the open design questions. This
> document answers them, consolidates the decisions scattered across the repos
> into one place, and ends with the ordered plan. When Tim approves it, the
> decided parts get folded into a rewritten `WEBDESIGN.md` and both older docs
> retire.
>
> Method. Every claim was verified this session against a named file, branch, or
> live URL. Sources are cited inline. Nothing is from memory. Items that could
> not be verified are marked as such rather than asserted.

---

## 1. The answer

**The website is the public evidence file of a research network whose goal is
national change, argued through data.** Tim's own formulation, given 2026-08-10,
is the north star. Grand change at the national scale, using data for evidence,
informing policy for equity.

Everything on the site should serve one of three claims, each of which is
already true and already documented internally:

1. **We measure what no federal agency measures**, with one documented method,
   replicated state by state, published with code and citations.
   (The profiles, the pipeline, the HPRM, the two new reports.)
2. **The measurements change outcomes.** ERN data anchored the first
   fair-housing challenges to eviction-record screening (Smith v. Wasatch 2017,
   Legal Aid Chicago v. Hunter Properties 2023, the Oak Park HUD matter) and
   supported reform in Washington and Baltimore. Source, verified this session:
   `library/legal_impact/README.md`, roles Tim-confirmed. **This claim is
   almost invisible on the current site.** Closing that gap is the single
   highest-value content addition available (§8).
3. **It is a network, not a center.** Publishing with courts, legal aid,
   agencies, and universities, not at an audience. This is the structural
   differentiation from Eviction Lab (`cidrlab/library/brand/
   differentiation-strategy.md` §2) and it is what EDRN, the partners row, and
   the state repos actually are.

Audiences, in priority order for copy decisions: researchers and journalists
who will cite us, legislative and agency staff who will act on us, legal aid
partners who will litigate with us, funders who will read the site as due
diligence, and tenants who need the resources page. When two audiences
conflict, the register that survives peer review wins, because every other
audience trusts the site precisely to the degree it reads as research.

---

## 2. The decisions that bind this site (consolidated)

The cross-repo coalescing Tim asked for. One line each, with the owning file.
These are settled. Do not relitigate them page by page.

| Decision | Owner file |
|---|---|
| Inter only, all weights, no companion font | `BRAND.md` (canonical: `cidrlab/library/brand/ern/BRAND.md`) |
| Red splits `#CC2118` text / `#F9322B` graphics; muted `#586573`; WCAG 2.1 AA sitewide | `BRAND.md`; shipped sitewide with PR #54 |
| Du Bois posture, spirit not surface. Claim-sentence titles with numbers, numbered figures, interpretive descriptions. No cream, no serif, no pastiche | `library/dubois_lineage.md` |
| The unit is **"Figure"**, renamed from "plate" brand-wide 2026-06-28. CSS identifiers (`.plate-*`) stay legacy pending a coordinated sweep | `library/dubois_lineage.md` §History |
| Du Bois citation reads "W. E. B. Du Bois's data plates for the 1900 Paris Exposition", linked to the two Nightingale articles, never to the exhibit's historical title | `library/dubois_lineage.md` §Citation |
| Factual surface, undeniable substance. Titles carry numbers, descriptions never advocate. "We believe" copy is prohibited on data pages | `library/dubois_lineage.md` §Rhetoric + `library/adversarial_review.md` |
| Policy content leads with landlord-aligned levers, honest trend verbs, supply as co-equal, Berkeley as open-methods credibility | `library/adversarial_review.md` §5 |
| Network-not-center positioning; methodology-forward voice; no documentary-pathos photography; DOI and citation blocks on method pages | `differentiation-strategy.md` (its §3.1 slab-serif advice is **dead**, superseded by the 2026-04-29 Inter decision) |
| Charter obligations attach to research products the site presents: use-and-limitations statements, sunset dates, public code | `library/RESEARCH_CHARTER.md` |
| Canonical Berkeley relationship statement, verbatim; no "housed in"; Berkeley is never a funder | `library/docs/berkeley-affiliation/README.md` |
| BIDS and IGS marks and text claims stay off the site until Meredith (BIDS) and IGS conversations happen; Berkeley + Sociology only | Tim, 2026-08-10, applied in PR #56 |
| CiDR Lab does not appear on evictionresearch.net except as a cleared COI disclosure (§6) | Tim 2026-08-10 + `cidrlab/library/memo-coi-status-2026-08-03.md` |
| No AI tells in prose. Em-dash and colon restraint, no arrow glyphs, no punchy headers. Density is the test | `~/.claude/CLAUDE.md`; memory `wr/machine-tells` |

---

## 3. Verdicts on the open questions

These were the seven open items in `DESIGN-STATE-2026-07.md`, plus two new ones
this review surfaced. Recommendation stated first, grounds after.

### 3.1 Homepage. Rework the six-section page on `homepage-v5b`, then ship it. Retire v6.

The six-section structure was approved 2026-05-29 and is the right IA
(HPRM leads, method second, profile index, recent work, action, partnership).
Tim's Aug 10 revert was correct anyway, because the page as built is stale on
four counts, all verified against `homepage-v5b:index.html`:

- 14 user-visible "Plate" strings, written before the 2026-06-28 Figure rename.
- 6 CiDR mentions plus a CiDR lede, written before the COI direction (§6).
- Two headline tells ("We measure it.", "Two arms. One method.") and an arrow
  glyph h2 ("Court records → tracts → demographics").
- The h2 claim "One method, 37 states." 37 is the count of org *repos*
  (`differentiation-strategy.md` §2), not states with a published method. The
  methodology page's own stats bar says "30+ states in the LSC corpus."
  Unverifiable as written; reword to a number we can defend (8 published
  profiles today, 10 with Illinois and Florida).

The rework, on the branch: sections keep plain kickers with **no Plate or
Figure numbering** (the Figure convention is for charts inside profiles and
reports, where a figure is an argument unit with data; homepage sections are
navigation, not argument), CiDR to zero, the four copy fixes, then swap.

**Prototype v6 retires as a homepage candidate.** Verified against
`_prototype-v6/index.html`: it is a funder pitch in page form (its §08 is "the
ask", four-year anchor funding). That structure belongs in a deck. Harvest two
things before deleting: the hero line "Evidence that keeps pace with
displacement." (the best single line any version of this site has produced,
and the recommended hero for the reworked homepage) and the "documentary
evidence" narrative move (a door, a number, a notice) as a candidate for the
Understanding Eviction page's orbit. Hero candidates for Tim, one choice:

1. "Evidence that keeps pace with displacement." (v6; recommended)
2. "Displacement is rarely one event. We measure it." (v5b as built)
3. Keep "Eviction Research Network" name-only (live today; weakest, says nothing)

### 3.2 maps.html. Rebuild it as the canonical Data & Profiles index. Move the 2019 Washington retrospective to the washington repo.

Verified this session: `maps.html` is a 2019 Washington maps retrospective
("Washington Eviction Maps (2019)"), linked from exactly one page
(cityscape-2024.html), carrying the site's worst adversarial tell ("we believe
several policies should be enacted"). Meanwhile the census (§1.2) shows the
site's biggest structural hole is that report discovery lives in four surfaces
that drift apart, and finished work (Illinois, the Washington determinants
report, State of Evictions 2020, the ERA working paper, Bay Area HPRM) is
unreachable. One move fixes both. `maps.html` becomes the index page behind
the "Maps & Profiles" nav item, driven by one machine-readable list (title,
year, geography, type, URL) that the nav, the footer, the us_map iframe, and
the news cards all read from. The 2019 retrospective content moves to
`/washington/`, its natural home beside State of Evictions 2020.

### 3.3 Naming sweep. Six user-visible instances, three changes.

Full case-insensitive inventory across the 11 live pages, verified:

- `methodology.html`, 5 instances. "Our plates carry the spirit of W. E. B.
  Du Bois" (h2) and "organized as numbered Plates" become Figures language.
  The instances quoting "Du Bois's data plates for the 1900 Paris Exposition"
  **stay**, that is the canonical citation phrasing referring to his plates,
  not ours.
- `understanding-eviction.html`, 1 instance, the same canonical citation. Stays.
- All other live pages, zero. The 14 on `homepage-v5b` die in the §3.1 rework.
- CSS class names (`.plate-num` etc.) stay, per the label-vs-identifier note in
  `dubois_lineage.md`. User-visible text only.

### 3.4 Two-template split. Tolerate through the homepage swap, then unify on the content-page pattern.

The split (Bootstrap homepage against Spectral-plus-v5b content pages) is
carried by exactly one page once about/methodology/research all run v5b
primitives. When the reworked homepage ships it inherits v5b anyway. No
separate workstream needed; the split resolves as a side effect of §3.1.

### 3.5 TOC and reading-progress pattern. Adopt as the standard for long reports.

`state-eviction-timeframes/` carries it; `understanding-eviction.html` has the
nav-dropdown variant. Standardize on the SET treatment (header contents,
scroll-spy, progress bar) for any page over roughly 3,000 words. It came from
the hprm_sanmateo reports and has survived contact with real readers.

### 3.6 Nav. Eight slots, contents adjusted, one addition.

Keep: Home · About · Maps & Profiles · News · Reports · Resources · Contact.
Change: Methodology, Glossary, and Cityscape consolidate under one **Methods**
dropdown (they are one subject; Glossary currently hides under Resources).
Add: **Impact** (§8) top-level in the freed slot. Maps & Profiles points at the
rebuilt index (§3.2) and gains Illinois now and Florida when Pages is enabled.
Reports gains the Washington determinants report, State of Evictions 2020, and
the ERA working paper chapter via the index. Bay Area HPRM gets a permanent
home under Maps & Profiles beside National HPRM, ending its dependence on the
rotating recent-work shelf.

### 3.7 Repo hygiene. Delete now.

`_prototype-v1..v6/` (after the §3.1 harvest), `html5up-spectral/` + zip,
`archive/`, `assetsx/`, `index.html.pre-v5b.bak`. Git history preserves all of
it. No decision left blocking this.

### 3.8 New. The em-dash problem is concentrated and large.

Counts across live pages, text nodes only, verified: understanding-eviction
**121**, cityscape-2024 32, methodology 21, glossary 21, research 16,
resources 16, maps 15. Tim's global rule treats em-dash excess as the primary
machine tell, and the primer is the page most likely to be read by exactly the
audiences the site exists for. The purge is the largest single language task on
the site (§5). Glossary gets judged in place, definitional dashes may be
legitimate typography there.

### 3.9 New. Stale factual surfaces found during review.

- `methodology.html:536` TODO asks for the exact Nightingale URLs. They are
  canonical in `library/dubois_lineage.md` §Citation. Closable in minutes.
- The lineage h2 on methodology still says "plates" (§3.3).
- Footer on all 11 pages still claims BIDS and UDP affiliation and "Housed in"
  (§7).

---

## 4. What is worth keeping, what is not

The filter, page by page. "Keep" means content and structure survive with the
language pass; nothing on the site needs a from-scratch rewrite except as noted.

| Page | Verdict |
|---|---|
| index.html (live, old) | Interim only. Dies when the §3.1 rework ships. Its mission copy ("Research for social good. We create things that can't be unseen.") does not migrate |
| homepage-v5b branch | The future homepage, after the four-count rework |
| _prototype-v6 | Retire. Harvest hero line + documentary-evidence move first |
| about.html | Keep as reworked in PR #56 (Academic Home, copy rewrite). Footer still pending |
| understanding-eviction.html | Keep. Flagship explainer, claims verified July 2026. Needs the em-dash purge, the CiDR figcaption fix, and "housed in" removal |
| state-eviction-timeframes/ | Keep. Model page for the house style. One credit-line fix (§6) |
| glossary.html | Keep. Generated page, working pipeline |
| methodology.html | Keep. Close the three §3.9 items; it is the differentiation doc's "show the apparatus" page and mostly already does |
| cityscape-2024.html | Keep. Em-dash sweep only |
| research.html | Keep. Audit "Policies That Work" against the adversarial checklist (lever order, rent-control framing) before calling it perfect |
| resources.html | Keep. Service page; light touch |
| news.html | Keep. Becomes partly index-driven in §3.2 |
| maps.html | Rebuild as index (§3.2); content moves to /washington/ |
| maps/us_map.html | Keep, iframe on the homepage. Other five maps/* standalones archive with the hygiene sweep unless the index wants them |

---

## 5. The language standard

The register Tim asked for, made precise enough to apply without him.

**What stays, and is not campiness.** Claim-sentence titles with numbers are
the design system, not marketing ("Black renters are 19% of renters and 51% of
those threatened with eviction."). The Du Bois posture is the house voice.
Flattening those titles into neutral labels would be a regression, not a
correction.

**What dies, everywhere, on sight.**

- Self-praise and slogan. "Research for social good", "We make things that
  can't be unseen" as public copy, "undeniable statistics", "force for
  advocacy", "mutual amplification of our collective voices". The lineage
  phrase "things that can't be unseen" is an internal design commitment
  (`dubois_lineage.md` §Rhetoric); it describes how a figure should land, and
  stops being true the moment the site says it about itself.
- Advocacy voice on data pages. "We believe several policies should be
  enacted" (maps.html, live today). The adversarial review is explicit that
  this one sentence is what lets a hostile reader dismiss every chart above it.
- Machine tells at density. Em-dashes (§3.8 counts), arrow glyphs in prose and
  headings, colon-riddled headers.
- Unverifiable numbers in display copy ("37 states", §3.1).

**The replacement register**, from `differentiation-strategy.md` §4, which is
already the approved voice: methodological transparency (name the source and
cadence), first-person-plural working voice ("We update this profile monthly
from Legal Services Corporation records"), disparities named with numbers, and
reproducibility stated adjacent to the claim (method, code, citation). Berkeley
appears as the guarantee of open methods, never as authority by affiliation.

**Protected phrases the purge must not touch.** "Amplified the effect" on the
primer is a finding about ERA dose-response, not a tell. Organization names
("Office of Community Empowerment"). The Du Bois citation phrasing. Quoted
material and testimony.

---

## 6. CiDR and conflict-of-interest policy for this site

Grounded in `cidrlab/library/memo-coi-status-2026-08-03.md` and
`cidrlab/library/berkeley-affiliation/coi-review-cidr-uw-edrn.md`, both read in
full this session.

**The interim rule, effective now.** CiDR Lab does not appear on
evictionresearch.net. Not in ledes, not in partnership sections, not in
figure captions. Current live exposure is exactly two mentions, verified:

1. `understanding-eviction.html`, figcaption: "ERN is housed in UC Berkeley's
   Department of Sociology; its applied arm, CiDR Lab, delivers the same
   methods under contract to governments, courts, and nonprofits." Two
   problems in one sentence ("housed in" plus promotional CiDR). Replace with
   the canonical relationship statement, no CiDR.
2. `state-eviction-timeframes/`, data credit line: "Eviction Research Network ·
   UC Berkeley & CiDR Lab · Data compiled July 2026." Becomes "Eviction
   Research Network · UC Berkeley · Data compiled July 2026."

**The end state.** The COI memo records that disclosure paragraphs for both
sites are drafted in `cidrlab/library/coi-disclosures.md`, pending the
checklist (Aaron's UC-employment answer, the practice-matches-promises
confirmation, the emails to Discovery and the COI office). When that clears,
the sanctioned form of CiDR presence on this site is that disclosure paragraph,
specific and Terner-style, most likely on the About page. Until then, zero.

**Watch item, factual accuracy.** Do not describe HPRM as "open-source" in
site copy. The repos are private today, and the COI memo flags a plausible UC
interest in HPRM v1 to be resolved deliberately (open-sourcing or IPIRA). The
Harding letter's phrasing was aspirational on this point. Say "published
methods" or "open methodology" only where the methods genuinely are published.

---

## 7. Berkeley affiliation, remaining site work

Done: About page Academic Home section, marks reduced to Berkeley + Sociology
caption, funders row cleaned, canonical statement in hero and meta (PR #56,
awaiting merge). Resubmission of #0946 sent via Smartsheet 2026-08-10.

Remaining, one PR across all 11 pages, the footer block:

- "Housed in UC Berkeley's Department of Sociology. Affiliated with the
  Berkeley Institute for Data Science (BIDS) and the Urban Displacement
  Project." becomes **"A research program of the UC Berkeley Department of
  Sociology."** (BIDS text claim waits for Meredith exactly as the logo does;
  UDP is historical per `library/ORG.md` and the Harding letter.)
- "© 2026 Eviction Research Network, UC Berkeley Department of Sociology. All
  rights reserved." becomes **"© 2026 Eviction Research Network. All rights
  reserved."** The departmental suffix asserts the campus-unit relationship
  the canonical statement denies.
- The BIDS link in the footer nav list comes out for now; Sociology link stays.
- Zenodo citation line and the accessibility-issue link stay untouched.
- The UE figcaption "housed in" fix rides with this PR (§6).

Still blocked on people, tracked in `library/docs/berkeley-affiliation/
README.md`: BIDS language (Kirstie/Meredith), IGS contact, approved wordmark
on #0946 clearance, CDSS page retirement.

---

## 8. Advertise what is new. The Impact page is the centerpiece.

**Safe to publish now, in priority order.**

1. **An Impact page.** The record already compiled and Tim-confirmed in
   `library/legal_impact/README.md`: Smith v. Wasatch (W.D. Wash. 2017, the
   first FHA challenge to eviction-record screening, built on Tim's King County
   disparity figures), Legal Aid Chicago v. Hunter Properties (N.D. Ill. 2023),
   the Oak Park HUD matter (2023), Baltimore good-cause and Maryland just-cause
   testimony, Washington's 14-day notice and right-to-counsel lineage. All
   public court matters, all citable. This page is claim 2 of §1 made visible,
   it is what a funder, a dean, or an EDRN partner most needs to see, and it is
   the public-safe expression of the strategy in §10. Framed per the
   adversarial playbook (the record is factual and litigated, no advocacy
   verbs needed).
2. EDRN. Washington cohort card is live on News; the reworked homepage's
   current-work band should carry it.
3. The three just-published pieces (Understanding Eviction, State Eviction
   Timeframes, Glossary), featured on the homepage rework.
4. Illinois profile (live, needs links), Florida (needs Pages enabled),
   Washington determinants report, State of Evictions 2020, ERA working paper
   chapter, Bay Area HPRM permanent placement. All ride the §3.2 index.

**Embargoed, do not surface on the site.** HPRM 3.0 (in active development,
`hprm/HPRM_3.0_MUST_DO.md`, display rule still being decided with Karen
Chapple's feedback under review). The Berkeley Law clinic thread (§10). The
Bay Legal collaboration (partner-sensitive). Anything under
`library/sensitive_project_docs/`. EDRN funder strategy.

---

## 9. The cleared desk. Ordered plan.

Supersedes the census phases where they overlap. Each item is one PR-sized
unit. Language perfection (the thing Tim said has to be perfect) is items 2,
4, and 5, and is defined by §5.

| # | Work | Depends on |
|---|---|---|
| 0 | Merge PR #56 (About). One command, Tim | Tim |
| 1 | Footer sweep, 11 pages (§7) + the two CiDR fixes (§6) | nothing |
| 2 | Homepage rework on `homepage-v5b` (§3.1): de-Plate, de-CiDR, hero choice, copy pass, verify numbers. Then swap live | Tim picks hero |
| 3 | maps.html rebuilt as the index; Washington 2019 content moved to /washington/; orphans wired (Illinois, Florida Pages, determinants, SoE 2020, ERA ch., Bay HPRM nav home) (§3.2, §3.6) | 1 |
| 4 | Em-dash purge + naming sweep + Nightingale TODO: understanding-eviction, methodology, cityscape, glossary-judged, research, resources (§3.3, §3.8, §3.9) | nothing |
| 5 | research.html adversarial audit (lever order, rent-control framing) | 4 |
| 6 | Impact page (§8) | 1; content from legal_impact memo |
| 7 | Nav consolidation (Methods dropdown, Impact top-level) (§3.6) | 3, 6 |
| 8 | State-repo publication recoveries, unchanged from census Phase 3: California merge, Minnesota v2 decision, Ohio hand-merge, Indiana decision, hud-era EDA de-publish decision, broken sites (lsc, missouri, presentations, projects) | Tim decisions |
| 9 | Hygiene deletions (§3.7) after v6 harvest | 2 |
| 10 | Rewrite WEBDESIGN.md from this doc; retire DESIGN-STATE and the decided parts of this file | 1..7 |
| 11 | Post-clearance work as it unblocks: COI disclosure paragraph, BIDS/IGS restoration, approved wordmark | external |

Decisions only Tim can make, collected: hero line (§3.1), Minnesota
index.v2 supersede-or-coexist, Ohio 2023 Columbus figures still publishable,
Indiana 2023 branch wanted, hud-era internal reports public or not, and
sign-off on this document.

---

## 10. Strategy appendix. Not for the website.

Recorded here because Tim asked for it in the same breath as the review; none
of this appears in site copy until he says so.

**The north star, in his words (2026-08-10).** Grand change at the national
scale, using data for evidence and informing policy for equity. The site's
role is to be the public proof that the machine exists and works: the method
(§1 claim 1), the record (§1 claim 2), the network (§1 claim 3). Horizon
three, institutionalization, is where the new thread points.

**The Berkeley Law clinic thread.** The draft Tim remembered exists and is
substantial: `~/git/evictionresearch/law/`, seven documents, built 2026-08-07,
private repo. Core concept, a housing justice clinic at Berkeley Law that
trains students to build and defend quantitative evidence in eviction cases,
with EBCLC as the defense arm, ERN as the records infrastructure, and
Sociology's CRELS trainees as the computational pipeline. Ariella Stefanson
(Bay Area Legal Aid) independently proposed the same clinic and is a
practitioner co-founder in waiting; the meeting record is
`library/sensitive_project_docs/california/2026-08-03_bay-legal-ariella.md`.

**Live deadlines in that thread** (from `law/README.md`, written Aug 7):
the next Ariella meeting is **Friday August 14, 11:00**, pitch-deck
brainstorm, Tim brings example figures. Then her supervisor meeting ~Aug 21,
and the DC PolicyLink summit Aug 24 to 28 overlaps the pitch window.

**How the website serves the strategy without mentioning it.** The clinic
pitch's "proof the method works" section cites exactly the litigation and
policy record the Impact page publishes (§8). A dean, a funder, or Bay Legal's
executive director will visit the site as due diligence; what they need to
find is the record, the method, the affiliation stated correctly, and no
conflict-of-interest loose ends. Items 0, 1, 2, and 6 of §9 are, not
coincidentally, the pre-August-21 shortlist.

**Verification discipline for that thread.** The Ariella note and law repo
carry their own unverified-claims registers (FEHA case-law gap, RTC pilot
stats, name spellings). Nothing from them enters site copy or external
documents without the verification the files themselves demand.

---

## Sources read this session

ERN library: `dubois_lineage.md`, `adversarial_review.md`,
`RESEARCH_CHARTER.md`, `ORG.md`, `legal_impact/README.md`,
`docs/berkeley-affiliation/README.md`. CiDR library:
`memo-coi-status-2026-08-03.md`, `berkeley-affiliation/coi-review-cidr-uw-edrn.md`,
`brand/differentiation-strategy.md`. Law: all seven documents' index plus
`00_concept.md` in full, the Bay Legal meeting record. Site: all 11 live pages
at `origin/main`, `homepage-v5b:index.html`, `_prototype-v6/index.html`,
`assets/css/v5b.css`, this repo's `BRAND.md`, `AFFILIATION-BRAND-FIXES.md`,
`DESIGN-STATE-2026-07.md`, `SITE-CENSUS-2026-08.md`. HPRM:
`HPRM_3.0_MUST_DO.md` (embargo check). Global: `~/.claude/memory/MEMORY.md`,
`writing.md`, `research_pedagogy.md`.
