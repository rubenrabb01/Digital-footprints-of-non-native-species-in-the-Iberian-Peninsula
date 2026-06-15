# 01_prepare_api_outputs_for_labeling.R
# Combine raw REG and GEO API files and create a screening table.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
})

API_INPUT_DIR <- file.path(PROJECT_ROOT, "optional_youtube_api_preworkflow", "data_raw")
PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
dir.create(PREP_DIR, recursive = TRUE, showWarnings = FALSE)

read_optional_csv <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()))
}

reg <- read_optional_csv(file.path(API_INPUT_DIR, "yt_species_videos_ES_PT_regioncode_scientific_common_dedup.csv")) %>%
  mutate(api_source = "REG")
geo <- read_optional_csv(file.path(API_INPUT_DIR, "yt_species_videos_ES_PT_geotagged_dedup_1200km_new_locs_espanded.csv")) %>%
  mutate(api_source = "GEO")

api_raw <- bind_rows(reg, geo)

if (nrow(api_raw) == 0) {
  warning("No REG/GEO API files were found. Run the optional API pre-workflow first, or place files in optional_youtube_api_preworkflow/data_raw/.")
} else {
  api_combined <- api_raw %>%
    filter(!is.na(video_id), video_id != "") %>%
    group_by(video_id) %>%
    arrange(desc(api_source == "GEO"), .by_group = TRUE) %>%
    summarise(
      across(everything(), ~ dplyr::first(na.omit(.x)), .names = "{.col}"),
      source_flag = paste(sort(unique(api_source)), collapse = "+"),
      .groups = "drop"
    )

  readr::write_csv(api_combined, file.path(PREP_DIR, "api_videos_for_screening.csv"), na = "")
  message("Screening table written: ", file.path(PREP_DIR, "api_videos_for_screening.csv"))
  message("Rows: ", nrow(api_combined), " | unique videos: ", dplyr::n_distinct(api_combined$video_id))
}
