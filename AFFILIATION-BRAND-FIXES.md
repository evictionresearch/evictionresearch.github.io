# Affiliation & Brand Fixes — TODO

> Added 2026-05-21. Tracks site changes required so ERN represents its UC Berkeley affiliation accurately, in line with what we've told UC Berkeley Brand Protection (Project #0946).

**Context:** Brand Protection is reviewing our request to use the current Berkeley wordmark. ERN's academic home is the **Department of Sociology** (Tim Thomas's appointment under David Harding, effective 2026-04-01); **BIDS** is an affiliation; **CiDR Lab stays off Berkeley marks**. The site copy must match the relationship description we've given Brand Protection and the language in David Harding's endorsement letter.

## Changes required (`about.html` + any shared header/footer)

1. **Move the UC Berkeley logo out of "Organizational Collaborators & Funders."**
   It currently sits in the funders row, which implies Berkeley *funds* ERN. Move it into a distinct **"Academic Home / Affiliations"** area (alongside BIDS).
2. **Soften the institutional claims.**
   Replace "Housed in UC Berkeley's Department of Sociology" and the footer "© 2026 Eviction Research Network, UC Berkeley Department of Sociology" with the canonical statement below.
3. **Apply the canonical relationship statement** wherever ERN's Berkeley relationship is described (About intro, footer, `<meta name="description">`).
4. **Track the legacy CDSS reference.** `cdss.berkeley.edu/project/eviction-research-network` is a 2023 student Discovery project, not our org home — follow up with CDSS to retire/relabel it. (Not a code change here; tracked for completeness.)

## Canonical relationship statement (use verbatim — matches the endorsement letter + Brand Protection reply)

> The Eviction Research Network is a research program led by Dr. Tim Thomas, Assistant Researcher in the UC Berkeley Department of Sociology, which serves as its academic home. ERN is not a separate legal entity or a separate campus unit; its externally funded research is administered through the University.

Short footer/affiliation form:

> A research program of the UC Berkeley Department of Sociology · Affiliated with the Berkeley Institute for Data Science (BIDS).

## Guardrails
- Do **not** describe Berkeley as a "funder."
- Keep **CiDR Lab** off any page bearing the Berkeley name/marks.
- Use only the Brand-Protection-approved wordmark/lockup once confirmed (pending Project #0946).

## Checklist
- [ ] Move UCB logo out of the funders row (`about.html`)
- [ ] Update the "Housed in…" line (`about.html` + shared template)
- [ ] Update footer copyright/affiliation line (shared template)
- [ ] Insert canonical statement (About intro + `<meta>` description)
- [ ] Confirm BIDS affiliation language with Kirstie before publishing
- [ ] Swap to approved Berkeley wordmark once Brand Protection approves
- [ ] Follow up with CDSS to retire/relabel the 2023 project page

_Source drafts (reply to Brand Protection, endorsement letter, BIDS email, talking points): CiDR Lab library, `berkeley-affiliation/`._
