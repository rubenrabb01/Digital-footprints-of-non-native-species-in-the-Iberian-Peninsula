# 02_apply_manual_labels.R
# Merge manual Iberian labels and create a validated video file.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")
suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(stringr)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
PAPER_DIR <- file.path(PROJECT_ROOT, "data", "paper_input")
dir.create(PAPER_DIR, recursive = TRUE, showWarnings = FALSE)

api_file <- file.path(PREP_DIR, "api_videos_for_screening.csv")
label_file <- file.path(PROJECT_ROOT, "data", "validation_templates", "manual_iberian_labels.csv")

if (!file.exists(api_file)) stop("Missing: ", api_file)
if (!file.exists(label_file)) stop("Missing manual labels: ", label_file)

api_videos <- readr::read_csv(api_file, col_types = readr::cols(.default = readr::col_character()))
manual_labels <- readr::read_csv(label_file, col_types = readr::cols(.default = readr::col_character()))

if (!"video_id" %in% names(manual_labels)) stop("The manual label file needs a video_id column.")
if (!"is_iberian" %in% names(manual_labels)) stop("The manual label file needs an is_iberian column.")

validated <- api_videos %>%
  left_join(manual_labels %>% select(video_id, is_iberian, everything()), by = "video_id") %>%
  filter(tolower(as.character(is_iberian)) %in% c("true", "yes", "1"))

readr::write_csv(validated, file.path(PAPER_DIR, "videos_validated_from_api.csv"), na = "")
message("Validated video file written: ", file.path(PAPER_DIR, "videos_validated_from_api.csv"))
message("Rows: ", nrow(validated), " | unique videos: ", dplyr::n_distinct(validated$video_id))
