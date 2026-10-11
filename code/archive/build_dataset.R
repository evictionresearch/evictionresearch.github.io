# [csv->parquet migration] reader->read_data for converted CSVs
# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
################################################################################

# Join datasets from individual states to create nationwide eviction dataset
# to be used for analysis

# Author: Julia Greenberg
# Date created: Jan 31 2023

# See tracker (https://docs.google.com/spreadsheets/d/157ns-6jlzBzK0QD3ECDhSoEqUvis1PfhrVrtYpFkoJY/edit#gid=0)
# for updates on each state.

################################################################################

#===============================
# Load packages
#===============================

<<<<<<< HEAD
librarian::shelf(tidyverse, googledrive, sf, lubridate, stringr)
=======
source('~/git/timathomas/functions/functions.r') # clone this repo from https://github.com/timathomas/functions into your account.

ipak(c('tidyverse', 'googledrive', 'sf', 'lubridate', 'stringr', 
       'tidycensus'))
>>>>>>> main

#===============================
# Download data
#===============================

# If you don't have the data downloaded, pull from Google Drive:
# https://drive.google.com/drive/u/0/folders/14_5j9a-rDjHK_sEsuKbsQYTFpe3XQUCU

d_loc <- '~/data/evictionresearch/'

# Georgia
ga4 <- read_data(paste0(d_loc, 'georgia/d4_dem_est_allcases_pii.qs'))
ga5 <- read_data(paste0(d_loc, 'georgia/d5_dem_est_agg.qs')) %>%
  mutate(state = 'georgia')

# Delaware
de4 <- read_data(paste0(d_loc, 'delaware/d4_dem_est_allcases_pii.qs'))
de5 <- read_data(paste0(d_loc, 'delaware/d5_dem_est_agg.qs')) %>%
  mutate(state = 'delaware')

# Indiana
in4 <- read_data(paste0(d_loc, 'indiana/d4_dem_est_allcases_pii.qs'))
in5 <- read_data(paste0(d_loc, 'indiana/d5_dem_est_agg.qs')) %>%
  mutate(state = 'indiana')

# Minnesota
mn4 <- read_data(paste0(d_loc, 'minnesota/d4_dem_est_allcases_pii.qs'))
mn5 <- read_data(paste0(d_loc, 'minnesota/d5_dem_est_agg.qs')) %>%
  mutate(state = 'minnesota')

# Missouri
mo4 <- read_data(paste0(d_loc, 'missouri/d4_dem_est_allcases_pii.qs')) %>%
  mutate(across(score:latitude, as.numeric))

mo5 <- read_data(paste0(d_loc, 'missouri/d5_dem_est_agg.qs')) %>%
  mutate(state = 'missouri')

# Connecticut
ct4 <- read_data(paste0(d_loc, 'connecticut/d4_dem_est_allcases_pii.qs')) %>%
  mutate(across(score:latitude, as.numeric))

ct5 <- read_data(paste0(d_loc, 'connecticut/d5_dem_est_agg.qs')) %>%
  mutate(state = 'connecticut')

# Pennsylvania
pa4 <- read_data(paste0(d_loc, 'pennsylvania/d4_dem_est_allcases_pii.qs'))
pa5 <- read_data(paste0(d_loc, 'pennsylvania/d5_dem_est_agg.qs')) %>%
  mutate(state = 'pennsylvania')

# Texas
tx4 <- read_data(paste0(d_loc, 'texas/d4_dem_est_allcases_pii.qs'))
tx5 <- read_data(paste0(d_loc, 'texas/d5_dem_est_agg.qs')) %>%
  mutate(state = 'texas')

# Florida
fl4 <- read_data(paste0(d_loc, 'florida/d4_dem_est_allcases_pii.qs')) %>%
  mutate(across(score:latitude, as.numeric),
         across(c(date_filed, date_closed, date_disposed, is_closed), 
                as.character))

fl5 <- read_data(paste0(d_loc, 'florida/d5_dem_est_agg.qs')) %>%
  mutate(state = 'florida')

# South Carolina
sc4 <- read_data(paste0(d_loc, 'south_carolina/d4_dem_est_allcases_pii.qs')) %>%
  mutate(across(score:latitude, as.numeric))

sc5 <- read_data(paste0(d_loc, 'south_carolina/d5_dem_est_agg.qs')) %>%
  mutate(state = 'south carolina')

# Ohio
# googledrive::drive_download(
#   path = paste0(d_loc, 'ohio/d4_dem_est_allcases_pii.qs'),
#   'https://drive.google.com/file/d/1Sih-4ZJdGMVyKag954504UMyCT_s0f2d/view?usp=sharing',
#   overwrite = T)
# 
# googledrive::drive_download(
#   path = paste0(d_loc, 'ohio/d5_dem_est_agg.qs'),
#   'https://drive.google.com/file/d/1pFXdVEB338iDDO-6e_j6E9dWZGsF_pZa/view?usp=sharing',
#   overwrite = T)

oh4 <- read_data(paste0(d_loc, 'ohio/d4_dem_est_allcases_pii.qs')) %>%
  rename(date_filed = file_date) %>%
  mutate(across(c(date_filed, date_closed, date_disposed, is_closed, id), 
                as.character)) 

oh4 <- oh4 %>%
  # Subset to only columns found in other d4s
  select(unlist(intersect(names(oh4), names(tx4)))) %>%
  mutate(state = 'ohio')

oh5 <- read_data(paste0(d_loc, 'ohio/d5_dem_est_agg.qs')) %>%
  mutate(state = 'ohio') 

oh5 <- oh5 %>%
  # Subset to only columns found in other d5s
  select(unlist(intersect(names(oh5), names(tx5))))

# California
# googledrive::drive_download(
#   path = paste0(d_loc, 'california/d4_dem_est_allcases_pii.qs'),
#   'https://drive.google.com/file/d/1oFJBojk0_nvPRhXEgRxJ5QbArdSdADzT/view?usp=sharing',
#   overwrite = T)
# 
# googledrive::drive_download(
#   path = paste0(d_loc, 'california/d5_dem_est_agg.qs'),
#   'https://drive.google.com/file/d/1O8FNR5csvdwoYuOiM0Qx8Js6B71KjgiB/view?usp=sharing',
#   overwrite = T)

ca4 <- read_data(paste0(d_loc, 'california/d4_dem_est_allcases_pii.qs'))

ca4 <- ca4 %>%
  # Subset to only columns found in other d4s
  select(unlist(intersect(names(ca4), names(tx4)))) %>%
  mutate(state = 'california')

ca5 <- read_data(paste0(d_loc, 'california/d5_dem_est_agg.qs')) %>%
  mutate(state = 'california') 

ca5 <- ca5 %>%
  # Subset to only columns found in other d5s
  select(unlist(intersect(names(ca5), names(tx5))))

# Oregon
# googledrive::drive_download(
#   path = paste0(d_loc, 'oregon/d4_dem_est_allcases_pii.qs'),
#   'https://drive.google.com/file/d/1QWRjrcGzVaergJYxxL1pDDiPBmoo0pfH/view?usp=sharing',
#   overwrite = T)
# 
# googledrive::drive_download(
#   path = paste0(d_loc, 'oregon/d5_dem_est_agg.qs'),
#   'https://drive.google.com/file/d/1-Y9yvQuEuFn80lhAvB0vn6VZw4ScD-md/view?usp=sharing',
#   overwrite = T)

or4 <- read_data(paste0(d_loc, 'oregon/d4_dem_est_allcases_pii.qs')) %>%
  mutate(state = 'oregon') 

or4 <- or4 %>%
  # Subset to only columns found in other d4s
  select(unlist(intersect(names(or4), names(tx4))))

or5 <- read_data(paste0(d_loc, 'oregon/d5_dem_est_agg.qs')) %>%
  mutate(state = 'oregon') 

or5 <- or5 %>%
  # Subset to only columns found in other d5s
  select(unlist(intersect(names(or5), names(tx5))))

# Virginia
va3 <- read_data(paste0(d_loc, 'virginia/d3_clean_names.qs')) %>%
  mutate(state = 'virginia') 

# Illinois - GOING THROUGH UPDATE NOW
# googledrive::drive_download(
#   path = paste0(d_loc, 'illinois/d4_dem_est_allcases_pii.qs'),
#   'https://drive.google.com/file/d/101oALxelUFnVxCDG3PfGYkJigGG1TiLX/view?usp=sharing',
#   overwrite = T)
# 
# googledrive::drive_download(
#   path = paste0(d_loc, 'illinois/d5_dem_est_agg.qs'),
#   'https://drive.google.com/file/d/1SfEosmIx_fNVVe1O_qxMKfHWWmvxp9n3/view?usp=sharing',
#   overwrite = T)
# 
# il4 <- read_data(paste0(d_loc, 'illinois/d4_dem_est_allcases_pii.qs'))
# il5 <- read_data(paste0(d_loc, 'illinois/d5_dem_est_agg.qs')) %>%
#   mutate(state = 'illinois')

#===============================
# County-level counts
#===============================

d_co_raw <<- 
  read_data("~/data/evictionresearch/lsc/output/county_counts_2022_12_19.qs") %>%
  mutate(state = case_when(
    state == 'puerto_rico' ~ 'puerto rico',
    state == 'south_carolina' ~ 'south carolina',
    state == 'virgin_islands' ~ 'virgin islands',
    TRUE ~ state
  ),
  fips = as.character(fips),
  fips = case_when(
    nchar(fips) == 4 ~ paste0('0', fips),
    TRUE ~ fips
  ),
  state = str_to_title(state))

# Load monthly & weekly & events files
monthly_2022_12_19 <- read.csv('monthly_2022_12_19.csv') %>% distinct()
weekly_2022_12_19 <- read.csv('weekly_2022_12_19.csv') %>% distinct()
events_2022_12_19 <- read_data('events_2022_12_19.csv') %>% distinct()

head(monthly_2022_12_19)
head(weekly_2022_12_19)
head(events_2022_12_19)

monthly <-
  monthly_2022_12_19 %>%
  mutate(
    date = as.Date(month_start_date),
    month = month(date),
    year = year(date),
    fips = as.character(fips),
    fips = case_when(
      nchar(fips) == 4 ~ paste0('0', fips),
      TRUE ~ fips)
  ) %>%
  rename(filings = count) %>%
  select(month, year, state, county, fips, filings, date)

head(monthly)

weekly <-
  weekly_2022_12_19 %>%
  mutate(
    fips = as.character(fips),
    fips = case_when(
      nchar(fips) == 4 ~ paste0('0', fips),
      TRUE ~ fips),
    date = as.Date(date_filed),
    month = month(date),
    year = year(date),
  ) %>%
  rename(filings = count) %>%
  select(month, year, state, county, fips, filings, date)

head(weekly)

d_co <- rbind(d_co_raw, monthly, weekly) %>% mutate(state = tolower(state))

list_states <- unique(d_co$state)
list_states

# Pull # of renter households & # of renter households by race from ACS

acs_renter_vars <-
  c('totten' = 'B25003_001',
    'totrent' = 'B25003_003',
    'totrentWHT' = 'B25003A_003',
    'totrentBLK' = 'B25003B_003',
    'totrentASI' = 'B25003D_003',
    'totrentWHTNL' = 'B25003H_003',
    'totrentLAT' = 'B25003I_003')

years <- lst(2016, 2017, 2018, 2019, 2020, 2021)

# loop over list of years and get 1 year acs estimates
bay_area_multi_year <- map_dfr(
  years,
  ~ get_acs(
    geography = "county",
    variables = acs_renter_vars,
    state = list_states,
    year = .x,
    survey = "acs5",
    geometry = FALSE
  ),
  .id = "year"  # when combining results, add id var (name of list item)
) %>%
  select(-moe, -NAME) %>%
  pivot_wider(names_from = "variable", values_from = "estimate", 
              values_fill = 0) %>%
  group_by(GEOID) %>%
  mutate(
    totrentOTH = totrent - sum(totrentBLK, totrentASI, totrentWHTNL, 
                               totrentLAT, na.rm = TRUE),
    p_renter = replace_na(totrent/totten, 0),
  ) %>%
  mutate(totrentOTH = case_when(totrentOTH < 0 ~ 0, TRUE ~ totrentOTH)) %>%
  ungroup()

# Just use 2021 data for 2022
co_acs <-
  bay_area_multi_year %>%
  rbind(bay_area_multi_year %>% filter(year == 2021) %>% mutate(year = 2022)) %>%
  mutate(year = as.numeric(year))

lsc_counties <-
  d_co %>%
  left_join(co_acs, by = c('year', 'fips' = 'GEOID')) %>%
  rename(county_fips = fips, cases = filings) %>%
  mutate(year = year(date), month = month(date)) %>%
  select(-date)

head(lsc_counties)
summary(lsc_counties)


#===============================
# Bind them together
#===============================

# Individual-level (Note: VA doesn't have demographic estimation so these
# fields will be blank)
final4 <- bind_rows(ga4, de4, in4, mn4, mo4, pa4, tx4, fl4, sc4, oh4, ca4, or4, 
                    ct4, va3) # il4

# Aggregated (either tract or county level) - should follow this format:
# https://docs.google.com/spreadsheets/d/18kAoMxz877YJg0d-O_RlYVd13sBvN82vsRGBS_YOzxQ/edit#gid=0
final5 <- bind_rows(ga5, de5, in5, mn5, mo5, pa5, tx5, fl5, sc5, oh5, ca5, or5,
                    ct5, lsc_counties) %>% # il5
  mutate(county_fips = case_when(
    is.na(county_fips) ~ substr(geoid, 1, 5),
    TRUE ~ county_fips
  ))

glimpse(final4)
glimpse(final5)

table(final4$state)
table(final5$state)

# Save
write_data(final4, paste0(d_loc, 'all_states/d4_all_states.qs'))
write_data(final5, paste0(d_loc, 'all_states/d5_all_states.qs'))

# Upload to google drive
drive_upload(
  paste0(d_loc, '/all_states/d4_all_states.qs'),
  as_dribble('https://drive.google.com/drive/u/0/folders/1QrNdABLbdoD2VWsDzkIhoXpDiZvtuo8D'), 
  overwrite = TRUE
)

drive_upload(
  paste0(d_loc, '/all_states/d5_all_states.qs'),
  as_dribble('https://drive.google.com/drive/u/0/folders/1QrNdABLbdoD2VWsDzkIhoXpDiZvtuo8D'), 
  overwrite = TRUE
)

#===============================
# Most recent dates?
#===============================

final4 %>%
  mutate(good_date = ymd(paste0(as.character(year), "-", as.character(month), 
                                "-01"))) %>%
  group_by(state) %>%
  summarize(recent = max(good_date, na.rm = T))

#===============================
# Table for Tim
#===============================

table(final4$state)
table(final5$state)

state_counties <- final4 %>%
  mutate(good_date = case_when(
    !is.na(date_filed) ~ as.Date(date_filed),
    TRUE ~ ymd(paste0(as.character(year), "-", as.character(month), 
                      "-01")))) %>%
  group_by(state) %>% 
  summarise(
    county_list = paste(unique(str_replace(tolower(county), ' county', '')),
                        collapse = ', '),
    num_counties = n_distinct(county),
    time_range = paste(min(good_date, na.rm = T), max(good_date, na.rm = T), 
                       sep = " - ")) %>%
  left_join(
    fips_codes %>%
      mutate(state = tolower(state_name)) %>%
      filter(tolower(state) %in% tolower(final4$state)) %>%
      group_by(state) %>%
      summarize(total_counties = n_distinct(county))
  ) %>%
  data.frame() %>%
  mutate(prop_counties = num_counties/total_counties,
         geo_available = case_when(
           state %in% c('california', 'connecticut', 'delaware', 'florida',
                        'georgia', 'illinois', 'indiana', 'minnesota', 
                        'missouri', 'ohio', 'oregon', 'south carolina',
                        'tennessee') ~ 'address',
           state %in% c('pennsylvania', 'texas') ~ 'address & zip',
           state == 'virginia' ~ 'zip'
         ))

state_counties

# Save
write.csv(state_counties, paste0(d_loc, 'all_states/policylink_table.csv'),
          row.names = F)

state_counties_co <- d_co %>%
  group_by(state) %>%
  summarise(
    county_list = paste(unique(str_replace(tolower(county), ' county', '')),
                        collapse = ', '),
    num_counties = n_distinct(county),
    time_range = paste(min(date, na.rm = T), max(date, na.rm = T), 
                       sep = " - ")) %>%
  left_join(
    fips_codes %>%
      mutate(state = tolower(state_name)) %>%
      filter(tolower(state) %in% tolower(d_co$state)) %>%
      group_by(state) %>%
      summarize(total_counties = n_distinct(county))
  ) %>%
  data.frame() %>%
  mutate(prop_counties = num_counties/total_counties,
         geo_available = 'county') %>%
  rename_with(.fn = function(.x){paste0("co_", .x)},
              .cols = county_list:geo_available)

state_counties_co

# Save
write.csv(state_counties_co, paste0(d_loc, 'all_states/policylink_table_county.csv'),
          row.names = F)

# States that are in both datasets?
intersect(state_counties$state, state_counties_co$state)

nrow(state_counties)
nrow(state_counties_co)

state_counties_both <-
  state_counties %>%
  full_join(state_counties_co, by = 'state')

nrow(state_counties_both)

state_counties_both %>% 
  filter(county_list != co_county_list)

state_counties_both %>% 
  filter(num_counties != co_num_counties)

state_counties_both %>% 
  filter(geo_available != co_geo_available)

state_counties_both %>% 
  filter(time_range != co_time_range)

# Are all the counties in address-level data also in county-level data?

add_counties <- final4 %>%
  select(state, county) %>%
  mutate(county_add = paste0(state, '_', str_replace(tolower(county), 
                                                     ' county', ''))) %>%
  select(county_add) %>%
  distinct()

head(add_counties)

co_counties <- d_co %>%
  select(state, county) %>%
  mutate(county_co = paste0(state, '_', str_replace(tolower(county), 
                                                    ' county', ''))) %>%
  distinct()

head(co_counties)

setdiff(add_counties$county_add, co_counties$county_co)

# counties_both <- add_counties %>% full_join(co_counties)
# head(counties_both)
