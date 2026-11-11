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

edrn_csv <- "~/git/evictionresearch/library/data/state_profile_readiness/edrn_partners.csv"
# Dated snapshots written by library/code/state_profile_readiness/d4_state_data_watch.r.
# The newest LSC snapshot supplies county coverage and the "Reviewed" month.
watch_dir <- "~/data/evictionresearch/library/state_data_watch"
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
    HI = "Hawaiʻi Judiciary annual report",
    ID = 'Idaho Policy Institute eviction reports',
    IL = 'Illinois circuit court statistics', LA = 'Eviction Lab, New Orleans',
    MA = 'Massachusetts Trial Court dashboard',
    ME = 'Maine Judicial monthly FED report', MI = 'Michigan courts eviction snapshot',
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
    ID = 'https://www.boisestate.edu/sps-ipi/evictions-in-idaho/',
    IL = 'https://www.illinoiscourts.gov/courts/circuit-court/illinois-circuit-court-statistical-reports/',
    LA = 'https://evictionlab.org/eviction-tracking/new-orleans-la/',
    MA = 'https://public.tableau.com/app/profile/drap4687/viz/MassachusettsTrialCourtSummaryProcess/SummaryProcess',
    ME = 'https://www.courts.maine.gov/about/reports/fed-monthly15yr-report.pdf',
    MI = 'https://www.courts.michigan.gov/4af43b/siteassets/covid/covid-19/eviction-rate.pdf',
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

# Michigan (2026-11-10): the Power BI address the July census recorded as
# Michigan's dashboard opens the New York courts' eviction dashboard. Michigan's
# own product is the snapshot PDF on courts.michigan.gov, which is what the
# Start-here link now points to. Open a dashboard link in a browser and read
# whose it is before listing it; a page title is not enough.
dark <- c('AL', 'IA', 'KS', 'MS', 'SD')

# LSC's Civil Court Data Initiative reaches far more states than the 12 it is
# the primary link for. Coverage is wildly uneven - Texas is 13 counties of
# 254 - so nothing is listed without its fraction. tracked/total/latest are
# LSC's own published figures, not counted by us. They used to be typed into
# this script by hand and went stale between rebuilds; since 2026-11-10 they
# are read from the newest snapshot the state data watch saved from
# civilcourtdata.lsc.gov/page-data/data/eviction/<slug>/page-data.json. Run
# the watch first, then this script. A state page returning HTTP 200 is no
# evidence of coverage - a dozen of them render an empty shell while the bulk
# download still carries their data - so only states with a county count in
# the feed are kept. Puerto Rico and the U.S. Virgin Islands are in the feed
# and are left out because this page lists states and D.C.
lsc_file <- sort(list.files(path.expand(watch_dir), full.names = TRUE,
                            pattern = "^lsc_coverage_\\d{4}-\\d{2}-\\d{2}\\.csv$"),
                 decreasing = TRUE)[1]
reviewed <- as.Date(str_extract(basename(lsc_file), "\\d{4}-\\d{2}-\\d{2}"))

lsc_cov <- read_csv(lsc_file, col_types = cols(.default = "c")) %>%
  filter(!is.na(counties_tracked), !ab %in% c("PR", "VI")) %>%
  transmute(ab, slug,
            tracked = as.integer(counties_tracked),
            total   = as.integer(counties_total),
            latest  = format(as.Date(paste0(latest_month, "-01")), "%B %Y")) %>%
  as.data.frame()

stopifnot(
  "the LSC snapshot is under 45 days old (run d4_state_data_watch.r first, or this page prints stale months)" =
    as.numeric(Sys.Date() - reviewed) <= 45,
  "the LSC snapshot carries at least 30 states" = nrow(lsc_cov) >= 30,
  "every LSC primary state is in the snapshot" = all(names(lsc_slug) %in% lsc_cov$ab)
)

# New America's Eviction Data Response Network partners, one row per partner.
# ERN names them under their state and does not build on top of them (standing
# decision, 2026-10-29). Names and cohorts are checked against New America's
# own pages; the source and date are in the file.
edrn <- read_csv(path.expand(edrn_csv), show_col_types = FALSE)

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

# The July 2026 census with every change a later review recorded applied to
# it (library/data/state_profile_readiness/d2_inventory_updates.csv and
# d2_inventory_additions.csv). The census file itself is never hand-edited.
source("~/git/evictionresearch/library/code/state_profile_readiness/f_current_inventory.r")

inv <- current_inventory() %>%
  filter(status == "active", !is.na(url), url != "", access != "paid") %>%
  mutate(name_short = str_squish(str_replace(collector, "—.*$", ""))) %>%
  # Two sources from one collector in a state would print the same name twice
  # (two "Texas Housers", two "Alaska Court System"), so those keep the report
  # or place after the dash, joined with a comma.
  group_by(state, name_short) %>%
  mutate(name_short = if (n() > 1)
           str_squish(str_replace(collector, "\\s*—\\s*", ", ")) else name_short) %>%
  ungroup()

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
    # Currency strings are free text that also carries the researcher's
    # verification notes. Only a leading period prints (a year, a month and
    # year, a full date, or a fiscal year), and only when the end of the
    # string, a parenthesis, semicolon, or comma, or the word data, caseloads,
    # or filings follows it, so "2025 Housing Fact Book" or "June 2026 report
    # exists per..." print nothing. Changed 2026-11-05; the old rule cut the
    # free text at 52 characters and printed working notes.
    cur_re <- paste0(
      "^(FY ?(19|20)[0-9]{2}(-[0-9]{2,4})?",
      "|(Jan(uary)?|Feb(ruary)?|Mar(ch)?|Apr(il)?|May|June?|July?|Aug(ust)?",
      "|Sep(t(ember)?)?|Oct(ober)?|Nov(ember)?|Dec(ember)?) ([0-9]{1,2}, )?(19|20)[0-9]{2}",
      "|(19|20)[0-9]{2})(?=$| \\(|;|,| data\\b| caseloads\\b| filings\\b)")
    cur    <- str_squish(coalesce(r$most_recent_data, ""))
    cur_ok <- grepl(cur_re, cur, perl = TRUE)
    if (cur_ok) cur <- regmatches(cur, regexpr(cur_re, cur, perl = TRUE))
    meta <- paste(na.omit(c(
      if (!r$smallest_geography %in% c(NA, "unknown")) r$smallest_geography else NA,
      if (cur_ok) paste("through", cur) else NA)), collapse = " · ")
    glue('<li><a href="{esc(r$url)}">{esc(r$name_short)}</a>',
         '{if (nchar(meta)) paste0(" <span class=meta>", esc(meta), "</span>") else ""}</li>')
  }, character(1)), collapse = "\n") else
    glue('<li class="none"><a href="{atlas_url}">The State of Eviction Data</a> describes what exists behind paywalls or on request.</li>')

  badge <- switch(p[1],
    ern     = '<span class="badge b-ern">ERN profile</span>',
    lsc     = '<span class="badge b-lsc">LSC dashboard</span>',
    partner = '<span class="badge b-partner">State / partner</span>',
    none    = '<span class="badge b-none">No statewide data</span>')

  # An LSC primary states its coverage inline. Sending a reader to "the LSC
  # dashboard" for Tennessee without saying it holds 37 of 95 counties is the
  # kind of omission this page exists to prevent.
  p_meta <- if (p[1] == "lsc" && nrow(lsc_row))
    glue(' <span class=meta>{lsc_row$tracked} of {lsc_row$total} counties · through {lsc_row$latest}</span>')
  else ""

  primary <- if (p[1] == "none")
    '<p class="primary none">We found no public source of statewide eviction data.</p>'
  else
    glue('<p class="primary">Start here: <a href="{esc(p[2])}">{esc(p[3])}</a>{p_meta}</p>')

  # New America's partners in this state, newest cohort first. A local partner
  # carries its city or county so nobody reads Austin as all of Texas.
  e <- edrn %>% filter(state == ab) %>% arrange(desc(cohort), area)
  edrn_p <- if (nrow(e)) paste0('<p class="edrn">', paste0(vapply(seq_len(nrow(e)), function(i) {
    r     <- e[i, ]
    name  <- if (is.na(r$partner_url)) esc(r$partner) else
      glue('<a href="{esc(r$partner_url)}">{esc(r$partner)}</a>')
    where <- if (r$scope == "local") paste0(" (", esc(r$area), ")") else ""
    glue('<span>Eviction Data Response Network partner, {sub("-", "–", r$cohort)}: {name}{where}</span>')
  }, character(1)), collapse = "\n"), '</p>') else ""

  glue('<section class="state" id="{tolower(ab)}" data-name="{tolower(nm)} {tolower(ab)}">
  <div class="st-h"><h2>{nm}</h2>{badge}</div>
  {primary}
  {edrn_p}
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
n_lsc_all <- nrow(lsc_cov)
n_edrn_28 <- sum(edrn$cohort == "2026-2028")
n_edrn_25 <- sum(edrn$cohort == "2024-2025")
lsc_of    <- function(ab) paste(lsc_cov$tracked[lsc_cov$ab == ab], "of", lsc_cov$total[lsc_cov$ab == ab])

stopifnot(
  "New America's 2026-2028 cohort is eleven states" = n_edrn_28 == 11,
  "New America's 2024-2025 cohort is nine partners" = n_edrn_25 == 9
)

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
.edrn{margin:0 0 6px;font-size:13px;color:var(--muted)}
.edrn span{display:block}
.edrn a{color:var(--body);text-decoration:underline;text-underline-offset:2px;
        text-decoration-color:rgba(213,223,234,.30)}
.edrn a:hover{color:var(--red);text-decoration-color:currentColor}
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
<meta property="og:description" content="Where each state’s public eviction data lives, and the five states with no public statewide source.">
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
      <a href="policy.html">What works</a>
      <a href="about.html">About</a>
      <a class="btn" href="index.html#partner">Contact</a>
    </nav>
  </div>
</header>

<main id="main">
<div class="wrap">
  <div class="mast col">
    <p class="eyebrow">Eviction data across the U.S.</p>
    <h1>U.S. Eviction Data <em>Directory.</em></h1>
    <p class="lede">This directory lists where to find eviction data in every state. Each state’s entry begins with the best place to start. Below it are the other active public sources we have verified. <a href="{atlas_url}">The State of Eviction Data</a> explains how we chose each starting point.</p>
    <p class="stats">Reviewed {format(reviewed, "%B %Y")} · 50 states and D.C. · <strong>{n_src}</strong> active public sources · <strong>{n_ern}</strong> with an ERN profile, <strong>{n_lsc}</strong> led by the LSC dashboard, <strong>{n_partner}</strong> with a state or partner source, <strong>{n_dark}</strong> with no statewide source.</p>
  </div>

  <div class="tools col">
    <nav class="jump" aria-label="Jump to state">{jump}</nav>
    <input class="filter" id="q" type="search" placeholder="Filter states" aria-label="Filter states">
  </div>

  {sections}

  <div class="notes">
    <p><b>What counts as a source.</b> A source is an active public program that publishes eviction filings or closely related court records. Sources include state courts, universities, legal aid groups, nonprofits, and news organizations. Paid lookup services and one-off studies are not listed here. <a href="{atlas_url}">The State of Eviction Data</a> lists them.</p>
    <p><b>Each date is the latest period we read on that source.</b> We re-read some sources in {format(reviewed, "%B %Y")}. The rest keep the date we read in July 2026.</p>
    <p><b>Filings are not judgments, notices, or lockouts.</b> Sources count different stages of eviction, and each stage produces a different number. A filing count from one source cannot be compared with a judgment or lockout count from another.</p>
    <p><b>Five states have no public statewide data.</b> Alabama, Iowa, Kansas, Mississippi, and South Dakota have no public statewide eviction data from any source we could verify. LSC’s Civil Court Data Initiative holds one county in Kansas (Johnson County) and one in Mississippi (DeSoto County). One county is not statewide coverage, so both states are counted among the five.</p>
    <p><b>LSC coverage is uneven.</b> The Civil Court Data Initiative reaches {n_lsc_all} states. Each LSC listing above shows how many of the state’s counties it holds and the latest month in its feed. Some states are complete, such as Kentucky at {lsc_of("KY")} counties. Others are a fraction, such as Texas at {lsc_of("TX")} counties, and cannot be read as statewide.</p>
    <p><b>New America’s Eviction Data Response Network.</b> New America gives state and local teams funding and technical help to build eviction data systems. Each team’s lead organization is named under its state above. Eleven states are in the 2026–2028 cohort, and nine local and state partners were in the 2024–2025 cohort. New America’s target is a pipeline of reliable eviction data in each of the eleven states by December 31, 2028. In Washington, ERN works on the partner team with the University of Washington’s Housing Futures Center. Sources: New America’s <a href="https://www.newamerica.org/insights/state-partners-join-eviction-data-response-network/">2026–2028 announcement</a> and its <a href="https://www.newamerica.org/insights/about-the-eviction-data-response-network/">description of the network</a>.</p>
  </div>
</div>
</main>

<footer class="foot">
  <div class="wrap foot-in">
    <div class="foot-brand">
      <img src="{logo_stak}" alt="Eviction Research Network">
      <!-- UC Berkeley Sociology departmental lockup, approved for this site by
           Brand Protection (Project #1008, 2026-09-02). Official file, white on
           its own Berkeley Blue ground; never recolor or crop it. -->
      <a class="foot-berkeley" href="https://sociology.berkeley.edu" target="_blank" rel="noopener noreferrer"><img src="images/logos/berkeley/uc-berkeley-sociology_h_white_transparent.png" alt="UC Berkeley Sociology"></a>
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
