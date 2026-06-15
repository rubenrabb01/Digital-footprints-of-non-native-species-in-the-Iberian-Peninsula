# 03_combine_reg_geo_outputs.R
# Combine filtered REG candidates with GEO videos and deduplicate by video.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
  library(tibble)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
dir.create(PREP_DIR, recursive = TRUE, showWarnings = FALSE)

read_csv_chr <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

reg <- read_csv_chr(file.path(PREP_DIR, "api_regioncode_filtered_candidates.csv")) %>%
  mutate(source_flag_raw = "REG")
geo <- read_csv_chr(file.path(PREP_DIR, "api_geotagged_raw.csv")) %>%
  mutate(source_flag_raw = "GEO")

combined_long <- bind_rows(reg, geo) %>%
  filter(!is.na(.data$video_id), .data$video_id != "")

if (nrow(combined_long) == 0) {
  warning("No REG/GEO candidate videos found. Run 01 and 02 first.")
  candidates <- tibble()
} else {
  candidates <- combined_long %>%
    mutate(source_priority = case_when(
      source_flag_raw == "GEO" ~ 2L,
      source_flag_raw == "REG" ~ 1L,
      TRUE ~ 0L
    )) %>%
    group_by(.data$video_id) %>%
    arrange(desc(.data$source_priority), .by_group = TRUE) %>%
    mutate(
      source_flag = case_when(
        all(c("GEO", "REG") %in% unique(.data$source_flag_raw)) ~ "BOTH",
        "GEO" %in% unique(.data$source_flag_raw) ~ "GEO",
        "REG" %in% unique(.data$source_flag_raw) ~ "REG",
        TRUE ~ paste(sort(unique(.data$source_flag_raw)), collapse = "+")
      )
    ) %>%
    summarise(
      across(
        .cols = -c(source_flag_raw, source_priority, source_flag),
        .fns = ~ {
          vals <- .x[!is.na(.x) & .x != ""]
          if (length(vals) == 0) NA_character_ else vals[1]
        }
      ),
      source_flag = first(.data$source_flag),
      .groups = "drop"
    )
}

readr::write_csv(combined_long, file.path(PREP_DIR, "api_reg_geo_candidates_long.csv"), na = "")
readr::write_csv(candidates, file.path(PREP_DIR, "api_candidates_for_manual_labeling.csv"), na = "")

summary_tbl <- candidates %>%
  count(.data$source_flag, name = "n_videos") %>%
  arrange(desc(.data$n_videos))
readr::write_csv(summary_tbl, file.path(PREP_DIR, "api_candidate_source_summary.csv"), na = "")
print(summary_tbl)
message("Candidate table written: ", file.path(PREP_DIR, "api_candidates_for_manual_labeling.csv"))
