# ==========================================================================
# Create State Icons for Website
# ==========================================================================
# Creates standardized PNG icons of all U.S. states
# - All icons are the same size (normalized to fit 500x500 bounding box)
# - Saved as individual PNG files for web use
# - Uses tigris for state boundaries

library(tigris)
library(sf)
library(ggplot2)

# Get all state boundaries (excludes territories)
states_sf <- states(cb = TRUE, year = 2020) %>%
  filter(!STUSPS %in% c("PR", "VI", "GU", "MP", "AS")) %>%
  st_transform(5070) # CONUS Albers Equal Area

# Create output directory
icon_dir <- paste0("~/data/evictionresearch/", long_state, "/state_icons/")
if (!dir.exists(icon_dir)) dir.create(icon_dir, recursive = TRUE)

# Function to create normalized state icon
create_state_icon <- function(state_geom, state_abbr, state_name, output_dir, size = 500) {

  # Get bounding box
  bbox <- st_bbox(state_geom)

  # Calculate aspect ratio
  width <- bbox["xmax"] - bbox["xmin"]
  height <- bbox["ymax"] - bbox["ymin"]
  aspect <- width / height

  # Normalize to fit within size x size box while preserving aspect ratio
  if (aspect > 1) {
    # Wider than tall
    plot_width <- size
    plot_height <- size / aspect
  } else {
    # Taller than wide
    plot_width <- size * aspect
    plot_height <- size
  }

  # Create plot
  p <- ggplot(state_geom) +
    geom_sf(fill = "#2c3e50", color = "white", linewidth = 1) +
    theme_void() +
    theme(
      plot.margin = margin(0, 0, 0, 0),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.background = element_rect(fill = "transparent", color = NA)
    )

  # Save as PNG with normalized dimensions
  filename <- paste0(output_dir, state_abbr, ".png")
  ggsave(
    filename = filename,
    plot = p,
    width = plot_width / 100,  # Convert pixels to inches (assuming 100 ppi)
    height = plot_height / 100,
    dpi = 100,
    bg = "transparent"
  )

  cat("Created:", filename, paste0("(", round(plot_width), "x", round(plot_height), ")\n"))
}

# Generate icons for all states
cat("\nGenerating state icons...\n")
for (i in 1:nrow(states_sf)) {
  create_state_icon(
    state_geom = states_sf[i, ],
    state_abbr = states_sf$STUSPS[i],
    state_name = states_sf$NAME[i],
    output_dir = icon_dir,
    size = 500
  )
}

cat("\nState icons saved to:", icon_dir, "\n")

# Create a reference table
state_icon_reference <- states_sf %>%
  st_drop_geometry() %>%
  select(state_abbr = STUSPS, state_name = NAME, state_fips = STATEFP) %>%
  mutate(icon_path = paste0(state_abbr, ".png")) %>%
  arrange(state_name)

write_csv(state_icon_reference, paste0(icon_dir, "state_icon_reference.csv"))

cat("Icon reference saved to:", paste0(icon_dir, "state_icon_reference.csv\n"))
