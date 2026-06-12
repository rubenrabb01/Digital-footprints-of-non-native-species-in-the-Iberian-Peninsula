# 05_apply_manual_labels.R
# Merge manual labels and keep Iberia-relevant videos.

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

read_csv_chr <- function(path) {
  if (!file.exists(path)) return(tibble())
  readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
}

find_first_existing <- function(paths) {
  hits <- paths[file.exists(paths)]
  if (length(hits) == 0) NA_character_ else hits[1]
}

candidates <- read_csv_chr(file.path(PREP_DIR, "api_candidates_for_manual_labeling.csv"))
if (nrow(candidates) == 0) stop("Missing candidate table. Run 03_combine_reg_geo_outputs.R first.")

label_path <- find_first_existing(c(
  file.path(TEMPLATE_DIR, "manual_iberian_labels.csv"),
  file.path(TEMPLATE_DIR, "manual_iberian_labels_completed.csv"),
  file.path(PREP_DIR, "manual_iberian_labels.csv"),
  file.path(PREP_DIR, "api_regioncode_labelled.csv")
))

if (is.na(label_path)) {
  stop("No completed manual label file found. Fill data/validation_templates/manual_iberian_labels_template.csv and save it as manual_iberian_labels.csv")
}

labels <- read_csv_chr(label_path)
if (!"video_id" %in% names(labels)) stop("The manual label file needs a video_id column: ", label_path)
if (!"is_iberian" %in% names(labels)) stop("The manual label file needs an is_iberian column: ", label_path)

label_cols <- labels %>%
  dplyr::select(video_id, is_iberian, any_of(c("iberian_context_category", "reviewer_notes"))) %>%
  distinct(.data$video_id, .keep_all = TRUE)

labelled <- candidates %>%
  dplyr::select(-any_of(c("is_iberian", "iberian_context_category", "reviewer_notes"))) %>%
  left_join(label_cols, by = "video_id") %>%
  mutate(
    is_iberian_clean = str_to_lower(str_squish(as.character(.data$is_iberian))),
    is_iberian_final = is_iberian_clean %in% c("true", "t", "yes", "y", "1", "si", "sí"),
    is_uncertain = is_iberian_clean %in% c("uncertain", "maybe", "unclear", "doubtful", "?")
  )

validated <- labelled %>% filter(.data$is_iberian_final)
excluded <- labelled %>% filter(!.data$is_iberian_final | is.na(.data$is_iberian_final))

readr::write_csv(labelled, file.path(PREP_DIR, "api_candidates_labelled.csv"), na = "")
readr::write_csv(validated, file.path(PREP_DIR, "videos_validated_from_api.csv"), na = "")
readr::write_csv(excluded, file.path(PREP_DIR, "videos_excluded_after_labeling.csv"), na = "")

summary_tbl <- tibble(
  label_file = label_path,
  n_candidates = nrow(candidates),
  n_labelled_rows = nrow(labelled),
  n_validated = nrow(validated),
  n_excluded_or_unlabelled = nrow(excluded),
  n_uncertain = sum(labelled$is_uncertain, na.rm = TRUE)
)
readr::write_csv(summary_tbl, file.path(PREP_DIR, "manual_label_summary.csv"), na = "")
print(summary_tbl)
message("Validated API-derived file written: ", file.path(PREP_DIR, "videos_validated_from_api.csv"))
