# 02b_regioncode_filtering_core_summary.R
# Short public summary of the REG filtering/labelling pathway.
#
# This script does not recreate the full historical exploratory filtering process.
# It checks the frozen public lineage files included in data/preparation_input/.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tibble)
})

prep_dir <- file.path(PROJECT_ROOT, "data", "preparation_input")

read_chr <- function(file) {
  path <- file.path(prep_dir, file)
  if (!file.exists(path)) {
    warning("Missing file: ", path)
    return(tibble())
  }
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

count_video_ids <- function(df) {
  if (nrow(df) == 0) return(NA_integer_)
  id_col <- intersect(c("video_id", "videoId", "id"), names(df))[1]
  if (is.na(id_col)) return(NA_integer_)
  dplyr::n_distinct(df[[id_col]], na.rm = TRUE)
}

files <- tibble::tribble(
  ~label, ~file,
  "RAW-REG", "api_regioncode_raw.csv",
  "RAW-REG flagged", "api_regioncode_raw_flagged.csv",
  "REG post-filtered candidates", "api_regioncode_postfiltered_candidates.csv",
  "REG-labelled", "api_regioncode_labelled.csv",
  "GEO anchor / source-flagged GEO", "api_geotagged_anchor_sourceflag.csv"
)

summary <- files %>%
  rowwise() %>%
  mutate(
    rows = nrow(read_chr(file)),
    unique_video_ids = count_video_ids(read_chr(file))
  ) %>%
  ungroup()

print(summary)

message("\nExpected public lineage:")
message("RAW-REG -> REG post-filtered candidates -> REG-labelled")
message("GEO anchor documents the geotag/location-based pathway.")
message("The final LABEL dataset is stored separately in data/paper_input/videos_validated.csv.")
