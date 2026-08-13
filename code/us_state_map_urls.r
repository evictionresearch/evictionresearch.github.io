# ==========================================================================
# Create U.S. map with url links for each state
# Author: Tim Thomas
# Created: 2022
# Updated: 2026-08-13 - reference map: ERN red, LSC navy, partner teal
# ==========================================================================

# The map is ERN's reference for eviction data everywhere: every state with
# any public eviction data is clickable, colored by who holds it.
#
#   Red   ERN state profiles at evictionresearch.net
#   Navy  LSC Civil Court Data Initiative dashboard (their brand navy) -
#         states where LSC is current and statewide-ish, or the only public
#         data, and our extract carries no defendant names or addresses
#   Teal  the best non-LSC source: a state court dashboard, a university
#         clearinghouse, or Eviction Lab's tracking system
#   White nothing public to link (AL IA KS MS SD)
#
# The roster follows the tiered strategy census (docs/
# state_profile_expansion.md, "The strategy census"; editable Drive sheet
# "ERN State Strategy Census (Aug 2026)"). Tier 3 states (counts unmapped:
# TX NV ME FL IL CA NH ID NE HI WY DC) currently show teal on their counts
# source and go RED as their KY-template pages ship, TX/NV/ME first. Tier 4
# interim colors (NY OK ND navy; VA PA MO NM NJ CO GA teal) go red as
# profiles ship. Tier 2 hub states re-point from their primary source to the
# ERN hub page when hubs ship. Keep this file and
# all_states/code/o2_data_directory.r in lockstep. The HI link is a
# year-stamped annual report PDF; re-point it when the judiciary posts the
# next one.

librarian::shelf(sf, dplyr, tigris, rstudio/leaflet, htmlwidgets)
options(tigris_use_cache = TRUE)

jsCode <- paste0('
 function(el, x, data) {
  var marker = document.getElementsByClassName("leaflet-interactive");
  for(var i=0; i < marker.length; i++){
    (function(){
      var v = data.win_url[i];
      marker[i].addEventListener("click", function() { window.open(v);}, false);
  }());
  }
 }
')

ern_red   <- '#F9322B'   # ERN brand red
lsc_navy  <- '#001F60'   # LSC brand navy, from civilcourtdata.lsc.gov styles
part_teal <- '#2A8A86'   # ERN qualitative teal, for non-LSC sources

# ERN profile states
ern_url <- c(
    CA = 'https://evictionresearch.net/california/',
    WA = 'https://evictionresearch.net/washington/',
    DE = 'https://evictionresearch.net/delaware/',
    IN = 'https://evictionresearch.net/indiana/',
    MN = 'https://evictionresearch.net/minnesota/',
    OR = 'https://evictionresearch.net/oregon/',
    MD = 'https://evictionresearch.net/maryland/report/baltimore.html',
    OH = 'https://evictionresearch.net/ohio/dayton.html')

# LSC dashboard states (current feed, no names/addresses in our extract;
# NY OK ND are interim links pending ERN builds)
lsc_slug <- c(
    AK = 'alaska',        AR = 'arkansas',       KY = 'kentucky',
    MT = 'montana',       ND = 'north-dakota',   NY = 'new-york',
    OK = 'oklahoma',      SC = 'south-carolina', TN = 'tennessee',
    UT = 'utah',          VT = 'vermont',        WV = 'west-virginia')

# Non-LSC sources: state courts, university clearinghouses, partners, and
# Eviction Lab state pages. Fetch-verified 2026-08-13.
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

partner_label <- c(
    AZ = 'AZ courts dashboard',            CO = 'CO Judicial dashboard',
    CT = 'CTData eviction map',            DC = 'Office of the Tenant Advocate',
    FL = 'Shimberg Center (UF)',           GA = 'Metro Atlanta tracker (ARC)',
    HI = 'HI Judiciary annual report',     ID = 'Idaho Policy Institute',
    IL = 'IL courts statistics',           LA = 'Eviction Lab, New Orleans',
    MA = 'Mass Trial Court dashboard',     ME = 'Maine Judicial FED report',
    MI = 'MI SCAO dashboard',              MO = 'Eviction Lab tracking',
    NC = 'NCAOC dashboard',                NE = 'NE courts eviction report',
    NH = 'NH courts data reports',         NJ = 'NJ Judiciary statistics',
    NM = 'Eviction Lab tracking',          NV = 'NV courts annual reports',
    PA = 'Eviction Lab tracking',          RI = 'RIHousing dashboard',
    TX = 'TX Office of Court Admin',       VA = 'virginiacourtdata.org',
    WI = 'WI Eviction Data Project',       WY = 'WY courts annual report')

all_st <- states(cb = TRUE, resolution = '20m')

state <- all_st %>%
    filter(STUSPS %in% names(ern_url)) %>%
    mutate(win_url = ern_url[STUSPS])

lsc_state <- all_st %>%
    filter(STUSPS %in% names(lsc_slug)) %>%
    mutate(win_url = paste0('https://civilcourtdata.lsc.gov/data/eviction/',
                            lsc_slug[STUSPS]))

partner_state <- all_st %>%
    filter(STUSPS %in% names(partner_url)) %>%
    mutate(win_url = partner_url[STUSPS],
           src_label = partner_label[STUSPS])

soon_state <- all_st %>%
    filter(!STUSPS %in% c(state$STUSPS, lsc_state$STUSPS, partner_state$STUSPS),
           !STUSPS %in% c('PR', 'VI', 'GU', 'MP', 'AS'))

# The click hook walks every leaflet-interactive path in draw order and zips
# it with win_url, so the data handed to onRender must be the interactive
# layers bound in the same order they are added below.
click_data <- bind_rows(state, lsc_state, partner_state)

stopifnot(
    "no state sits in two rosters" =
        anyDuplicated(c(names(ern_url), names(lsc_slug), names(partner_url))) == 0,
    "12 LSC states resolved"            = nrow(lsc_state) == 12,
    "26 partner states resolved"        = nrow(partner_state) == 26,
    "every interactive state has a url" = all(!is.na(click_data$win_url)),
    "only AL IA KS MS SD stay dark"     =
        setequal(soon_state$STUSPS, c('AL', 'IA', 'KS', 'MS', 'SD')),
    "51 jurisdictions on the map"       =
        nrow(state) + nrow(lsc_state) + nrow(partner_state) + nrow(soon_state) == 51
)

us_map <-
leaflet(
  options = leafletOptions(zoomControl = FALSE, minZoom = 3.7, maxZoom = 3.7,
                           dragging = FALSE, attributionControl = FALSE)) %>%
    setView(lat = 39, lng = -96, zoom = 3.5) %>%
    addMapPane(name = "polygons", zIndex = 410) %>%
    addMapPane(name = "maplabels", zIndex = 420) %>%
    addProviderTiles("CartoDB.PositronNoLabels") %>%
    addProviderTiles("CartoDB.PositronOnlyLabels",
                   options = leafletOptions(pane = "maplabels"),
                   group = "map labels") %>%
  addPolygons(
        data = state,
        fillOpacity = .5,
        color = ern_red,
        stroke = TRUE,
        label = ~paste0(NAME, " · ERN profile"),
        weight = 1,
        opacity = .5,
        highlightOptions = highlightOptions(
                    color = "#ff4a4a",
                    weight = 5,
                    bringToFront = TRUE
                    )
        ) %>%
  addPolygons(
        data = lsc_state,
        fillOpacity = .45,
        color = lsc_navy,
        stroke = TRUE,
        label = ~paste0(NAME, " · eviction data at LSC"),
        weight = 1,
        opacity = .5,
        highlightOptions = highlightOptions(
                    color = lsc_navy,
                    weight = 5,
                    bringToFront = TRUE
                    )
        ) %>%
  addPolygons(
        data = partner_state,
        fillOpacity = .45,
        color = part_teal,
        stroke = TRUE,
        label = ~paste0(NAME, " · ", src_label),
        weight = 1,
        opacity = .5,
        highlightOptions = highlightOptions(
                    color = part_teal,
                    weight = 5,
                    bringToFront = TRUE
                    )
        ) %>%
  addPolygons(
        data = soon_state,
        options = pathOptions(interactive = FALSE),
        fillOpacity = .5,
        fillColor = '#ffffff',
        color = '#d6d6d6',
        stroke = TRUE,
        label = ~paste(NAME, " No public eviction data"),
        weight = 1,
        opacity = .35
        ) %>%
  htmlwidgets::onRender(jsCode, data = click_data)

us_map
saveWidget(us_map, '~/git/evictionresearch/evictionresearch.github.io/maps/us_map.html', selfcontained = TRUE)
