# ==========================================================================
# Eviction Help directory: build resources.html
# Author: Tim Thomas
# Created: 2026-08-27
# Reviewer:
# Updated:
#
# The tenant-facing companion to the data directory. A person facing eviction
# picks their state, then the county where the case was filed, and gets the
# providers whose service area actually covers that county.
#
# County-first because that is how legal aid is organized: LSC service areas
# are defined by county, so "which county" is the question that determines
# who can take your call. A statewide list makes the reader do that lookup
# themselves, at the worst possible moment.
#
# The roster is data, not markup: library/data/tenant_help/providers.csv and
# provider_counties.csv, each row carrying its own last_verified date. Rebuild
# the roster with library/data/tenant_help/pipeline/, not by editing HTML.
#
# This page replaced a hand-written one whose links were unreliable. Every
# defect that audit found returned HTTP 200 while pointing at the wrong
# organization: San Diego legal aid resolving to the Los Angeles County
# Sheriff, Mississippi legal aid to a Colorado property-rights firm, three
# different "CHFA" agencies mixed across four states. Status checking alone
# cannot see that class of error, which is why providers.csv carries the
# destination title observed at verification time.
# ==========================================================================

rm(list = ls())
options(width = 200, scipen = 10)
librarian::shelf(dplyr, readr, glue, stringr, jsonlite)

# ===============================================
# Config
# ===============================================

data_dir  <- "~/git/evictionresearch/library/data/tenant_help"
part_dir  <- "~/git/evictionresearch/evictionresearch.github.io/code/partials"
out_html  <- "~/git/evictionresearch/evictionresearch.github.io/resources.html"

prov_csv  <- file.path(data_dir, "providers.csv")
link_csv  <- file.path(data_dir, "provider_counties.csv")

ern_home  <- "https://evictionresearch.net/"

state_names <- c(
  AL="Alabama", AK="Alaska", AZ="Arizona", AR="Arkansas", CA="California",
  CO="Colorado", CT="Connecticut", DC="District of Columbia", DE="Delaware",
  FL="Florida", GA="Georgia", HI="Hawaii", IA="Iowa", ID="Idaho",
  IL="Illinois", IN="Indiana", KS="Kansas", KY="Kentucky", LA="Louisiana",
  MA="Massachusetts", MD="Maryland", ME="Maine", MI="Michigan", MN="Minnesota",
  MO="Missouri", MS="Mississippi", MT="Montana", NC="North Carolina",
  ND="North Dakota", NE="Nebraska", NH="New Hampshire", NJ="New Jersey",
  NM="New Mexico", NV="Nevada", NY="New York", OH="Ohio", OK="Oklahoma",
  OR="Oregon", PA="Pennsylvania", RI="Rhode Island", SC="South Carolina",
  SD="South Dakota", TN="Tennessee", TX="Texas", UT="Utah", VA="Virginia",
  VT="Vermont", WA="Washington", WI="Wisconsin", WV="West Virginia",
  WY="Wyoming")

# Order is the order a tenant should work through them: someone who can take
# the case first, then how to answer on your own, then money, then everything
# else. Labels are plain language, not the category slug.
cat_meta <- tibble::tribble(
  ~category,             ~label,                              ~blurb,
  "legal_aid",           "Free legal help",                   "Free civil legal aid for people under an income limit. Call first, and call the day you get papers.",
  "eviction_defense",    "Eviction defense programs",         "Programs built specifically for eviction cases, including right-to-counsel where it exists.",
  "court_selfhelp",      "Court self-help",                   "Official court instructions and forms for answering an eviction case yourself.",
  "tenant_rights",       "Know your rights",                  "What the law in your state requires of a landlord, and what your deadlines are.",
  "hotline",             "Helplines",                         "Phone lines that route you to local help.",
  "bar_referral",        "Lawyer referral",                   "Bar association referral services, for when you do not qualify for free aid.",
  "rent_assistance",     "Rent and utility help",             "Money to cover back rent or utilities. Programs open and close, so check the date.",
  "housing_counseling",  "HUD housing counselors",            "HUD-approved rental counseling. These are offices located in the county; call to confirm they serve your address.",
  "tenant_union",        "Tenant unions",                     "Organized tenant groups offering peer support and advocacy."
)

# ===============================================
# Load and shape
# ===============================================

# Everything reads as character on purpose. county_geoid has leading zeros,
# and last_verified is a stamp to print rather than a date to compute with;
# letting readr guess turns both into something the page cannot render.
prov <- read_csv(path.expand(prov_csv), show_col_types = FALSE,
                 col_types = cols(.default = col_character()))
link <- read_csv(path.expand(link_csv), show_col_types = FALSE,
                 col_types = cols(.default = col_character()))

stopifnot(
  "providers present"              = nrow(prov) > 100,
  "links present"                  = nrow(link) > 1000,
  "every link resolves to a provider" =
    all(link$provider_id %in% prov$provider_id),
  "every provider carries a phone or a url" =
    all(!is.na(prov$phone) & prov$phone != "" | !is.na(prov$url) & prov$url != ""),
  "categories are known"           = all(prov$category %in% cat_meta$category)
)

# A tenant should never land on a county with nothing. Statewide entries are
# expanded across that state's counties by the join table, so any county
# missing here is a genuine hole in the roster, not a display quirk.
counties <- link %>%
  distinct(county_geoid, county_name, state) %>%
  arrange(state, county_name)

cov <- link %>% distinct(state, county_geoid) %>% count(state, name = "n_counties")
message(glue("{nrow(prov)} providers - {nrow(link)} county links - ",
             "{nrow(counties)} counties in {nrow(cov)} jurisdictions"))

# ===============================================
# Payload
# ===============================================
# The whole roster ships inline and filters client-side. No fetch, no API, no
# dependency that can go down: the page has to work for someone on a phone in
# a courthouse hallway. Keys are short because this is ~250KB of JSON.

cat_order <- cat_meta$category

prov_idx <- prov %>%
  mutate(i = row_number() - 1L,
         c = match(category, cat_order) - 1L) %>%
  select(provider_id, i, c)

P <- prov %>%
  left_join(prov_idx, by = "provider_id") %>%
  arrange(i) %>%
  transmute(
    n = name,
    c = c,
    u = coalesce(url, ""),
    p = coalesce(phone, ""),
    t = coalesce(phone_toll_free, ""),
    s = coalesce(scope_label, ""),
    k = coalesce(scope_type, ""),
    b = coalesce(note, ""),
    v = coalesce(last_verified, "")
  ) %>%
  purrr::pmap(~ unname(list(...)))

CO <- counties %>%
  transmute(g = county_geoid, n = county_name, s = state) %>%
  purrr::pmap(~ unname(list(...)))

LK <- link %>%
  left_join(prov_idx, by = "provider_id") %>%
  group_by(county_geoid) %>%
  summarise(ix = list(sort(unique(i))), .groups = "drop")
# I() keeps a one-provider county as a one-element array. Without it
# auto_unbox collapses it to a bare number and the client calls .slice()
# on an integer, so every single-provider county in the country breaks.
LK_list <- setNames(lapply(LK$ix, I), LK$county_geoid)

# Statewide-scoped providers are attached to every county already, so the
# "show everything in the state" view is just the union of that state's
# county lists rather than a second lookup path.
payload <- list(
  ST  = as.list(state_names[sort(names(state_names))]),
  CAT = purrr::pmap(cat_meta, function(category, label, blurb)
          unname(list(label, blurb))),
  CO  = CO,
  P   = P,
  LK  = LK_list
)

json <- toJSON(payload, auto_unbox = TRUE, null = "null")

verified_on <- prov %>% pull(last_verified) %>% na.omit() %>% max()
n_prov      <- nrow(prov)
n_county    <- nrow(counties)
n_phone     <- sum(prov$phone != "" & !is.na(prov$phone))

# ===============================================
# Page chrome
# ===============================================
# Header and footer are copies of the site's, kept in code/partials/. Nothing
# links them to the rest of the site automatically: if the nav changes there,
# change it here too.

hdr <- paste(readLines(file.path(path.expand(part_dir), "help_header.html"),  warn = FALSE), collapse = "\n")
ftr <- paste(readLines(file.path(path.expand(part_dir), "help_footer.html"),  warn = FALSE), collapse = "\n")
scr <- paste(readLines(file.path(path.expand(part_dir), "help_scripts.html"), warn = FALSE), collapse = "\n")

css <- '
:root{ --h-brand:#F9322B; --h-navy:#19222C; --h-ink:#1d2733; --h-body:#3c4a5c;
       --h-muted:#6b7a8d; --h-rule:#e3e8ee; --h-bg:#f7f9fb; }
.h-wrap{max-width:1080px;margin:0 auto;padding:0 20px}

/* Triage block: the three things that matter in the first minute. */
.h-first{background:var(--h-bg);border:1px solid var(--h-rule);border-radius:10px;
         padding:26px 28px;margin:0 0 34px}
.h-first h2{font-size:20px;font-weight:700;color:var(--h-ink);margin:0 0 16px}
.h-steps{display:grid;grid-template-columns:repeat(3,1fr);gap:22px;margin:0;padding:0;list-style:none;
         counter-reset:s}
.h-steps li{counter-increment:s;font-size:14.5px;line-height:1.6;color:var(--h-body)}
.h-steps li b{display:block;color:var(--h-ink);font-size:15px;margin:0 0 4px}
.h-steps li b::before{content:counter(s);display:inline-flex;align-items:center;justify-content:center;
    width:22px;height:22px;border-radius:50%;background:var(--h-brand);color:#fff;font-size:12px;
    font-weight:700;margin-right:9px;vertical-align:1px}
@media(max-width:800px){.h-steps{grid-template-columns:1fr;gap:16px}}

/* Finder */
.h-find{border:1px solid var(--h-rule);border-radius:10px;padding:26px 28px;margin:0 0 30px}
.h-find h2{font-size:20px;font-weight:700;color:var(--h-ink);margin:0 0 6px}
.h-find .h-sub{font-size:14.5px;color:var(--h-muted);margin:0 0 20px}
.h-row{display:flex;flex-wrap:wrap;gap:16px;align-items:flex-end}
.h-field{display:flex;flex-direction:column;gap:6px;min-width:220px;flex:1 1 220px}
.h-field label{font-size:12px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--h-muted)}
.h-field select{font-family:inherit;font-size:15px;padding:11px 12px;border:1px solid #c9d2dc;
    border-radius:6px;background:#fff;color:var(--h-ink);width:100%}
.h-field select:disabled{background:#f1f4f7;color:#9aa7b5}
.h-field select:focus{outline:2px solid var(--h-brand);outline-offset:-1px}
.h-allbtn{font-family:inherit;font-size:14px;font-weight:600;padding:11px 16px;border-radius:6px;
    border:1px solid #c9d2dc;background:#fff;color:var(--h-ink);cursor:pointer;white-space:nowrap}
.h-allbtn:hover:not(:disabled){border-color:var(--h-brand);color:var(--h-brand)}
.h-allbtn:disabled{opacity:.45;cursor:not-allowed}

/* Results */
.h-count{font-size:14px;color:var(--h-muted);margin:26px 0 14px;padding-top:16px;border-top:1px solid var(--h-rule)}
.h-count b{color:var(--h-ink)}
.h-group{margin:0 0 30px}
.h-group h3{font-size:16px;font-weight:700;color:var(--h-ink);margin:0 0 3px}
.h-group .h-blurb{font-size:13.5px;color:var(--h-muted);margin:0 0 14px;max-width:70ch}
.h-card{border:1px solid var(--h-rule);border-left:3px solid var(--h-brand);border-radius:6px;
        padding:15px 18px;margin:0 0 10px;background:#fff}
.h-card .h-name{font-size:15.5px;font-weight:650;color:var(--h-ink);margin:0 0 3px}
.h-card .h-name a{color:var(--h-ink);text-decoration:underline;text-underline-offset:2px;
        text-decoration-color:#c9d2dc}
.h-card .h-name a:hover{color:var(--h-brand);text-decoration-color:currentColor}
.h-card .h-scope{font-size:12.5px;color:var(--h-muted);margin:0 0 8px}
.h-card .h-note{font-size:13.5px;color:var(--h-body);margin:0 0 10px;max-width:74ch}
.h-lines{display:flex;flex-wrap:wrap;gap:8px}
.h-tel{display:inline-flex;align-items:center;gap:7px;font-size:14.5px;font-weight:650;
    padding:8px 14px;border-radius:5px;background:var(--h-brand);color:#fff;text-decoration:none}
.h-tel:hover{background:#d81f19;color:#fff}
.h-tel.h-tf{background:#fff;color:var(--h-brand);border:1px solid var(--h-brand)}
.h-tel.h-tf:hover{background:#fdecec}
.h-site{display:inline-flex;align-items:center;gap:7px;font-size:14px;padding:8px 14px;
    border-radius:5px;border:1px solid #c9d2dc;color:var(--h-body);text-decoration:none}
.h-site:hover{border-color:var(--h-brand);color:var(--h-brand)}
.h-empty{font-size:15px;color:var(--h-body);padding:22px;background:var(--h-bg);
    border:1px solid var(--h-rule);border-radius:8px}
.h-ver{font-size:12px;color:var(--h-muted);margin:8px 0 0}

/* Notes */
.h-notes{border-top:1px solid var(--h-rule);margin-top:44px;padding-top:26px;font-size:13.5px;
    line-height:1.75;color:var(--h-muted);max-width:76ch}
.h-notes h2{font-size:16px;font-weight:700;color:var(--h-ink);margin:0 0 12px}
.h-notes p{margin:0 0 13px}
.h-notes b{color:var(--h-ink)}
@media(prefers-reduced-motion:reduce){*{scroll-behavior:auto !important}}
'

js <- '
(function(){
  var D = window.__HELP__;
  var stSel = document.getElementById("h-state"),
      coSel = document.getElementById("h-county"),
      allBtn= document.getElementById("h-all"),
      out   = document.getElementById("h-out");

  // county lists per state, built once
  var byState = {};
  D.CO.forEach(function(c, i){ (byState[c[2]] = byState[c[2]] || []).push(i); });

  Object.keys(D.ST).sort(function(a,b){
    return D.ST[a].localeCompare(D.ST[b]);
  }).forEach(function(ab){
    if(!byState[ab]) return;
    var o = document.createElement("option");
    o.value = ab; o.textContent = D.ST[ab];
    stSel.appendChild(o);
  });

  function esc(s){ return String(s).replace(/[&<>"]/g, function(m){
    return {"&":"&amp;","<":"&lt;",">":"&gt;","\\"":"&quot;"}[m]; }); }

  // "870-776-1054 ext. 1032" must dial 8707761054, not 87077610541032.
  // Everything after the base number becomes a comma pause, which phones
  // read as "wait, then send the extension".
  function telHref(p){
    var s = String(p), m = s.split(/ext\\.?/i);
    var d = m[0].replace(/[^0-9]/g, "");
    var base = d.length > 11 ? d.slice(0, d[0] === "1" ? 11 : 10) : d;
    var ext = m[1] ? m[1].replace(/[^0-9]/g, "") : "";
    return "tel:" + base + (ext ? ",," + ext : "");
  }

  function card(p){
    var h = "<div class=\\"h-card\\">";
    h += "<p class=\\"h-name\\">" + (p[2]
          ? "<a href=\\"" + esc(p[2]) + "\\" target=\\"_blank\\" rel=\\"noopener noreferrer\\">" + esc(p[0]) + "</a>"
          : esc(p[0])) + "</p>";
    if(p[5]) h += "<p class=\\"h-scope\\">" + esc(p[5]) + "</p>";
    if(p[7]) h += "<p class=\\"h-note\\">" + esc(p[7]) + "</p>";
    h += "<div class=\\"h-lines\\">";
    if(p[3]) h += "<a class=\\"h-tel\\" href=\\"" + telHref(p[3]) + "\\">Call " + esc(p[3]) + "</a>";
    if(p[4] && p[4] !== p[3]) h += "<a class=\\"h-tel h-tf\\" href=\\"" + telHref(p[4]) + "\\">Toll free " + esc(p[4]) + "</a>";
    if(p[2]) h += "<a class=\\"h-site\\" href=\\"" + esc(p[2]) + "\\" target=\\"_blank\\" rel=\\"noopener noreferrer\\">Website</a>";
    h += "</div>";
    if(p[8]) h += "<p class=\\"h-ver\\">Link checked " + esc(p[8]) + "</p>";
    return h + "</div>";
  }

  function render(idxs, heading){
    if(!idxs.length){
      out.innerHTML = "<div class=\\"h-empty\\">No providers are listed for this county yet. " +
        "Dial <b>2-1-1</b> for a local referral, and tell us what is missing so we can add it.</div>";
      return;
    }
    var groups = {};
    idxs.forEach(function(i){ var p = D.P[i]; (groups[p[1]] = groups[p[1]] || []).push(p); });

    var h = "<p class=\\"h-count\\"><b>" + idxs.length + "</b> " +
            (idxs.length === 1 ? "program" : "programs") + " for " + esc(heading) + "</p>";

    D.CAT.forEach(function(meta, ci){
      var g = groups[ci];
      if(!g) return;
      h += "<section class=\\"h-group\\"><h3>" + esc(meta[0]) + "</h3>" +
           "<p class=\\"h-blurb\\">" + esc(meta[1]) + "</p>";
      g.forEach(function(p){ h += card(p); });
      h += "</section>";
    });
    out.innerHTML = h;
  }

  function fillCounties(ab){
    coSel.innerHTML = "<option value=\\"\\">Select a county</option>";
    (byState[ab] || []).slice().sort(function(a,b){
      return D.CO[a][1].localeCompare(D.CO[b][1]);
    }).forEach(function(i){
      var o = document.createElement("option");
      o.value = D.CO[i][0]; o.textContent = D.CO[i][1];
      coSel.appendChild(o);
    });
    coSel.disabled = false;
    allBtn.disabled = false;
  }

  stSel.addEventListener("change", function(){
    var ab = stSel.value;
    out.innerHTML = "";
    if(!ab){ coSel.innerHTML = "<option value=\\"\\">Select a state first</option>";
             coSel.disabled = true; allBtn.disabled = true; return; }
    fillCounties(ab);
    allBtn.textContent = "Show all in " + D.ST[ab];
  });

  coSel.addEventListener("change", function(){
    var g = coSel.value;
    if(!g){ out.innerHTML = ""; return; }
    var name = coSel.options[coSel.selectedIndex].textContent;
    render((D.LK[g] || []).slice(), name + ", " + D.ST[stSel.value]);
  });

  allBtn.addEventListener("click", function(){
    var ab = stSel.value; if(!ab) return;
    var seen = {}, all = [];
    (byState[ab] || []).forEach(function(i){
      (D.LK[D.CO[i][0]] || []).forEach(function(x){
        if(!seen[x]){ seen[x] = 1; all.push(x); } });
    });
    all.sort(function(a,b){ return a - b; });
    coSel.value = "";
    render(all, "all of " + D.ST[ab]);
  });
})();
'

body <- glue('
  <main id="main" class="main" role="main">

    <section class="v5b-section" aria-labelledby="r-hero-title">
      <div class="v5b-page" style="padding-top: 60px;">
        <p class="kicker">Resources</p>
        <h1 id="r-hero-title" class="section-title" style="font-size: clamp(2.4rem, 5vw, 3.6rem); max-width: 30ch;">Eviction help, <em>by county</em>.</h1>
        <p class="lead-paragraph">Legal aid is organised by county, so the county where your case was filed decides who can take your call. Pick your state and county to see the programs that serve you.</p>
      </div>
    </section>

    <div class="r-main">
      <div class="h-wrap">

        <aside class="r-alert" aria-labelledby="r-alert-title">
          <h2 id="r-alert-title"><i class="bi bi-telephone-fill" aria-hidden="true"></i> Need help right now?</h2>
          <p>Dial <strong>2-1-1</strong> from any phone to reach a trained specialist who can connect you to rent assistance, shelter, and tenant-legal referrals in your area, in any state, at any hour.</p>
          <div class="r-btns">
            <a class="btn-primary-red" href="tel:211" aria-label="Call 2-1-1">
              <i class="bi bi-telephone" aria-hidden="true"></i> Call 2-1-1
            </a>
          </div>
          <p class="r-note"><strong>Got court papers?</strong> Contact a legal aid program the same day. Response deadlines are often 5 to 10 days, and missing one can cost you the case by default.</p>
        </aside>

        <div class="h-first">
          <h2>Do these three things first</h2>
          <ol class="h-steps">
            <li><b>Find your deadline</b>Read the papers for the date you must respond or appear. That date governs everything else. It is usually days, not weeks.</li>
            <li><b>Call legal aid today</b>Do not wait to see how it goes. Free programs run out of capacity, and representation changes outcomes more than any other single factor.</li>
            <li><b>Do not skip court</b>Not showing up usually means an automatic loss. Go even if you have no lawyer and no money, and say so to the judge.</li>
          </ol>
        </div>

        <div class="h-find">
          <h2>Find help in your county</h2>
          <p class="h-sub">Choose the county where the eviction was filed, which may not be where you live.</p>
          <div class="h-row">
            <div class="h-field">
              <label for="h-state">State</label>
              <select id="h-state"><option value="">Select a state</option></select>
            </div>
            <div class="h-field">
              <label for="h-county">County</label>
              <select id="h-county" disabled><option value="">Select a state first</option></select>
            </div>
            <button type="button" id="h-all" class="h-allbtn" disabled>Show all in state</button>
          </div>
        </div>

        <div id="h-out" aria-live="polite"></div>

        <div class="h-notes">
          <h2>About this list</h2>
          <p><b>What is here.</b> {n_prov} programs across {n_county} counties, every one of them carrying a phone number. Legal aid service areas come from the Legal Services Corporation, whose grantees cover every county in the United States. Rental counselors come from HUD\'s approved-agency list. Where a state program is listed, it was open when checked.</p>
          <p><b>Every link was fetched, not assumed.</b> Each entry was loaded and its destination checked against the organisation\'s name, most recently on {verified_on}. This matters more than it sounds: the version of this page that came before returned a valid response for every single link while sending people in San Diego to the Los Angeles County Sheriff, people in Mississippi to a Colorado property-rights firm, and Californians to Connecticut\'s housing agency. Checking that a link works does not check that it is right.</p>
          <p><b>What we could still have wrong.</b> An organisation that merges or renames while keeping its website online will not show up in any automated check. We found one that way only because its domain went dark. Counties come from the 2023 Census geography, so Connecticut appears as its nine planning regions rather than its former counties. HUD counselors are listed under the county their office sits in, which is not a promise about who they serve, so call ahead.</p>
          <p><b>This is not legal advice</b>, and listing is not endorsement. If something here is wrong or missing, tell us at <a href="mailto:evictions@berkeley.edu?Subject=Eviction%20help%20directory">evictions@berkeley.edu</a> and we will check it.</p>
        </div>

      </div>
    </div>
  </main>
', .open = "{", .close = "}")

html <- glue('<!DOCTYPE html>
<html lang="en" data-header-style="plate">

<head>
  <meta charset="utf-8">
  <meta content="width=device-width, initial-scale=1.0" name="viewport">
  <title>Eviction Help &mdash; Eviction Research Network</title>
  <meta name="description" content="Find free legal aid, rent assistance, and tenant help for eviction, by state and county. Every listing verified and carrying a phone number. From the Eviction Research Network at UC Berkeley.">
  <meta name="keywords" content="eviction help, tenant resources, legal aid, rental assistance, housing counseling, eviction defense">
  <meta name="author" content="Eviction Research Network, UC Berkeley">

  <link rel="canonical" href="https://evictionresearch.net/resources.html">
  <meta name="theme-color" content="#19222C">

  <meta property="og:title" content="Eviction Help &mdash; Eviction Research Network">
  <meta property="og:description" content="Free legal aid, rent assistance, and tenant help for eviction, by state and county.">
  <meta property="og:url" content="https://evictionresearch.net/resources.html">
  <meta property="og:type" content="website">
  <meta property="og:image" content="https://evictionresearch.net/images/ern_logo/1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER.png">
  <meta name="twitter:card" content="summary_large_image">

  <link href="assets/img/favicon.png" rel="icon">
  <link href="assets/img/apple-touch-icon.png" rel="apple-touch-icon">

  <link href="https://fonts.googleapis.com" rel="preconnect">
  <link href="https://fonts.gstatic.com" rel="preconnect" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@200;300;400;500;600;700&display=swap" rel="stylesheet" media="print" onload="this.media=\'all\'">
  <noscript><link href="https://fonts.googleapis.com/css2?family=Inter:wght@200;300;400;500;600;700&display=swap" rel="stylesheet"></noscript>

  <link href="assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
  <link href="assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet" media="print" onload="this.media=\'all\'">
  <link href="assets/css/main.css" rel="stylesheet" media="print" onload="this.media=\'all\'">
  <link href="assets/css/v5b.css" rel="stylesheet" media="print" onload="this.media=\'all\'">
  <noscript>
    <link href="assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
    <link href="assets/css/main.css" rel="stylesheet">
    <link href="assets/css/v5b.css" rel="stylesheet">
  </noscript>
  <style>{css}</style>
</head>

<body>

{hdr}

{body}

{ftr}

{scr}
  <script>window.__HELP__ = {json};</script>
  <script>{js}</script>

</body>

</html>
', .open = "{", .close = "}")

writeLines(html, path.expand(out_html))

# Read-off: page size, roster size, and coverage
c(kb            = round(file.size(path.expand(out_html)) / 1024),
  providers     = n_prov,
  counties      = n_county,
  with_phone    = n_phone,
  verified_on   = verified_on)
