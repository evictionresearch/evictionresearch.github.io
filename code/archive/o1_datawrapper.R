# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
# ==========================================================================
# All States Datawrapper Visualizations
# Step 1: Create google sheets in appropriate state folder 
# https://drive.google.com/drive/folders/1HntbNztMWbKjH7MZRb55ZzijizQIj86U
# Datawrapper folder is here: 
# https://app.datawrapper.de/archive/team/EWxQYwus
# Run on your personal machine.
# ==========================================================================

rm(list=ls()) # remove objects
options(width=Sys.getenv("COLUMNS"), setWidthOnResize=TRUE, scipen=10) # option when using terminal
if(!require(librarian)) install.packages('librarian') # in case you don't have this package
shelf(skimr, scales, janitor, googlesheets4, munichrocker/DatawRappr, timathomas/colorout, timathomas/neighborhood, tidycensus, fable, tsibble, tsibbledata, tidyverse)
if (!exists("read_data")) for (.p in c("~/git/evictionresearch/library/code/io_helpers.R","~/users/timthomas/git/evictionresearch/library/code/io_helpers.R","/accounts/projects/timthomas/git/evictionresearch/library/code/io_helpers.R")) if (file.exists(.p)) { source(.p); break }

# ==========================================================================
# Load data
# ==========================================================================

as <- 
  read_csv("/accounts/projects/timthomas/udp/data/evictionresearch/all_states/lsc_monthly_20240312.csv") %>% 
  mutate(
    date = date(date), 
    month = month(date),
    year = year(date),
    ym_date = yearmonth(date), 
    geography = 
      case_when(
        nchar(fips) == 2 ~ "state", 
        nchar(fips) == 5 ~ "county"
        )
    )

glimpse(as)

#
# What's the max and min dates available
#

as %>% group_by(fips) %>% summarize(date = max(date)) %>% count(date)
as %>% group_by(fips) %>% summarize(date = min(date)) %>% count(date)

#
# Explore which places have min dates that are far back enough
#

  as %>% 
  group_by(fips) %>% 
  mutate(min_date = min(date)) %>% 
  filter(min_date == "2019-01-01") %>%
  data.frame()

# ==========================================================================
# Create forecast table
# ==========================================================================

as_ts <- 
  as %>%
  select(fips, state_fips, geography, name, date, year, month, ym_date, filings = filings_count) %>% 
  tsibble(key = fips, index = ym_date) 

# ==========================================================================
# ==========================================================================
# BEGIN STATE TESTBED
# ==========================================================================
#
# Study state
#
state = "Hawaii"

#
# Forecast expected (historical average)
#
test_exp <- 
  as_ts %>% 
  filter(name == state, geography == "state", date <= "2020-02-01", year >= 2016) %>% 
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "15 years") 

test_exp %>% 
  autoplot(filter(as_ts, year >= 2016))

#
# Forecast observed
#
test_obs <- 
  as_ts %>% 
  filter(name == state, geography == "state", year >= 2016) %>% 
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "15 years") 

test_obs %>% 
  autoplot(filter(as_ts, year >= 2016), level = NULL)

ggplot(filter(as_ts, name == state, geography == "state", year >= 2016),
    aes(x = ym_date, y = filings)) + 
  geom_line() + 
  geom_line(
    data = as_tibble(test_exp), 
    aes(x = ym_date, y = .mean), color = "#50A1C7") +  
  geom_line(
    data = as_tibble(test_obs), 
    aes(x = ym_date, y = .mean), color = "#C7505B") 

#
# Combine
#
test_forecast <- 
  as_ts %>% 
  filter(name == state, geography == "state") %>% 
  select(fips, ym_date, filings) %>%
  full_join(
    as_tibble(test_exp) %>% 
    select(fips, ym_date, exp_forecast = .mean) 
    ) %>% 
  full_join(
    as_tibble(test_obs) %>%
    select(fips, ym_date, obs_forecast = .mean)
    ) %>% 
  filter(year(ym_date) < 2035) %>%
  mutate(
    adj_exp = if_else(is.na(exp_forecast), filings, exp_forecast), 
    adj_obs = if_else(is.na(obs_forecast), filings, obs_forecast) 
    ) %>% 
  filter(year(ym_date) >= 2019) %>%
  mutate(
    cum_exp = cumsum(adj_exp), 
    cum_obs = cumsum(adj_obs), 
    diff = cum_obs - cum_exp, 
    ha = case_when(
        cum_exp == 0 & cum_obs == 0 ~ 0, 
        cum_exp == 0 & cum_obs > 0 ~ cum_obs,
        TRUE ~ ((cum_obs/cum_exp)-1)*100
        )
    ) %>% 
  as_tibble()
summary(test_forecast)

net_zero_month <- test_forecast %>% filter(diff > 0) %>% summarize(date = min(ym_date)) %>% pull(date)

#
# Plot month
#
plotly::ggplotly(
  ggplot(test_forecast %>% filter(ym_date <= net_zero_month + 12)) + 
    geom_line(aes(x = ym_date, y = cum_exp), color = "#50A1C7") + 
    geom_line(aes(x = ym_date, y = cum_obs), color = "#C7505B") + 
    geom_vline(xintercept = test_forecast %>% filter(diff > 0) %>% summarize(date = min(ym_date)) %>% pull(date), linetype = "dashed") + 
    labs(
      x = "", 
      y = "Filings",
      title = 
        paste0(state, ": ", net_zero_month - yearmonth(Sys.Date()), " months till net-zero ", "(", net_zero_month, ")"
        )
      ) + 
    scale_y_continuous(labels = scales::comma) 
  )
  
# ==========================================================================
# END TESTBED
# ==========================================================================
# ==========================================================================


# ==========================================================================
# Forecast states
# ==========================================================================

#
# Forecast expected (historical average)
#
state_exp <- 
  as_ts %>% 
  filter(geography == "state", date <= "2020-02-01", year >= 2016, name != "Hawaii") %>% 
  group_by_key() %>% 
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "20 years") 

state_exp %>% 
filter(fips == 27) %>% # Minnesota
autoplot(filter(as_ts, year >= 2016), level = NULL)

#
# Forecast observed
#
state_obs <- 
  as_ts %>% 
  filter(geography == "state", year >= 2016, name != "Hawaii") %>% 
  fill_gaps() %>%
  group_by_key() %>%
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "17 years") 

state_obs %>% 
  filter(fips == 27) %>% # Minnesota
  autoplot(filter(as_ts, year >= 2016), level = NULL)

ggplot(filter(as_ts, fips == 27, year >= 2016),
    aes(x = ym_date, y = filings)) + 
  geom_line() + 
  geom_line(
    data = filter(as_tibble(state_exp), fips == 27), 
    aes(x = ym_date, y = .mean), color = "#50A1C7") +  
  geom_line(
    data = filter(as_tibble(state_obs), fips == 27), 
    aes(x = ym_date, y = .mean), color = "#C7505B") 

#
# Combine
#
state_fips <- 
  as_ts %>% 
  filter(geography == "state", name != "Hawaii") %>% 
  pull(fips) %>% 
  unique()

state_forecast <- 
  map_dfr(state_fips, function(study_fips){
      as_ts %>% 
      filter(fips == study_fips, geography == "state") %>% 
      select(fips, ym_date, filings) %>%
      full_join(
        as_tibble(state_exp) %>% 
        filter(fips == study_fips) %>%
        select(fips, ym_date, exp_forecast = .mean) 
        ) %>% 
      full_join(
        as_tibble(state_obs) %>%
        filter(fips == study_fips) %>%
        select(fips, ym_date, obs_forecast = .mean)
        ) %>% 
      # filter(year(ym_date) < 2035) %>% 
      mutate(
        adj_exp = if_else(is.na(exp_forecast), filings, exp_forecast), 
        adj_obs = if_else(is.na(obs_forecast), filings, obs_forecast) 
        ) %>% 
      filter(year(ym_date) >= 2019) %>%
      mutate(
        cum_exp = cumsum(adj_exp), 
        cum_obs = cumsum(adj_obs), 
        diff = cum_obs - cum_exp, 
        ha = case_when(
            cum_exp == 0 & cum_obs == 0 ~ 0, 
            cum_exp == 0 & cum_obs > 0 ~ cum_obs,
            TRUE ~ ((cum_obs/cum_exp)-1)*100
            )
        ) %>% 
      left_join(fips_codes %>% select(fips = state_code, state_name) %>% distinct()) %>%
      as_tibble()
  }
  )

glimpse(state_forecast)
state_forecast %>% filter(fips == "02") 

ggplot(filter(as_ts, fips == "27", year >= 2016),
    aes(x = ym_date, y = filings)) + 
  geom_line() + 
  geom_line(
    data = filter(as_tibble(state_exp), fips == "27"), 
    aes(x = ym_date, y = .mean), color = "#50A1C7") +  
  geom_line(
    data = filter(as_tibble(state_obs), fips == "27"), 
    aes(x = ym_date, y = .mean), color = "#C7505B") 

#
# Which states meet net_zero?
# --------------------------------------------------------------------------

net_zero_states <- 
  state_forecast %>% 
  filter(diff > 0) %>% 
  group_by(state_name) %>%
  summarize(
    net_zero_date = min(ym_date)
    ) %>% 
  arrange(net_zero_date)


#
# Plot net_zero_states
#

pick_state <- function(x){net_zero_states %>% slice(x)}

st <- pick_state(10)

plotly::ggplotly(
  ggplot(state_forecast %>% filter(state_name == st$state_name, year(ym_date) < 2030)) + 
    geom_line(aes(x = ym_date, y = cum_exp), color = "#50A1C7") + 
    geom_line(aes(x = ym_date, y = cum_obs), color = "#C7505B") + 
    geom_vline(xintercept = st$net_zero_date, linetype = "dashed") + 
    labs(
      x = "", 
      y = "Filings",
      title = 
        paste0(st$state_name, ": ", st$net_zero_date - yearmonth(Sys.Date()), " months till net-zero ", "(", st$net_zero_date, ")"
        )
      ) + 
    scale_y_continuous(labels = scales::comma) 
  )

# ==========================================================================
# All state netzero graph
# ==========================================================================

all_states <- 
  state_forecast %>% 
  group_by(ym_date) %>% 
  reframe(
    adj_exp = sum(adj_exp), 
    adj_obs = sum(adj_obs)) %>% 
  mutate(
    cum_exp = cumsum(adj_exp), 
    cum_obs = cumsum(adj_obs), 
    diff = cum_obs - cum_exp, 
    ha = case_when(
        cum_exp == 0 & cum_obs == 0 ~ 0, 
        cum_exp == 0 & cum_obs > 0 ~ cum_obs,
        TRUE ~ ((cum_obs/cum_exp)-1)*100
        ),
    ha_monthly = case_when(
        adj_exp == 0 & adj_obs == 0 ~ 0, 
        adj_exp == 0 & adj_obs > 0 ~ adj_obs,
        TRUE ~ ((adj_obs/adj_exp)-1)*100
        )
      )

ggplot(all_states,
    aes(x = ym_date, y = ha_monthly)) + 
  geom_line() + 
  geom_line(
    data = filter(as_tibble(state_exp), fips == "27"), 
    aes(x = ym_date, y = .mean), color = "#50A1C7") +  
  geom_line(
    data = filter(as_tibble(state_obs), fips == "27"), 
    aes(x = ym_date, y = .mean), color = "#C7505B") 

net_zero_states <- 
  all_states %>% 
  filter(diff > 0) %>% 
  group_by(state_name) %>%
  summarize(
    net_zero_date = min(ym_date), 
    forecast_date = 
      case_when(

        )
    ) %>% 
  arrange(net_zero_date)

plotly::ggplotly(
  ggplot(all_states) + 
    geom_line(aes(x = ym_date, y = cum_exp), color = "#50A1C7") + 
    geom_line(aes(x = ym_date, y = cum_obs), color = "#C7505B") + 
    geom_vline(xintercept = st$net_zero_date, linetype = "dashed") + 
    labs(
      x = "", 
      y = "Filings",
      title = 
        paste0("U.S.: ", st$net_zero_date - yearmonth(Sys.Date()), " months till net-zero ", "(", st$net_zero_date, ")"
        )
      ) + 
    scale_y_continuous(labels = scales::comma) 
  )
  as_ts %>% 
      filter(geography == "state") %>% 
      select(fips, ym_date, filings) %>%
      full_join(
        as_tibble(state_exp) %>% 
        filter(fips == study_fips) %>%
        select(fips, ym_date, exp_forecast = .mean) 
        ) %>% 
      full_join(
        as_tibble(state_obs) %>%
        filter(fips == study_fips) %>%
        select(fips, ym_date, obs_forecast = .mean)
        ) %>% 
      # filter(year(ym_date) < 2035) %>% 
      mutate(
        adj_exp = if_else(is.na(exp_forecast), filings, exp_forecast), 
        adj_obs = if_else(is.na(obs_forecast), filings, obs_forecast) 
        ) %>% 
      filter(year(ym_date) >= 2019) %>%
      mutate(
        cum_exp = cumsum(adj_exp), 
        cum_obs = cumsum(adj_obs), 
        diff = cum_obs - cum_exp, 
        ha = case_when(
            cum_exp == 0 & cum_obs == 0 ~ 0, 
            cum_exp == 0 & cum_obs > 0 ~ cum_obs,
            TRUE ~ ((cum_obs/cum_exp)-1)*100
            )
        ) %>% 
      left_join(fips_codes %>% select(fips = state_code, state_name) %>% distinct()) %>%
      as_tibble()
### LEFT OFF - looking at states meeting HA 
# ==========================================================================
# ==========================================================================
# ==========================================================================
# Excess code
# ==========================================================================
# ==========================================================================
# ==========================================================================



as_exp <- 
  as_ts %>% 
  group_by(fips) %>%
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "10 years") 

as_exp %>% 
  autoplot(filter(as_ts, year >= 2016))

as_obs <- 
  as_ts %>% 
  filter(name == "Minnesota", year >= 2016) %>% 
  model(
    # ets = ETS(box_cox(filings, 0.3)), # needs three years of data
    # arima = ARIMA(log(filings)), # needs two years of data
    snaive = SNAIVE(filings) # needs one year of data
  ) %>%
  forecast(h = "10 years") 

as_obs %>% 
  autoplot(filter(as_ts, year >= 2016))

data.frame()

aus_retail %>%
  filter(
    State %in% c("New South Wales", "Victoria"),
    Industry == "Department stores"
  ) %>% 
  model(
    ets = ETS(box_cox(Turnover, 0.3)),
    arima = ARIMA(log(Turnover)),
    snaive = SNAIVE(Turnover)
  ) %>%
  forecast(h = "2 years") %>% data.frame()
  autoplot(filter(aus_retail, year(Month) > 2010), level = NULL)


#
# Get ha counts from 2019
# --------------------------------------------------------------------------

as_ha <- 
  as %>%
  filter(year == 2019) %>%
  group_by(month, fips, geography) %>%
  summarize(ha = sum(filings_count, na.rm = TRUE))

glimpse(as_ha)

#
# create observed & expected
# --------------------------------------------------------------------------

as_oe <- 
  as %>%
  filter(
    date >= "2019-01-01", 
    !str_detect(fips, "^15") # data starts in 2020
    ) %>%
  group_by(date, fips, name, geography) %>%
  summarize(filings = sum(filings_count, na.rm = TRUE)) %>%
  mutate(month = month(date)) %>%
  left_join(as_ha) %>% 
  group_by(fips) %>%
  mutate(
    year = year(date),
    min_date = min(date), 
    cumulative_ha = cumsum(ha), 
    cumulative_observed = cumsum(filings), 
    diff = cumulative_observed - cumulative_ha,
    net_zero = 
      case_when(
        cumulative_ha == 0 & cumulative_observed == 0 ~ 0, 
        cumulative_ha == 0 & cumulative_observed > 0 ~ cumulative_observed,
        TRUE ~ ((cumulative_observed/cumulative_ha)-1)*100
        )
    )

glimpse(as_oe)

# ==========================================================================
# Create forecast
# ==========================================================================
#
# create monthly counts
# --------------------------------------------------------------------------
monthly <- 
  as_oe %>% 
  group_by(fips)



# Monthly time series
monthlyts <- ts(as_oe$filings, start=c(2016, 1), end=c(2022, 4), frequency=12)
# Monthly forecast
mo_forecast <- forecast(monthlyts) %>% data.frame() %>% mutate(date = my(point))

pre_pan_monthly <- forecast(window(monthlyts, start=c(2016, 1), end=c(2020, 1)), h = 27)

for_pan <-
  monthly %>%
  filter(date >= "2020-02-01") %>%
  cbind(pre_pan_monthly) %>%
  mutate(`Point Forecast` = case_when(date == "2020-02-01" ~ filings, TRUE ~ `Point Forecast`))


glimpse(as_oe)
summary(as_oe)
as_oe %>% filter(is.infinite(net_zero)) %>% glimpse()
as_oe %>% filter(is.na(net_zero)) %>% glimpse()

count(as_oe, net_zero) %>% arrange(desc(net_zero)) %>% filter(!is.infinite(net_zero)) %>% summary()

as_oe %>% filter(name == "Indiana") %>% data.frame()
as_oe %>% group_by(fips) %>% filter(max(date))

# ==========================================================================
# Calculate net zero
# ==========================================================================






  %>% 
  reframe(
    date = date,
    `Historical Average` = ((filings/ha)-1)*100
    )

state_net <- 
  as %>% 
  filter(geography == "state") %>% 
  mutate(
    ha = 
    )
  group_by(fips) %>% 
  summarize(date = max(date)) %>% 
  count(date)

count(as, geography)



agg %>%
  filter(year == 2019) %>%
  group_by(month) %>%
  summarize(ha = sum(filings, na.rm = TRUE))
# ==========================================================================
# Step 1:
# 1. Go to ERN public data Google Drive folder
# https://drive.google.com/drive/folders/1HntbNztMWbKjH7MZRb55ZzijizQIj86U
# 2. Create a state folder (if there's not one already for where you're working).
# 3. Create a blank spreadsheet and name it `eviction_data`. The following code 
# will populate this sheet appropriately.
# ==========================================================================
# Step 2:
# Follow the code
# ==========================================================================

# ==========================================================================
# Apply DataWrapper credentials
# ==========================================================================

#
# DW credentials
# --------------------------------------------------------------------------
datawrapper_auth(api_key = "KCnK7iz8JLcAjx5mbsEna8HRMeHXIEgp5VVX99weoWPERQVcvFBz5ss390iwKpMn", overwrite = TRUE) # DO NOT SHARE!!!
dw_test_key() # this will confirm the key works

# ===============================================
# Set user-defined inputs
# ===============================================

long_state <- "oregon"
short_state <- "OR"
end_month = "2023-11-01" # Final month in which data is complete
sheet_url <- # This is the URL for the Google Sheet you just created
  gs4_get("https://docs.google.com/spreadsheets/d/1Ciy1CZbwofj_LKXFTqnKKr3fEdRqqNLSmsisAEQ9ecA/edit#gid=0")
# choose new 1 if this is the first time so you can set up Google authentication.
# choose your username if you've already set an AUTH code

# ==========================================================================
# Load data
# ==========================================================================

#
# Load in aggregated data for plots
# --------------------------------------------------------------------------
# NOTE: This data file has everything you will need to curate data for plots
# Also note that Oregon has circuit court, justice court, and both courts in 
# certain counties. Our data consists of circuit court and we will add justice 
# court when EIO provides it. Make the disclaimer in the plots too. Lane county is 
# the only county that is multiple court that we will include because 98% of cases 
# are circuit court. For which counties are which, see: 
# https://www.evictedinoregon.com/data-availability
# --------------------------------------------------------------------------

omit_counties <- c("Clackamas", "Douglas", "Linn", "Malheur", "Marion", "Morrow", "Tillamook", "Baker", "Gilliam", "Grant", "Harney", "Sherman", "Wheeler")

agg <- 
  read_data(
    paste0(
      '~/users/timthomas/git/evictionresearch/', long_state, 
      # '~/git/evictionresearch/', long_state, # for local
      '/data/d5_case_aggregated.qs'
      )
    ) %>% 
  filter(
    !county %in% omit_counties, 
    plot_date <= end_month 
    )

summary(agg)
glimpse(agg)
# ==========================================================================
# TESTBED DEV - RR
# agg %>% 
# ungroup() %>% 
# reframe(
#   renters = pums_total,
#   group_renters = pums_white, 
#   all_other_renters = renters - group_renters, 
#   filings = sum(filings, na.rm = TRUE), 
#   group_filings = sum(white_head, na.rm = TRUE), 
#   all_other_filings = filings - group_filings
#   ) %>% 
# distinct() %>% 
# slice(4) %>% 
# mutate(rr = (group_filings/group_renters)/(all_other_filings/all_other_renters))
# # 1.73 black
# # 1.73 latine
# # 0.943 other
# # 0.462 white


# select(tract_geoid, county, year, co_totrent, co_totrent_black, filings, black_head) %>% 
# distinct() %>%
# glimpse()
# reframe(
#   renters = co_totrent,
#   black_renters = co_totrent_black, 
#   all_other_renters = renters - black_renters, 
#   filings = 
#   )

# mutate(
#   rr = )
# ==========================================================================


# ==========================================================================
#
# EDA
#
dim(agg)
glimpse(agg)
summary(agg)

# ==========================================================================
# Curate data for pancake plot
# ==========================================================================

county_counts <-
  agg %>%
  filter(plot_date <= end_month, year >= 2019) %>%
  group_by(county, plot_date) %>%
  reframe(filings = sum(filings)) %>%
  mutate(county = paste0(county, " County")) %>%
  group_by(county) %>% # rearrange the counties for a prettier plot
  mutate(total = sum(filings)) %>%
  arrange(total) %>%
  select(-total) %>%
  pivot_wider(
    names_from = county,
    values_from = filings
    )

glimpse(county_counts)
data.frame(county_counts)
county_counts %>% select(plot_date, `Multnomah County`) %>% data.frame()

#
# Upload data to google sheets
# --------------------------------------------------------------------------
# NOTE: the `sheet` option will create a sheet of the given name for the spreadsheet you created.
# --------------------------------------------------------------------------
sheet_write(
  data = county_counts,
  ss = sheet_url,
  sheet = "County Counts"
  )

# ==========================================================================
# NEXT DEV UPDATE: incorporate DatawRappr package into the code
# For now, follow the manual instructions below...
# ==========================================================================
# Step 3:
# *** FOR NEW PLOTS ***
# 1. go to the Eviction Research DataWrapper team page,
# https://app.datawrapper.de/archive/team/EWxQYwus
# 2. Create a folder for your state (if doesn't already exist).
# 3. Copy the the plots in the Oregon folder to your new folder (this will be the most up-to-date plot configuration).
#   a. select a plot
#   b. click on the 3 vertical dots in the upper right corner
#   c. choose duplicate
#   d. drag copies to your new state folder on the left column
#   e. repeat steps a-d for each plot
# 4. Edit the plot
#   a. copy the URL of the Google Sheets "sheet" that has the data you want to work with.
#   b. go to `Upload Data` and make sure "Connect Google Sheet" is selected and paste the Google Sheet's sheet URL on the right.
#   c. Check the data and make sure it looks right
#   d. Visualize: check all the tabs and change what's needed. For the pancake plot, it should have the county with the most filings at the top and least at the bottom and look like it's in order of cases.
#   e. Once you're happy with the plot,
#     * publish the plot
#     * choose the `New: Embed with  script` radio button
#     * Copy the "Embed Code for your visualization" script
#   d. Using a text editor, open the `~/git/evictionresearch/[state repo]/index.html` file under and paste the new script under `<!-- Count pancake graph -->` starting with the next `<div...` chunk that you see. This is important because even republishing changes this code chunk.
#
# *** Republishing edits ***
# After the first publication, each time you edit a plot thereafter you will need to republish it replace the current script in the index.html file with the new script to show updates.
#
# Always open your index.html locally in a browser and check that your changes were made appropriately.
# In the republish page, choose the `New: Embed with  script` radio button and copy the `Embed code for your visualization code` and paste it on the appropriate line in `~/git/evictionresearch/[state repo]/index.html` file under `<!-- Count pancake graph -->` starting with the next `<div...` chunk that you see. This is important because republishing changes this code chunk.
# ==========================================================================

# ==========================================================================
# Create Historical Average Plot
# ==========================================================================

ha <- 
  agg %>%
  filter(year == 2019) %>%
  group_by(month) %>%
  summarize(ha = sum(filings, na.rm = TRUE))

ha
mean(ha$ha) 
min(ha$ha) 
max(ha$ha) 
sum(ha$ha)

#
# Take the sum, min, max, and mean "ha" value and put it in the text when 
# describing this plot.
#

ha_counts <- 
  agg %>%
    filter(plot_date >= "2020-01-01", plot_date <= end_month) %>%
    group_by(plot_date) %>%
    summarize(filings = sum(filings, na.rm = TRUE)) %>%
    mutate(month = month(plot_date)) %>%
    left_join(ha) %>% 
    reframe(
      plot_date = plot_date,
      `Historical Average` = ((filings/ha)-1)*100
      )

data.frame(ha_counts)

#
# Upload to google sheets
#
sheet_write(
  data = ha_counts,
  ss = sheet_url,
  sheet = "Historical Average"
  )

# ==========================================================================
# Step 4:
# Repeat step 3 for the historical average plot.
# ==========================================================================

# ==========================================================================
# Create Racial Disparity Plots
# ==========================================================================
# For these plots, we'll need to interpolate the demographics because not all cases were estimated. We will also aggregate these by year as 2023 is not complete
# ==========================================================================

# gather pums data and spread per year for estimates

demographic_rates <-
  agg %>%
  select(year, starts_with("pums")) %>% 
  distinct() %>%
  left_join(
    agg %>%
    select(year, filings, ends_with("_head")) %>%
    group_by(year) %>%
    summarize_at(vars(filings:white_female_head), ~sum(., na.rm = TRUE))
    ) %>%
  rowwise() %>%
  mutate(
    weight_r = sum(black_head, latine_head, other_head, white_head),
    weight_s = sum(male_head, female_head),
    weight_rs = sum(black_male_head, black_female_head, latine_male_head, latine_female_head, other_male_head, other_female_head, white_male_head, white_female_head),
    est_male_head = (male_head/weight_s)*filings,
    est_female_head = (female_head/weight_s)*filings,

    est_black_head = (black_head/weight_r)*filings,
    est_latine_head = (latine_head/weight_r)*filings,
    est_other_head = (other_head/weight_r)*filings,
    est_white_head = (white_head/weight_r)*filings,

    est_black_male_head = (black_male_head/weight_rs)*filings,
    est_black_female_head = (black_female_head/weight_rs)*filings,
    est_latine_male_head = (latine_male_head/weight_rs)*filings,
    est_latine_female_head = (latine_female_head/weight_rs)*filings,
    est_other_male_head = (other_male_head/weight_rs)*filings,
    est_other_female_head = (other_female_head/weight_rs)*filings,
    est_white_male_head = (white_male_head/weight_rs)*filings,
    est_white_female_head = (white_female_head/weight_rs)*filings,

    Male = (est_male_head/pums_male)*100,
    Female = (est_female_head/pums_female)*100,

    Black = (est_black_head/pums_black)*100,
    Latine = (est_latine_head/pums_latine)*100,
    Other = (est_other_head/pums_other)*100,
    White = (est_white_head/pums_white)*100,

    `Black Male` = (est_black_male_head/pums_black_male)*100,
    `Black Female` = (est_black_female_head/pums_black_female)*100,
    `Latine Male` = (est_latine_male_head/pums_latine_male)*100,
    `Latine Female` = (est_latine_female_head/pums_latine_female)*100,
    `Other Male` = (est_other_male_head/pums_other_male)*100,
    `Other Female` = (est_other_female_head/pums_other_female)*100,
    `White Male` = (est_white_male_head/pums_white_male)*100,
    `White Female` = (est_white_female_head/pums_white_female)*100,

    `Black to White` = Black/White,
    `Latine to White` = Latine/White,
    `Other to White` = Other/White,

    `Black Male to White Male` = `Black Male`/`White Male`,
    `Black Female to White Female` = `Black Female`/`White Female`,
    `Latine Male to Latine Female` = `Latine Male`/`White Male`,
    `Latine Female to White Female` = `Latine Female`/`White Female`,
    `Other Male to White Male` = `Other Male`/`White Male`,
    `Other Female to White Female` = `Other Female`/`White Female`,
    ) %>%
  select(year, filings, Male:`Other Female to White Female`) %>%
  distinct() %>%
  glimpse()

summary(demographic_rates)
glimpse(demographic_rates)
#
# Upload to google sheets
#
sheet_write(
  data = demographic_rates,
  ss = sheet_url,
  sheet = "Demographic Estimate Data"
  )

# ==========================================================================
# Repeat datawrapper steps from above
# ==========================================================================

# ==========================================================================
# Create table data
# ==========================================================================

county_df <-
  agg %>%
  group_by(county, year, month, plot_date) %>%
  reframe(
    filings = sum(filings),
    renters = co_totrent,
    mo_ev_rate =
      case_when(
        is.infinite(filings/renters) ~ 100,
        is.na(filings/renters) ~ 0,
        TRUE ~ (filings/renters)*100)
      ) %>%
  distinct()

summary(county_df)

county_table <-
  county_df %>%
    group_by(county) %>%
    reframe(
      total_filings = sum(filings, na.rm = TRUE),
      renters = unique(renters),
      total_rate = sum(mo_ev_rate, na.rm = TRUE)) %>%
    data.frame() %>%
  left_join(
  county_df %>%
    filter(plot_date >= max(plot_date, na.rm = TRUE) - months(11)) %>%
    group_by(county) %>%
    summarize(
      six_mo_filings = sum(filings, na.rm = TRUE),
      six_mo_rate = sum(mo_ev_rate, na.rm = TRUE)
      ) %>%
    na.omit() %>%
    distinct() %>%
    data.frame()
    ) %>%
  left_join(
  county_df %>%
    filter(plot_date >= max(plot_date, na.rm = TRUE) - months(11)) %>%
    select(county, plot_date, filings) %>%
    pivot_wider(names_prefix = "count_", names_from = plot_date, values_from = filings)
  ) %>%
  left_join(
  county_df %>%
    filter(plot_date >= max(plot_date, na.rm = TRUE) - months(11)) %>%
    select(county, plot_date, mo_ev_rate) %>%
    pivot_wider(names_prefix = "rate_", names_from = plot_date, values_from = mo_ev_rate)
    ) %>%
  select(County = county, `Filings in the last 12 months` = six_mo_filings, starts_with("count_2"), `Filing rate in the last 12 months` = six_mo_rate, starts_with("rate_2"), `Total filings since 2017` = total_filings, `Total filing rate since 2017` = total_rate, Renters = renters) %>% 
  distinct()

glimpse(county_table)

sheet_write(
  data = county_table,
  ss = sheet_url,
  sheet = "County Eviction Table"
  )

#
# Find the state filing rate in the past 12 months for webpagae text
#
sum(county_table$`Filings in the last 12 months`)/sum(county_table$Renters)
#
# Compare to 2019 state rate
#
sum(ha$ha)/sum(county_table$Renters)


# ==========================================================================
# Segregation plot
# ==========================================================================

rate_fun <- function(f, r){
    round(
      case_when(
        is.infinite(f/r) & f >= 1 ~ 100,
        is.infinite(f/r) & f < 1 ~ 0,
        is.na(f/r) ~ 0,
        f == 0 ~ 0,
        TRUE ~ (f/r)*100
      ), digits = 1
    )
}  

state_seg <-
  ntdf(
    state = short_state,
    year = 2021,
    geometry = FALSE
  ) %>% 
  clean_names() 

seg_df1 <- 
  state_seg %>% 
  left_join(    
    agg %>% 
    filter(plot_date >= ymd(end_month) - months(11)) %>%
    select(geoid = tract_geoid, renters = tr_totrent, filings, black_head:white_head, tr_totrent_black, tr_totrent_latine, tr_totrent_other, tr_totrent_white_nl) %>% 
    group_by(geoid) %>%
    reframe(
      renters = unique(renters),
      black_renters = unique(tr_totrent_black),
      latine_renters = unique(tr_totrent_latine),
      other_renters = unique(tr_totrent_other),
      white_renters = unique(tr_totrent_white_nl),
      filings = sum(filings), 
      black_head = sum(black_head),
      latine_head = sum(latine_head),
      other_head = sum(other_head),
      white_head = sum(white_head)
      ) 
    ) %>% 
  na.omit() %>% 
  group_by(nt_conc) %>% 
  reframe(
    # neigh_type = unique(neigh_type),
    tracts = n(),
    filings = sum(filings), 
    renters = sum(renters), 
    black_renters = sum(black_renters),
    latine_renters = sum(latine_renters),
    other_renters = sum(other_renters),
    white_renters = sum(white_renters),
    filings = sum(filings), 
    black_head = sum(black_head),
    latine_head = sum(latine_head),
    other_head = sum(other_head),
    white_head = sum(white_head)
    ) %>% 
  mutate(
    evr = rate_fun(filings, renters), 
    black_evr = rate_fun(black_head, black_renters), 
    latine_evr = rate_fun(latine_head, latine_renters), 
    other_evr = rate_fun(other_head, other_renters), 
    white_evr = rate_fun(white_head, white_renters)
    )

#
# Look at the number of tracts for each group and thoughtfully combine categories 
#

seg_df1
seg_df1 %>% select(nt_conc:renters, ends_with("evr")) %>% arrange(evr)

#
# Based on these numbers, we'll pull out Latine-Other because there are no
# evictions and is only 1 neighborhood and then combine 4 group and diverse
# into diverse. 
#

seg_df2 <- 
  state_seg %>% 
  left_join(    
    agg %>% 
    filter(plot_date >= ymd(end_month) - months(11)) %>%
    select(geoid = tract_geoid, renters = tr_totrent, filings, black_head:white_head, tr_totrent_black, tr_totrent_latine, tr_totrent_other, tr_totrent_white_nl) %>% 
    group_by(geoid) %>%
    reframe(
      renters = unique(renters),
      black_renters = unique(tr_totrent_black),
      latine_renters = unique(tr_totrent_latine),
      other_renters = unique(tr_totrent_other),
      white_renters = unique(tr_totrent_white_nl),
      filings = sum(filings), 
      black_head = sum(black_head),
      latine_head = sum(latine_head),
      other_head = sum(other_head),
      white_head = sum(white_head)
      ) 
    ) %>% 
  na.omit() %>% 
  filter(nt_conc != "Latine-Other") %>% 
  mutate(nt_conc = 
    case_when(
      nt_conc == "4 Group Mixed" ~ "Diverse", 
      TRUE ~ nt_conc
      )
    ) %>% 
  group_by(nt_conc) %>% 
  reframe(
    # neigh_type = unique(neigh_type),
    `Tract count` = n(),
    Renters = sum(renters), 
    `Black renters` = sum(black_renters),
    `Latine renters` = sum(latine_renters),
    `Other renters` = sum(other_renters),
    `White renters` = sum(white_renters),
    Filings = sum(filings), 
    `Black evictions` = round(sum(black_head)),
    `Latine evictions` = round(sum(latine_head)),
    `Other racial group evictions` = round(sum(other_head)),
    `White evictions` = round(sum(white_head))
    ) %>% 
  mutate(
    `Overall eviction rate` = rate_fun(Filings, Renters), 
    `Black eviction rate` = rate_fun(`Black evictions`, `Black renters`), 
    `Latine eviction rate` = rate_fun(`Latine evictions`, `Latine renters`), 
    `Other racial group eviction rate` = rate_fun(`Other racial group evictions`, `Other renters`), 
    `White eviction rate` = rate_fun(`White evictions`, `White renters`)
    ) %>% 
  arrange(`Overall eviction rate`)

seg_df2
glimpse(seg_df2)

sheet_write(
  data = seg_df2,
  ss = sheet_url,
  sheet = "Neighborhood Segregation Rates"
  )

# ==========================================================================
# Low income & eviction plot
# ==========================================================================

#
# County median incomes
# --------------------------------------------------------------------------
inc_df <- get_acs(
  geography = "county",
  variables = c('county_medinc' = 'B19013_001'),
  state = short_state,
  # year = 2021,
  geometry = FALSE,
  cache_table = FALSE,
  output = "wide",
  survey = "acs5"
) %>%
  rename(ami = county_medincE, ami_moe = county_medincM) %>%
  # Create a upper bound for low-income classification
  # Low-income status can be classified as earning below 80% of AMI
  # AMI, for this analysis, is considered as the county median income
  mutate(low_inc_bound = .8 * ami)

# write_data(inc_df, paste0("~/git/evictionresearch/", long_state, "/data/census/inc_df.qs"))

#
# ACS variables to pull
# --------------------------------------------------------------------------

income_vars <- c(
  #  "medinc" = "B19013_001",
  "income_less_10k_all" =  "B19001_002",
  "income_10k_15k_all" =   "B19001_003",
  "income_15k_20k_all" =   "B19001_004",
  "income_20k_25k_all" =   "B19001_005",
  "income_25k_30k_all" =   "B19001_006",
  "income_30k_35k_all" =   "B19001_007",
  "income_35k_40k_all" =   "B19001_008",
  "income_40k_45k_all" =   "B19001_009",
  "income_45k_50k_all" =   "B19001_010",
  "income_50k_60k_all" =   "B19001_011",
  "income_60k_75k_all" =   "B19001_012",
  "income_75k_100k_all" =  "B19001_013",
  "income_100k_125k_all" = "B19001_014",
  "income_125k_150k_all" = "B19001_015",
  "income_150k_200k_all" = "B19001_016",
  "income_200k_more_all" = "B19001_017"
)

#
# Download tract level ACS data
# --------------------------------------------------------------------------
acs <-
  get_acs(
    geography = "tract",
    variables = income_vars,
    state = short_state,
    # year = 2021,
    geometry = FALSE,
    cache_table = FALSE,
    survey = "acs5"
  ) %>%
  rename(num_hh = estimate, hh_moe = moe) %>%
  mutate(fips = str_sub(GEOID, 1, 5))

glimpse(acs)

# write_data(acs, paste0("~/git/evictionresearch/", long_state, "/data/census/inc_num_hh.qs"))

# Create data frame approximating income levels with their upper bounds.
# (DO NOT NEED TO EDIT inc_names OR inc_bounds)
income_levels <-
  data.frame(
    inc_names = c(
    'income_less_10k_all',
    'income_10k_15k_all',
    'income_15k_20k_all',
    'income_20k_25k_all',
    'income_25k_30k_all',
    'income_30k_35k_all',
    'income_35k_40k_all',
    'income_40k_45k_all',
    'income_45k_50k_all',
    'income_50k_60k_all',
    'income_60k_75k_all',
    'income_75k_100k_all',
    'income_100k_125k_all',
    'income_125k_150k_all',
    'income_150k_200k_all',
    'income_200k_more_all'),
    inc_bounds = c(
      9999,
      14999,
      19999,
      24999,
      29999,
      34999,
      39999,
      44999,
      49999,
      59999,
      74999,
      99999,
      124999,
      149999,
      199999,
      200000
      )
    )

inc_vars_join <- left_join(acs, income_levels, by = c('variable' = 'inc_names'))

glimpse(inc_vars_join)

#
# Approximate percent of low-income individuals by tract
# --------------------------------------------------------------------------
tr_inc <-
  inc_vars_join %>%
  group_by(NAME, GEOID, fips) %>%
  summarise('hh_total' = sum(num_hh, na.rm = TRUE)) %>% # sum total number of households in each tract
  left_join(
    inc_vars_join %>% select(GEOID, variable, inc_bounds, num_hh)) %>%
  left_join(
    inc_df %>% select(GEOID, ami, low_inc_bound),
    by = c('fips' = 'GEOID')) %>% 
  # filter out households in income classes above 80% of AMI
  filter(inc_bounds <= low_inc_bound, GEOID %in% unique(agg$tract_geoid)) %>%
  group_by(NAME, GEOID) %>%
  # find approximate percent of low-income households
  summarise('p_all_li' = unique(sum(num_hh, na.rm = TRUE) / hh_total)) %>%
  mutate( # create classifications for the popups
    'p_li_cat' =
      case_when(
        p_all_li < .1 ~ "Less than 10%",
        p_all_li >= .1 & p_all_li < .3 ~ "10% to 29%",
        p_all_li >= .3 & p_all_li < .5 ~ "30% to 49%",
        p_all_li >= .5 ~ "More than 50%"
      )
  ) %>%
  drop_na(p_all_li) %>%
  clean_names() %>%
  glimpse()

#
# Combine with eviction data and plot for datawrapper
# --------------------------------------------------------------------------

tr_df <- 
  tr_inc %>% 
  left_join(    
    agg %>% 
    filter(plot_date >= ymd(end_month) - months(11)) %>%
    select(geoid = tract_geoid, renters = tr_totrent, filings, black_head:white_head, tr_totrent_black, tr_totrent_latine, tr_totrent_other, tr_totrent_white_nl) %>% 
    group_by(geoid) %>%
    reframe(
      renters = unique(renters),
      black_renters = unique(tr_totrent_black),
      latine_renters = unique(tr_totrent_latine),
      other_renters = unique(tr_totrent_other),
      white_renters = unique(tr_totrent_white_nl),
      filings = sum(filings), 
      black_head = sum(black_head),
      latine_head = sum(latine_head),
      other_head = sum(other_head),
      white_head = sum(white_head)
      ) 
    ) %>% 
  group_by(p_li_cat) %>% 
  reframe(
    # neigh_type = unique(neigh_type),
    `Tract count` = n(),
    Renters = sum(renters), 
    `Black renters` = sum(black_renters),
    `Latine renters` = sum(latine_renters),
    `Other renters` = sum(other_renters),
    `White renters` = sum(white_renters),
    Filings = sum(filings), 
    `Black evictions` = round(sum(black_head)),
    `Latine evictions` = round(sum(latine_head)),
    `Other racial group evictions` = round(sum(other_head)),
    `White evictions` = round(sum(white_head))
    ) %>% 
  mutate(
    `Overall eviction rate` = rate_fun(Filings, Renters), 
    `Black eviction rate` = rate_fun(`Black evictions`, `Black renters`), 
    `Latine eviction rate` = rate_fun(`Latine evictions`, `Latine renters`), 
    `Other racial group eviction rate` = rate_fun(`Other racial group evictions`, `Other renters`), 
    `White eviction rate` = rate_fun(`White evictions`, `White renters`)
    ) %>% 
  arrange(`Overall eviction rate`)

tr_df
glimpse(tr_df)

sheet_write(
  data = tr_df,
  ss = sheet_url,
  sheet = "Low-income Neighborhoods"
  )

#
# Eviction by rent
# --------------------------------------------------------------------------

tr_rent <- 
  get_acs(
    state = short_state, 
    variables = c('mgrent' = 'B25064_001'), 
    geography = "tract", 
    cache_table = TRUE
    ) %>% 
  na.omit()

rent_quartiles <- quantile(tr_rent$estimate, prob = c(.25,.5,.75), type=1)

rent_df <- 
  tr_rent %>% 
  clean_names() %>% 
  left_join(
    agg %>% 
      filter(plot_date >= ymd(end_month) - months(11)) %>%
      select(geoid = tract_geoid, renters = tr_totrent, filings, black_head:white_head, tr_totrent_black, tr_totrent_latine, tr_totrent_other, tr_totrent_white_nl) %>% 
      group_by(geoid) %>%
      reframe(
        renters = unique(renters),
        black_renters = unique(tr_totrent_black),
        latine_renters = unique(tr_totrent_latine),
        other_renters = unique(tr_totrent_other),
        white_renters = unique(tr_totrent_white_nl),
        filings = sum(filings), 
        black_head = sum(black_head),
        latine_head = sum(latine_head),
        other_head = sum(other_head),
        white_head = sum(white_head)
        ) 
      ) %>% 
  na.omit() %>%
  mutate(
    cat = 
        case_when(
          estimate <= rent_quartiles[1] ~ paste0("Less than $", comma(rent_quartiles[1])), 
          estimate > rent_quartiles[1] & estimate <= rent_quartiles[2] ~ paste0("$",comma(rent_quartiles[1]+1), " to $", comma(rent_quartiles[2])), 
          estimate > rent_quartiles[2] & estimate <= rent_quartiles[3] ~ paste0("$",comma(rent_quartiles[2]+1), " to $", comma(rent_quartiles[3])), 
          estimate > rent_quartiles[3] ~ paste0("$",comma(rent_quartiles[3]+1), "+") 
          )
      ) %>% 
  group_by(cat) %>%
  reframe(
      # neigh_type = unique(neigh_type),
      `Tract count` = n(),
      Renters = sum(renters), 
      `Black renters` = sum(black_renters),
      `Latine renters` = sum(latine_renters),
      `Other renters` = sum(other_renters),
      `White renters` = sum(white_renters),
      Filings = sum(filings), 
      `Black evictions` = round(sum(black_head)),
      `Latine evictions` = round(sum(latine_head)),
      `Other racial group evictions` = round(sum(other_head)),
      `White evictions` = round(sum(white_head))
      ) %>% 
    mutate(
      `Overall eviction rate` = rate_fun(Filings, Renters), 
      `Black eviction rate` = rate_fun(`Black evictions`, `Black renters`), 
      `Latine eviction rate` = rate_fun(`Latine evictions`, `Latine renters`), 
      `Other racial group eviction rate` = rate_fun(`Other racial group evictions`, `Other renters`), 
      `White eviction rate` = rate_fun(`White evictions`, `White renters`)
      ) %>% 
    glimpse()

# Manually reorder rows for presentation sake
rent_order <- 
  c(
    paste0("Less than $", comma(rent_quartiles[1])), 
    paste0("$",comma(rent_quartiles[1]+1), " to $", comma(rent_quartiles[2])), 
    paste0("$",comma(rent_quartiles[2]+1), " to $", comma(rent_quartiles[3])), 
    paste0("$",comma(rent_quartiles[3]+1), "+")
  )

rent_df_final <- 
  rent_df %>% 
  slice(match(rent_order, cat))

# Save to spreadsheet
sheet_write(
  data = rent_df_final,
  ss = sheet_url,
  sheet = "Neighborhood rents"
  )

# ==========================================================================
# Descriptive statistics for in-text information
# ==========================================================================

#
# State totals of renters by demographics
# --------------------------------------------------------------------------

agg %>% 
filter(plot_date >= ymd(end_month)-months(11), plot_date <= end_month) %>% 
summarize(
  black_filings = sum(black_head, na.rm = TRUE), 
  latine_filings = sum(latine_head, na.rm = TRUE), 
  other_filings = sum(other_head, na.rm = TRUE), 
  white_filings = sum(white_head, na.rm = TRUE), 
  filings = sum(filings, na.rm = TRUE), 
  black_renters = unique(pums_black), 
  latine_renters = unique(pums_latine), 
  other_renters = unique(pums_other), 
  white_renters = unique(pums_white), 
  renters = unique(pums_total)
  ) %>%
mutate(
  black_evr = round((black_filings/black_renters)*100, 1),
  latine_evr = round((latine_filings/latine_renters)*100, 1),
  other_evr = round((other_filings/other_renters)*100, 1),
  white_evr = round((white_filings/white_renters)*100, 1),
  evr = round((filings/renters)*100, 1),
  black_oi = round(100/(black_evr)), 
  latine_oi = round(100/(latine_evr)), 
  other_oi = round(100/(other_evr)), 
  white_oi = round(100/(white_evr)), 
  oi = round(100/(evr)), 
  ) %>%
glimpse()

