# ============================================================
# 99_run_optional_api_test.R
# Minimal optional YouTube API example wrapper
# ============================================================
# This wrapper runs the small illustrative API example included in
# optional_youtube_api_example/. It is not required to reproduce the
# manuscript analyses and does not implement the full bulk retrieval
# workflow used to build the study corpus.
#
# Requirements:
#   Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
# ============================================================

PROJECT_DIR <- getwd()
example_script <- file.path(PROJECT_DIR, "optional_youtube_api_example", "example_single_species_youtube_api_query.R")

if (!file.exists(example_script)) {
  stop("Cannot find optional_youtube_api_example/example_single_species_youtube_api_query.R")
}

source(example_script, encoding = "UTF-8")
