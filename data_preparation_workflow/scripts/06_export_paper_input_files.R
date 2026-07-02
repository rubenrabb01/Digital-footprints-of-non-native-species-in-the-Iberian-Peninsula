# 06_export_paper_input_files.R
# Copy validated preparation files to the paper-input folder.

source(file.path("scripts", "00_config_paths_mode.R"), encoding = "UTF-8")

suppressPackageStartupMessages({
  library(dplyr)
  library(readr)
  library(tibble)
})

PREP_DIR <- file.path(PROJECT_ROOT, "data", "preparation_input")
PAPER_DIR <- file.path(PROJECT_ROOT, "data", "paper_input")
API_DIR <- file.path(PROJECT_ROOT, "optional_youtube_api_preworkflow", "data_raw")
dir.create(PAPER_DIR, recursive = TRUE, showWarnings = FALSE)

if (!exists("OVERWRITE_PAPER_INPUTS", inherits = FALSE)) OVERWRITE_PAPER_INPUTS <- FALSE

copy_if_exists <- function(from, to, overwrite = FALSE) {
  if (!file.exists(from)) {
    message("Missing, not copied: ", from)
    return(FALSE)
  }
  if (file.exists(to) && !overwrite) {
    message("Kept existing file: ", to)
    message("  New file was copied instead with '_from_api' in the name.")
    return(FALSE)
  }
  file.copy(from, to, overwrite = TRUE)
}

validated_api <- file.path(PREP_DIR, "videos_validated_from_api.csv")
comments_api <- file.path(PREP_DIR, "api_comments_raw.csv")
if (!file.exists(comments_api)) comments_api <- file.path(API_DIR, "YT_comments_with_timestamps_long.csv")

# Always export API-derived copies with explicit names.
copy_if_exists(validated_api, file.path(PAPER_DIR, "videos_validated_from_api.csv"), overwrite = TRUE)
copy_if_exists(comments_api, file.path(PAPER_DIR, "comments_timestamped_from_api.csv"), overwrite = TRUE)

# Only replace the paper files if explicitly requested.
if (OVERWRITE_PAPER_INPUTS) {
  copy_if_exists(validated_api, file.path(PAPER_DIR, "videos_validated.csv"), overwrite = TRUE)
  copy_if_exists(comments_api, file.path(PAPER_DIR, "comments_timestamped.csv"), overwrite = TRUE)
  message("Paper input files were overwritten because OVERWRITE_PAPER_INPUTS = TRUE.")
} else {
  message("Paper input files were not overwritten. Set OVERWRITE_PAPER_INPUTS <- TRUE before running this script to replace them.")
}

out_summary <- tibble(
  output = c("videos_validated_from_api.csv", "comments_timestamped_from_api.csv", "videos_validated.csv", "comments_timestamped.csv"),
  path = file.path(PAPER_DIR, output),
  exists = file.exists(path)
)
readr::write_csv(out_summary, file.path(PREP_DIR, "paper_input_export_summary.csv"), na = "")
print(out_summary)
