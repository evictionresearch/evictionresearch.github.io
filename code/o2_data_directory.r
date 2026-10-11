# ==========================================================================
# U.S. Eviction Data Directory: build index.html
# Author: Tim Thomas
# Created: 2026-08-13
# Reviewer:
# Updated:
#
# One page listing, for every state, where eviction data lives: the primary
# link the ERN homepage map points to, then every active public source the
# July 2026 atlas verified. This is the national companion to the state
# profiles and the v1 landing for states with several efforts. Writes
# ../eviction-data-atlas.html, served at evictionresearch.net/eviction-data-atlas.html.
# The page used to live at /all_states/; that path now holds a redirect stub.
#
# Moved here from the all_states repo on 2026-08-28. It generated a file in this
# repo from another one, which meant code/build_home_map_data.py parsed markup it
# could not see, and that split had already gone stale once. The rosters below
# also mirror us_state_map_urls.r, now a sibling in this same directory rather
# than a cross-repo promise. The routing authority is still the tiered strategy
# census (library/docs/state_profile_expansion.md, "The strategy census"). Edit
# the census first, then both scripts. Tier 3 and 4 states move to ern_url as
# their pages ship.
#
# Paths are absolute ~/git/... to match o3_tenant_help.r, the house convention
# for R generators here.
# ==========================================================================

rm(list = ls())
options(width = 200, scipen = 10)
librarian::shelf(dplyr, readr, glue, stringr, tibble)

# ===============================================
# Config
# ===============================================

inv_csv  <- "~/git/evictionresearch/library/data/state_profile_readiness/d2_public_source_inventory.csv"
out_html <- "~/git/evictionresearch/evictionresearch.github.io/eviction-data-atlas.html"
# "The State of Eviction Data" is the companion report, built by
# library/code/eviction_data_atlas/build_page.py and deployed to the site root.
# It used to claim the eviction-data-atlas slug this page now occupies; it was
# moved to its own title on 2026-08-28 so the two are not one slash apart.
atlas_url <- "state-of-eviction-data/"

ern_url <- c(
    CA = 'https://evictionresearch.net/california/',
    WA = 'https://evictionresearch.net/washington/',
    DE = 'https://evictionresearch.net/delaware/',
    IN = 'https://evictionresearch.net/indiana/',
    MN = 'https://evictionresearch.net/minnesota/',
    OR = 'https://evictionresearch.net/oregon/',
    MD = 'https://evictionresearch.net/maryland/report/baltimore.html',
    OH = 'https://evictionresearch.net/ohio/dayton.html')

lsc_slug <- c(
    AK = 'alaska',        AR = 'arkansas',       KY = 'kentucky',
    MT = 'montana',       ND = 'north-dakota',   NY = 'new-york',
    OK = 'oklahoma',      SC = 'south-carolina', TN = 'tennessee',
    UT = 'utah',          VT = 'vermont',        WV = 'west-virginia')

partner_label <- c(
    AZ = 'Arizona courts eviction dashboard', CO = 'Colorado Judicial eviction dashboard',
    CT = 'CTData eviction map',               DC = 'Office of the Tenant Advocate',
    FL = 'Shimberg Center housing data clearinghouse (UF)',
    GA = 'Metro Atlanta eviction tracker (ARC)',
    HI = "Hawai'i Judiciary annual report",
    ID = 'Idaho Policy Institute eviction reports',
    IL = 'Illinois circuit court statistics', LA = 'Eviction Lab, New Orleans',
    MA = 'Massachusetts Trial Court dashboard',
    ME = 'Maine Judicial monthly FED report', MI = 'Michigan SCAO dashboard',
    MO = 'Eviction Lab tracking, Missouri',   NC = 'North Carolina courts dashboard',
    NE = 'Nebraska courts eviction report',   NH = 'New Hampshire courts data reports',
    NJ = 'New Jersey Judiciary statistics',   NM = 'Eviction Lab tracking, New Mexico',
    NV = 'Nevada courts annual reports',      PA = 'Eviction Lab tracking, Pennsylvania',
    RI = 'RIHousing evictions dashboard',     TX = 'Texas Office of Court Administration',
    VA = 'virginiacourtdata.org',             WI = 'Wisconsin Eviction Data Project',
    WY = 'Wyoming courts annual report')

partner_url <- c(
    AZ = 'https://www.azcourts.gov/statistics/Interactive-Data-Dashboards/Justice-Court-Evictions',
    CO = 'https://coloradojudicial.gov/eviction-filings',
    CT = 'https://evictionmap.ctdata.org/',
    DC = 'https://ota.dc.gov/page/monthly-eviction-data',
    FL = 'https://flhousingdata.shimberg.ufl.edu/eviction-foreclosure',
    GA = 'https://atlregional.github.io/eviction-tracker/',
    HI = 'https://www.courts.state.hi.us/wp-content/uploads/2026/02/FY2025_annual_report_statistical_supplement_Final_Draft-2.pdf',
    ID = 'https://www.boisestate.edu/sps-ipi/evictions-in-idaho/evictions-in-idaho-2/',
    IL = 'https://www.illinoiscourts.gov/courts/circuit-court/illinois-circuit-court-statistical-reports/',
    LA = 'https://evictionlab.org/eviction-tracking/new-orleans-la/',
    MA = 'https://public.tableau.com/app/profile/drap4687/viz/MassachusettsTrialCourtSummaryProcess/SummaryProcess',
    ME = 'https://www.courts.maine.gov/about/reports/fed-monthly15yr-report.pdf',
    MI = 'https://app.powerbigov.us/view?r=eyJrIjoiZGE3NzljYmItYTBmZC00OGI2LTliYTgtYzY5ZjI0N2U0MWYxIiwidCI6IjM0NTZmZTkyLWNiZDEtNDA2ZC1iNWEzLTUzNjRiZWMwYTgzMyJ9',
    MO = 'https://evictionlab.org/eviction-tracking/missouri/',
    NC = 'https://www.nccourts.gov/data',
    NE = 'https://nebraskajudicial.gov/administration/publications-reports',
    NH = 'https://www.courts.nh.gov/media/data-reports',
    NJ = 'https://www.njcourts.gov/public/statistics/fil-res-current',
    NM = 'https://evictionlab.org/eviction-tracking/new-mexico/',
    NV = 'https://nvcourts.gov/supreme/reports/annual_reports',
    PA = 'https://evictionlab.org/eviction-tracking/pennsylvania/',
    RI = 'https://www.rihousing.com/evictions-dashboard/',
    TX = 'https://card.txcourts.gov/',
    VA = 'https://virginiacourtdata.org/',
    WI = 'https://doa.wi.gov/Pages/Wisconsin-Eviction-Data-Project.aspx',
    WY = 'https://www.wyocourts.gov/circuit-courts/')

dark <- c('AL', 'IA', 'KS', 'MS', 'SD')

# LSC's Civil Court Data Initiative reaches 32 states, not the 12 it is the
# primary link for. Coverage is wildly uneven - Texas is 13 counties of 254 -
# so nothing is listed without its fraction. tracked/total/latest are LSC's own
# published figures, read from
# civilcourtdata.lsc.gov/page-data/data/eviction/<slug>/page-data.json on
# 2026-08-27, not counted by us. Re-read that JSON on rebuild; the numbers move,
# and a state page returning HTTP 200 is no evidence of coverage - a dozen of
# them render an empty shell while the bulk download still carries their data.
lsc_cov <- data.frame(
  ab      = c("AK", "AR", "AZ", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IN", "KS", "KY", "ME", "MN",
              "MS", "MT", "NC", "ND", "NH", "NY", "OH", "OK", "PA", "SC", "TN", "TX", "UT", "VA", "VT",
              "WI", "WV"),
  slug    = c("alaska", "arkansas", "arizona", "colorado", "connecticut", "delaware", "florida",
              "georgia", "hawaii", "idaho", "indiana", "kansas", "kentucky", "maine", "minnesota",
              "mississippi", "montana", "north-carolina", "north-dakota", "new-hampshire", "new-york",
              "ohio", "oklahoma", "pennsylvania", "south-carolina", "tennessee", "texas", "utah",
              "virginia", "vermont", "wisconsin", "west-virginia"),
  tracked = c(30, 75, 1, 62, 8, 3, 42, 3, 5, 43, 92, 1, 120, 16, 87, 1, 35, 100, 52, 10, 62, 4, 77, 67,
              46, 37, 13, 29, 133, 14, 72, 55),
  total   = c(30, 75, 15, 64, 8, 3, 67, 159, 5, 44, 92, 105, 120, 16, 87, 82, 56, 100, 53, 10, 62, 88, 77,
              67, 46, 95, 254, 29, 133, 14, 72, 55),
  latest  = c("June 2026", "June 2026", "June 2026", "November 2023", "June 2026", "June 2026", "June
              2026", "March 2026", "July 2022", "May 2025", "June 2026", "February 2025", "June 2026",
              "May 2023", "June 2026", "March 2024", "November 2025", "June 2022", "June 2025", "April
              2023", "June 2026", "June 2026", "June 2026", "June 2026", "June 2026", "June 2026", "June
              2026", "June 2026", "June 2026", "June 2026", "December 2023", "June 2026"),
  stringsAsFactors = FALSE)

state_names <- c(
  AL="Alabama", AK="Alaska", AZ="Arizona", AR="Arkansas", CA="California",
  CO="Colorado", CT="Connecticut", DC="District of Columbia", DE="Delaware",
  FL="Florida", GA="Georgia", HI="Hawaiʻi", IA="Iowa", ID="Idaho",
  IL="Illinois", IN="Indiana", KS="Kansas", KY="Kentucky", LA="Louisiana",
  MA="Massachusetts", MD="Maryland", ME="Maine", MI="Michigan", MN="Minnesota",
  MO="Missouri", MS="Mississippi", MT="Montana", NC="North Carolina",
  ND="North Dakota", NE="Nebraska", NH="New Hampshire", NJ="New Jersey",
  NM="New Mexico", NV="Nevada", NY="New York", OH="Ohio", OK="Oklahoma",
  OR="Oregon", PA="Pennsylvania", RI="Rhode Island", SC="South Carolina",
  SD="South Dakota", TN="Tennessee", TX="Texas", UT="Utah", VA="Virginia",
  VT="Vermont", WA="Washington", WI="Wisconsin", WV="West Virginia",
  WY="Wyoming")

# ===============================================
# Load and shape
# ===============================================

inv <- read_csv(path.expand(inv_csv), show_col_types = FALSE) %>%
  filter(status == "active", !is.na(url), url != "", access != "paid") %>%
  mutate(name_short = str_squish(str_replace(collector, "—.*$", "")))

stopifnot(
  "every jurisdiction accounted for" =
    setequal(c(names(ern_url), names(lsc_slug), names(partner_url), dark),
             names(state_names)),
  "inventory carries active sources" = nrow(inv) > 100
)

esc <- function(x) {
  x <- gsub("&", "&amp;", x); x <- gsub("<", "&lt;", x); x <- gsub(">", "&gt;", x)
  gsub('"', "&quot;", x)
}

primary_of <- function(ab) {
  if (ab %in% names(ern_url))     return(c("ern",  ern_url[[ab]],  "ERN state profile"))
  if (ab %in% names(lsc_slug))    return(c("lsc",
      paste0("https://civilcourtdata.lsc.gov/data/eviction/", lsc_slug[[ab]]),
      "LSC Civil Court Data Initiative"))
  if (ab %in% names(partner_url)) return(c("partner", partner_url[[ab]],
      partner_label[[ab]]))
  c("none", "", "No public statewide eviction data")
}

section_html <- function(ab) {
  nm <- state_names[[ab]]
  p  <- primary_of(ab)
  # Dark states list nothing rather than contradicting their own badge with
  # paid vendors or dashboards that carry no eviction breakout.
  srcs <- if (ab %in% dark) inv[0, ] else
    inv %>% filter(state == ab) %>% arrange(collector)
  # LSC rides in as an ordinary source row wherever it holds data but is not
  # already the state's primary. Dark states are left out on purpose: one county
  # is not statewide coverage, so listing it would fight the badge. Kansas and
  # Mississippi are named in the notes instead. Coverage goes in the geography
  # field so the existing meta builder renders it.
  lsc_row <- lsc_cov[lsc_cov$ab == ab, ]
  if (!(ab %in% dark) && !(ab %in% names(lsc_slug)) && nrow(lsc_row)) {
    srcs <- bind_rows(srcs, tibble(
      collector          = "LSC Civil Court Data Initiative",
      name_short         = "LSC Civil Court Data Initiative",
      url                = paste0("https://civilcourtdata.lsc.gov/data/eviction/",
                                  lsc_row$slug, "/"),
      smallest_geography = paste0("county, ", lsc_row$tracked, " of ",
                                  lsc_row$total, " tracked"),
      most_recent_data   = lsc_row$latest)) %>% arrange(collector)
  }
  rows <- if (nrow(srcs)) paste0(vapply(seq_len(nrow(srcs)), function(i) {
    r <- srcs[i, ]
    # Currency strings are free text; only date-shaped ones print, cut on a
    # word boundary so no dangling fragments.
    cur    <- str_squish(coalesce(r$most_recent_data, ""))
    cur_ok <- grepl("^(19|20|FY|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec|[0-9])", cur)
    if (cur_ok && nchar(cur) > 52)
      cur <- paste0(sub("\\s+\\S*$", "", substr(cur, 1, 52)), "…")
    meta <- paste(na.omit(c(
      if (!r$smallest_geography %in% c(NA, "unknown")) r$smallest_geography else NA,
      if (cur_ok) paste("through", cur) else NA)), collapse = " · ")
    glue('<li><a href="{esc(r$url)}">{esc(r$name_short)}</a>',
         '{if (nchar(meta)) paste0(" <span class=meta>", esc(meta), "</span>") else ""}</li>')
  }, character(1)), collapse = "\n") else
    glue('<li class="none">See <a href="{atlas_url}">The State of Eviction Data</a> for what exists behind paywalls or on request.</li>')

  badge <- switch(p[1],
    ern     = '<span class="badge b-ern">ERN profile</span>',
    lsc     = '<span class="badge b-lsc">LSC dashboard</span>',
    partner = '<span class="badge b-partner">State / partner</span>',
    none    = '<span class="badge b-none">No public data</span>')

  # An LSC primary states its coverage inline. Sending a reader to "the LSC
  # dashboard" for Tennessee without saying it holds 37 of 95 counties is the
  # kind of omission this page exists to prevent.
  p_meta <- if (p[1] == "lsc" && nrow(lsc_row))
    glue(' <span class=meta>{lsc_row$tracked} of {lsc_row$total} counties · through {lsc_row$latest}</span>')
  else ""

  primary <- if (p[1] == "none")
    '<p class="primary none">No statewide eviction data is published by anyone we could verify.</p>'
  else
    glue('<p class="primary">Start here: <a href="{esc(p[2])}">{esc(p[3])}</a>{p_meta}</p>')

  glue('<section class="state" id="{tolower(ab)}" data-name="{tolower(nm)} {tolower(ab)}">
  <div class="st-h"><h2>{nm}</h2>{badge}</div>
  {primary}
  <ul class="sources">{rows}</ul>
</section>')
}

sections <- paste0(vapply(names(state_names)[order(state_names)], section_html,
                          character(1)), collapse = "\n")

jump <- paste0(vapply(names(state_names)[order(state_names)], function(ab)
  glue('<a href="#{tolower(ab)}">{ab}</a>'), character(1)), collapse = "")


# Counted off the rendered markup rather than nrow(inv). The inventory count
# was already an overstatement, since the dark-state rule suppresses rows it
# includes, and LSC rows are added after the inventory is read.
n_src     <- length(gregexpr("<li><a ", sections)[[1]])
n_ern     <- length(ern_url)
n_lsc     <- length(lsc_slug)
n_partner <- length(partner_url)
n_dark    <- length(dark)

# ===============================================
# Page chrome
# ===============================================
# The header and footer are lifted from evictionresearch.net so the directory
# reads as part of the site rather than a stray page: same logos, same nav,
# same footer columns, same 1240px measure. Home links stay in the same tab,
# since their whole job is getting a reader back to the site. The page sits at
# the root of the site repo, so same-site links and assets are relative; HPRM
# is a separate deploy and stays absolute.

hprm_url  <- "https://evictionresearch.net/hprm/"
# BRAND.md assigns the stacked reversed mark to footers. It is 3001x1977, so it
# needs more height than the banner to read at all.
logo_bar  <- "images/ern_logo/1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER_REV.png"
logo_stak <- "images/ern_logo/1A/EvictionStudy_logo_v09_1A_LOGO_STACK_REV.png"

# The page is dark by choice, not by OS setting, so the palette is a single
# set of tokens rather than a light set with a prefers-color-scheme override.
# Everything here clears WCAG AA on the ground (checked 2026-08-26): steel
# 6.9:1, red-on-dark 6.6:1, and the brand red itself 4.7:1 - the dark ground
# buys back the AA shortfall the light home page accepts.
css <- '
:root{
  --ground:#14181D;   /* page ground                                    */
  --navy:#19222C;     /* ERN dark navy: header, footer                  */
  --ink:#FFFFFF;      /* headings                                       */
  --body:#D5DFEA;     /* body copy                        13.2:1        */
  --muted:#8BA3BE;    /* ERN steel: captions, metadata     6.9:1        */
  --red:#ff706a;      /* ERN red on dark: links, eyebrow   6.6:1        */
  --red-hi:#ff8f88;   /* hover                             8.1:1        */
  --lsc:#8FB0EA;      /* LSC navy, lifted to read on dark  8.1:1        */
  --teal:#5FC0BA;     /* partner teal, same treatment      8.3:1        */
  --rule:rgba(255,255,255,.15); --rule-fine:rgba(255,255,255,.08);
  --sans:"Inter",-apple-system,system-ui,"Helvetica Neue",Helvetica,Arial,sans-serif;
  --wrap:1240px; --read:880px; --pad:40px;
}
*{box-sizing:border-box}
html{scroll-behavior:smooth}
body{margin:0;background:var(--ground);color:var(--body);font-family:var(--sans);
     font-size:16px;line-height:1.6;font-feature-settings:"ss01","cv11";
     -webkit-font-smoothing:antialiased;min-height:100vh;display:flex;flex-direction:column}
main{flex:1 0 auto}
a{color:var(--red)} a:hover{color:var(--red-hi)}
::selection{background:rgba(249,50,43,.30)}
a:focus-visible,input:focus-visible{outline:2px solid var(--red);outline-offset:3px;border-radius:2px}
.skip{position:absolute;left:-9999px;top:0;background:#fff;color:var(--navy);padding:12px 18px;
      z-index:100;font-size:13px;font-weight:600;text-decoration:none}
.skip:focus{left:8px;top:8px}
.wrap{max-width:var(--wrap);margin:0 auto;padding-left:var(--pad);padding-right:var(--pad)}
.col{max-width:var(--read)}

/* Header */
.head{position:sticky;top:0;z-index:50;background:rgba(25,34,44,.92);
      backdrop-filter:saturate(180%) blur(12px);border-bottom:1px solid var(--rule)}
.head-in{display:flex;align-items:center;justify-content:space-between;gap:32px;
         min-height:84px;padding-top:16px;padding-bottom:16px}
.head-in>a{display:flex;align-items:center;text-decoration:none}
.head-in img{height:44px;width:auto;max-width:100%;display:block}
.nav{display:flex;align-items:center;gap:26px}
.nav a{font-size:13px;font-weight:500;color:#fff;text-decoration:none;white-space:nowrap}
.nav a:hover{color:var(--red);text-decoration:underline}
.nav a.btn:hover{text-decoration:none}
.btn{display:inline-flex;align-items:center;gap:10px;font-size:12px;font-weight:600;
     letter-spacing:.06em;text-transform:uppercase;text-decoration:none;padding:10px 18px;
     border-radius:4px;border:1px solid rgba(255,255,255,.5);background:transparent;color:#fff;
     transition:background 180ms ease,border-color 180ms ease,color 180ms ease}
.btn:hover{background:#fff;color:var(--navy);border-color:#fff}

/* Masthead */
.mast{padding:60px 0 4px}
.eyebrow{font-size:11px;font-weight:800;letter-spacing:.28em;text-transform:uppercase;
         color:var(--red);margin:0 0 16px}
h1{font-size:clamp(34px,5.2vw,52px);font-weight:200;line-height:1.05;letter-spacing:-.026em;
   margin:0;color:var(--ink);text-wrap:pretty}
h1 em{font-style:normal;font-weight:600}
.lede{font-size:17px;line-height:1.6;color:var(--body);max-width:66ch;margin:18px 0 0;
      text-wrap:pretty}
.lede a{color:var(--red);text-decoration:underline;text-underline-offset:2px}
.stats{font-size:12.5px;line-height:1.7;color:var(--muted);margin:22px 0 0;padding-top:14px;
       border-top:1px solid var(--rule-fine);font-variant-numeric:tabular-nums}
.stats strong{color:#fff;font-weight:600}

/* Jump nav and filter */
.tools{padding:26px 0 2px}
.jump{display:flex;flex-wrap:wrap;gap:6px;font-size:12px;font-variant-numeric:tabular-nums}
.jump a{color:var(--body);text-decoration:none;border:1px solid var(--rule);border-radius:4px;
        padding:3px 7px}
.jump a:hover{border-color:var(--red);color:var(--red)}
.filter{margin:16px 0 30px;padding:10px 13px;border:1px solid var(--rule);border-radius:4px;
        font-family:inherit;font-size:14px;width:280px;max-width:100%;
        background:rgba(255,255,255,.05);color:#fff}
.filter::placeholder{color:var(--muted)}
.filter:focus{outline:2px solid var(--red);outline-offset:-1px}

/* State sections */
section.state{border-top:1px solid var(--rule-fine);padding:20px 0 24px;max-width:var(--read);
              scroll-margin-top:110px}
.st-h{display:flex;align-items:baseline;gap:12px;flex-wrap:wrap}
h2{font-size:22px;font-weight:600;margin:0;letter-spacing:-.012em;color:var(--ink)}
/* Outlined rather than filled: a solid brand-red chip with white type is the
   one combination on this page that would fail AA. */
.badge{font-size:10.5px;letter-spacing:.12em;text-transform:uppercase;font-weight:600;
       padding:3px 9px;border-radius:3px;border:1px solid currentColor;white-space:nowrap}
.b-ern{color:var(--red)} .b-lsc{color:var(--lsc)}
.b-partner{color:var(--teal)} .b-none{color:var(--muted)}
.primary{margin:10px 0 6px;font-size:15px;color:var(--muted)}
.primary a{color:#fff;font-weight:600;text-decoration:underline;text-underline-offset:3px;
           text-decoration-color:rgba(255,255,255,.35)}
.primary a:hover{color:var(--red);text-decoration-color:currentColor}
.primary.none{color:var(--muted)}
.primary .meta{color:var(--muted);font-size:12.5px;font-weight:400}
ul.sources{margin:8px 0 0;padding-left:20px;font-size:14px}
ul.sources li{margin:5px 0}
ul.sources a{color:var(--body);text-decoration:underline;text-underline-offset:2px;
             text-decoration-color:rgba(213,223,234,.30)}
ul.sources a:hover{color:var(--red);text-decoration-color:currentColor}
ul.sources .meta{color:var(--muted);font-size:12.5px}
ul.sources .none{color:var(--muted);list-style:none;margin-left:-20px}

/* Notes */
.notes{border-top:1px solid var(--rule);margin-top:44px;padding-top:26px;font-size:13.5px;
       line-height:1.7;color:var(--muted);max-width:74ch}
.notes p{margin:0 0 12px}
.notes p:last-child{margin-bottom:0}
.notes b{color:#fff;font-weight:600}

/* Footer */
.foot{background:var(--navy);border-top:1px solid var(--rule);margin-top:60px}
.foot-in{display:flex;flex-wrap:wrap;gap:44px;justify-content:space-between;
         padding-top:44px;padding-bottom:44px}
.foot-brand{display:flex;flex-direction:column;gap:14px;max-width:38ch}
.foot-brand img{height:72px;width:auto;align-self:flex-start}
.foot-brand p{font-size:13px;line-height:1.6;color:var(--muted);margin:0}
.foot-brand p+p{font-size:12.5px}
.foot-col{display:flex;flex-direction:column;gap:10px}
.foot-col span{font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;
               color:var(--muted)}
.foot-col a{font-size:13.5px;color:#fff;text-decoration:none}
.foot-col a:hover{color:var(--red);text-decoration:underline}
.foot-bar{border-top:1px solid var(--rule)}
.foot-bar div{display:flex;flex-wrap:wrap;gap:16px;justify-content:space-between;
              padding-top:18px;padding-bottom:18px;font-size:12px;color:var(--muted)}
.foot-bar a{color:var(--muted);text-decoration:underline;text-underline-offset:2px}
.foot-bar a:hover{color:var(--red)}

@media (max-width:1000px){
  .head-in{flex-wrap:wrap;min-height:0;padding-top:12px;padding-bottom:12px;gap:8px}
  .nav{width:100%;flex-wrap:wrap;gap:14px 18px;padding-top:4px}
  .nav a{font-size:12.5px}
  section.state{scroll-margin-top:170px}
}
@media (max-width:900px){
  :root{--pad:20px}
  .mast{padding-top:40px}
}
@media (max-width:560px){
  .head-in img{height:34px}
  .foot-in{gap:30px}
}
@media (prefers-reduced-motion:reduce){
  *{transition-duration:.01ms !important;scroll-behavior:auto !important}
}
'

js <- '
const f = document.getElementById("q");
f.addEventListener("input", () => {
  const q = f.value.trim().toLowerCase();
  document.querySelectorAll("section.state").forEach(s =>
    s.style.display = s.dataset.name.includes(q) ? "" : "none");
});
'

html <- glue('<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>U.S. Eviction Data Directory — Eviction Research Network</title>
<meta name="description" content="Where to find eviction data in every U.S. state: ERN profiles, the LSC Civil Court Data Initiative, state court dashboards, and university and partner trackers.">
<link rel="canonical" href="https://evictionresearch.net/eviction-data-atlas.html">
<meta property="og:title" content="U.S. Eviction Data Directory — Eviction Research Network">
<meta property="og:description" content="Where every state’s public eviction data lives: ERN profiles, LSC’s Civil Court Data Initiative, state courts, universities, and nonprofits.">
<meta property="og:url" content="https://evictionresearch.net/eviction-data-atlas.html">
<meta property="og:type" content="website">
<meta property="og:image" content="https://evictionresearch.net/images/ern_logo/1Av2/EvictionStudy_logo_v09_1A_LOGO_BANNER.png">
<meta name="twitter:card" content="summary_large_image">
<link rel="icon" href="assets/img/favicon.png">
<link rel="apple-touch-icon" href="assets/img/apple-touch-icon.png">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Inter:wght@200;400;500;600;700;800&display=swap">
<style>{css}</style>
</head>
<body>
<a class="skip" href="#main">Skip to the directory</a>

<header class="head">
  <div class="wrap head-in">
    <a href="index.html" aria-label="Eviction Research Network — home">
      <img src="{logo_bar}" alt="Eviction Research Network">
    </a>
    <nav class="nav" aria-label="Primary">
      <a href="index.html#atlas">Maps &amp; Profiles</a>
      <a href="{hprm_url}">HPRM</a>
      <a href="index.html#research">Research</a>
      <a href="about.html">About</a>
      <a class="btn" href="index.html#partner">Contact</a>
    </nav>
  </div>
</header>

<main id="main">
<div class="wrap">
  <div class="mast col">
    <p class="eyebrow">Eviction data across the US</p>
    <h1>U.S. Eviction Data <em>Directory.</em></h1>
    <p class="lede">Where eviction data lives, state by state: the best starting point for each state, then every active public source we have verified. How each state’s pathway was judged, including sources that have gone dormant, is documented in <a href="{atlas_url}">The State of Eviction Data</a>.</p>
    <p class="stats">Reviewed August 2026 · 50 states and D.C. · <strong>{n_src}</strong> active public sources · <strong>{n_ern}</strong> with an ERN profile, <strong>{n_lsc}</strong> led by the LSC dashboard, <strong>{n_partner}</strong> with a state or partner source, <strong>{n_dark}</strong> with none.</p>
  </div>

  <div class="tools col">
    <nav class="jump" aria-label="Jump to state">{jump}</nav>
    <input class="filter" id="q" type="search" placeholder="Filter states" aria-label="Filter states">
  </div>

  {sections}

  <div class="notes">
    <p><b>What counts as a source.</b> Active public programs that publish eviction filings or closely related court records: state courts, universities, legal aid, nonprofits, and journalism. Paid lookup services and one-off studies are excluded here but appear in the atlas.</p>
    <p><b>Filings are not judgments, notices, or lockouts.</b> Sources differ in which stage of eviction they count, and the stages differ by an order of magnitude. Check each source’s definitions before comparing.</p>
    <p><b>Five states publish nothing.</b> Alabama, Iowa, Kansas, Mississippi, and South Dakota have no public statewide eviction data from any source we could verify. Two of them have a single county in LSC’s Civil Court Data Initiative, Johnson County in Kansas and DeSoto County in Mississippi. One county is not statewide coverage, so they stay listed here.</p>
    <p><b>LSC coverage varies enormously.</b> The Civil Court Data Initiative reaches 32 states, and every listing above carries the share of counties it actually holds. Some are complete, such as Kentucky at 120 of 120. Others are a fraction of the state, such as Texas at 13 counties of 254, and cannot be read as statewide. A state page that loads is not evidence of coverage: about a dozen render an empty page while the bulk download still carries their data.</p>
  </div>
</div>
</main>

<footer class="foot">
  <div class="wrap foot-in">
    <div class="foot-brand">
      <img src="{logo_stak}" alt="Eviction Research Network">
      <p>A research program led by Dr.&nbsp;Tim Thomas, Assistant Researcher in the UC Berkeley Department of Sociology, which serves as its academic home. Affiliated with the Berkeley Institute for Data Science.</p>
    </div>
    <div class="foot-col">
      <span>Data</span>
      <a href="index.html#atlas">Maps &amp; profiles</a>
      <a href="{hprm_url}">HPRM risk maps</a>
      <a href="{atlas_url}">The State of Eviction Data</a>
    </div>
    <div class="foot-col">
      <span>Research</span>
      <a href="research.html">Publications</a>
      <a href="methodology.html">Methodology</a>
      <a href="understanding-eviction.html">Understanding eviction</a>
      <a href="news.html">News &amp; press</a>
    </div>
    <div class="foot-col">
      <span>Contact</span>
      <a href="mailto:evictions@berkeley.edu?Subject=Contact%20through%20website">evictions@berkeley.edu</a>
      <a href="https://bsky.app/profile/evictionresearch.bsky.social">Bluesky</a>
      <a href="https://www.linkedin.com/company/evictionresearch/">LinkedIn</a>
      <a href="https://github.com/evictionresearch">GitHub</a>
    </div>
  </div>
  <div class="foot-bar">
    <div class="wrap">
      <span>© {format(Sys.Date(), "%Y")} Eviction Research Network · University of California, Berkeley · directory built {format(Sys.Date(), "%B %e, %Y")}</span>
      <span><a href="https://dap.berkeley.edu/get-help/report-web-accessibility-issue">Report a web accessibility issue</a></span>
    </div>
  </div>
</footer>
<script>{js}</script>
</body>
</html>')

writeLines(html, path.expand(out_html))

# Read-off: size and section count
c(kb = round(file.size(path.expand(out_html)) / 1024),
  sections = length(state_names), sources_listed = n_src)
