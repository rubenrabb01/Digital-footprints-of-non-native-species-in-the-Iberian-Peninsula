# 04_prepare_manual_label_template.R
# Create a simple table for manual Iberian relevance labels.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
  library(tibble)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
TEMPLATE_DIR <- file.path(PROJECT_ROOT, "data", "validation_templates")
dir.create(PREP_DIR, recursive = TRUE, showWarnings = FALSE)
dir.create(TEMPLATE_DIR, recursive = TRUE, showWarnings = FALSE)

read_csv_chr <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

candidates <- read_csv_chr(file.path(PREP_DIR, "api_candidates_for_manual_labeling.csv"))
if (nrow(candidates) == 0) stop("Missing candidate table. Run 03_combine_reg_geo_outputs.R first.")

optional_cols <- c(
  "video_id", "TaxonName", "query", "title", "description", "channelTitle",
  "publishedAt", "created_at", "regionCode", "location", "locationRadius",
  "source_flag", "video_url", "viewCount", "likeCount", "commentCount"
)
for (cc in optional_cols) if (!cc %in% names(candidates)) candidates[[cc]] <- NA_character_

template <- candidates %>%
  transmute(
    video_id,
    TaxonName,
    query,
    title,
    description,
    channelTitle,
    publishedAt,
    created_at,
    regionCode,
    location,
    locationRadius,
    source_flag,
    video_url,
    viewCount,
    likeCount,
    commentCount,
    is_iberian = "",
    iberian_context_category = "",
    reviewer_notes = ""
  ) %>%
  arrange(.data$TaxonName, .data$query, .data$publishedAt)

template_path <- file.path(TEMPLATE_DIR, "manual_iberian_labels_template.csv")
prep_template_path <- file.path(PREP_DIR, "manual_iberian_labels_template.csv")
readr::write_csv(template, template_path, na = "")
readr::write_csv(template, prep_template_path, na = "")

rules <- tibble::tribble(
  ~column, ~how_to_fill,
  "is_iberian", "Use TRUE/FALSE/UNCERTAIN. TRUE means the video is relevant to the Iberian Peninsula or an Iberian pathway/context.",
  "iberian_context_category", "Optional short category, e.g. observation, management/news, trade/pet/aquarium, general information, unclear.",
  "reviewer_notes", "Optional comments supporting the decision."
)
readr::write_csv(rules, file.path(TEMPLATE_DIR, "manual_iberian_labels_decision_rules.csv"), na = "")

message("Manual labelling template written: ", template_path)
message("Fill it and save a completed copy as data/validation_templates/manual_iberian_labels.csv")
