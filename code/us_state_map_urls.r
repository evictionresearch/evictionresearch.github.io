# ==========================================================================
# Create U.S. map with url links for each state
# ==========================================================================

librarian::shelf(maps, sf, tidyverse, tigris, rstudio/leaflet, htmlwidgets, leaflet.extras, update_all = TRUE)

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

state <-
    states(
        cb = TRUE
    ) %>% 
    filter(STUSPS %in% c('CA', 'WA',
        'DE',
        # 'IL',
        'IN',
        'MN',
        'OR',
        'MD',
        # 'MO'#,
        # 'PA',
        'OH'
        )) %>%
    mutate(win_url = 
        case_when(
            STUSPS == 'CA' ~ 'https://evictionresearch.net/california/',
            STUSPS == 'WA' ~ 'https://evictionresearch.net/washington/',
            STUSPS == 'DE' ~ 'https://evictionresearch.net/delaware/',
            # STUSPS == 'IL' ~ 'https://evictionresearch.net/illinois/',
            STUSPS == 'IN' ~ 'https://evictionresearch.net/indiana/',
            STUSPS == 'MN' ~ 'https://evictionresearch.net/minnesota/',
            STUSPS == 'OR' ~ 'https://evictionresearch.net/oregon/',
            STUSPS == 'MD' ~ 'https://evictionresearch.net/maryland/report/baltimore.html',
            # STUSPS == 'MO' ~ 'https://evictionresearch.net/missouri/',
            # STUSPS == 'PA' ~ 'https://evictionresearch.net/pennsylvania/',
            STUSPS == 'OH' ~ 'https://evictionresearch.net/ohio/dayton.html'
        )
        )

# soon_state <-
#     states(cb = TRUE) %>%
#     filter(STUSPS %in% c(
#         'IL',
#         'MO',
#         'PA',
#         # 'OH',
#         'TX',
#         'FL',
#         'GA',
#         'SC',
#         'TN'))

# later_state <-
#     states(cb = TRUE) %>%
#     filter(STUSPS %in% c('AL', 'AZ', 'AR', 'CO', 'KS', 'KY', 'ND', 'OK', 'VT', 'VA', 'AK', 'HI', 'CT', 'NM', 'ME', 'NH', 'NY', 'UT', 'WI'))

# state_center <- 
#     st_centroid(state) %>% 
#     mutate(lng = st_coordinates(.)[1], lat = st_coordinates(.)[2]) %>%
#     st_drop_geometry()

us_map <-
leaflet(
    # state_center, 
  options = leafletOptions(zoomControl = FALSE, minZoom = 3.7, maxZoom = 3.7, dragging = FALSE, attributionControl=FALSE)) %>%
    # suspendScroll() %>% 
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
        color = '#F9322B',
        stroke = TRUE, 
        label = ~NAME, 
        weight = 1, 
        opacity = .5, 
        highlightOptions = highlightOptions(
                    color = "#ff4a4a", 
                    weight = 5,
                    bringToFront = TRUE
                    )  
        )  %>%
  # addPolygons(
  #       data = soon_state,
  #       fillOpacity = .5,
  #       color = '#cfcfcf',
  #       stroke = TRUE,
  #       label = ~paste(NAME, " Coming soon"),
  #       weight = 1,
  #       opacity = .5,
  #       highlightOptions = highlightOptions(
  #                   color = "#ff4a4a",
  #                   weight = 5,
  #                   bringToFront = TRUE
  #                   )
  #       )  %>%
  # addPolygons(
  #       data = later_state,
  #       fillOpacity = .5,
  #       color = '#cfcfcf',
  #       stroke = TRUE,
  #       label = ~paste(NAME, " Coming soon"),
  #       weight = 1,
  #       opacity = .5,
  #       highlightOptions = highlightOptions(
  #                   color = "#ff4a4a",
  #                   weight = 5,
  #                   bringToFront = TRUE
  #                   )
  #       )  %>%
  htmlwidgets::onRender(jsCode, data=state) 

us_map
saveWidget(us_map, '~/git/evictionresearch/evictionresearch.github.io/maps/us_map.html')
