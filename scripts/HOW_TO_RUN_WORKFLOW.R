############################################################
# How to run the workflow
############################################################
# Use one block at a time.
# Restart R or run rm(list = ls()) before switching between
# the API test, data preparation, validation checks, and main analysis.
#
# Main project folder:
# Set PROJECT_DIR to the folder where this repository was unzipped or cloned.
############################################################


############################################################
# 0. Set the main project folder
############################################################

rm(list = ls())

PROJECT_DIR <- getwd()  # run this file from the project root, or set a full path manually
setwd(PROJECT_DIR)


############################################################
# 1. Main analysis: titles and descriptions only
############################################################
# This uses the curated labelled dataset in data/paper_input/.
# It reproduces the main analysis without the comments-only check.

rm(list = ls())
setwd(PROJECT_DIR)

ANALYSIS_MODE <- "NO_COMMENTS"

source("scripts/14_run_all.R", encoding = "UTF-8")


############################################################
# 2. Main analysis plus comments-only check
############################################################
# This runs the main analysis and then the comments-only thematic check.

rm(list = ls())
setwd(PROJECT_DIR)

source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")


############################################################
# 3. Validation summaries and supplementary checks
############################################################
# This creates validation summaries and the supplementary lead-lag figures
# and tables, including Figures S7 and S8 if the required files exist.

rm(list = ls())
setwd(PROJECT_DIR)

source("scripts/99_run_validation_audits.R", encoding = "UTF-8")


############################################################
# 4. Full paper outputs
############################################################
# This is the usual option if you want all figures and tables:
# main analysis + comments-only check + validation/lead-lag outputs.

rm(list = ls())
setwd(PROJECT_DIR)

source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")


############################################################
# 5. Optional YouTube API pre-workflow
############################################################
# This step is optional. It shows how raw YouTube API outputs can be
# retrieved. It is not needed to reproduce the paper results from the
# curated files in data/paper_input/.
#
# Notes:
# - Run this from optional_youtube_api_preworkflow/.
# - Use your own API key locally.
# - Do not save or share your API key in this script.
# - YouTube results can change over time.
############################################################

rm(list = ls())

PROJECT_DIR <- getwd()  # or set this manually, e.g. "C:/path/to/project"
setwd(file.path(PROJECT_DIR, "optional_youtube_api_preworkflow"))

Sys.setenv(YOUTUBE_API_KEY = "YOUR_API_KEY_HERE")


############################################################
# 5a. Choose one API run mode
############################################################
# Small tests:
#   test_REG       = regionCode search only, small species subset
#   test_GEO       = geotagged/location-radius search only, small species subset
#   test_comments  = small comments/replies test
#
# Larger runs:
#   full_REG_GEO_no_comments    = REG + GEO searches, no comments
#   full_REG_GEO_with_comments  = REG + GEO searches, plus comments/replies
#
# Choose only one RUN_MODE at a time.

RUN_MODE <- "test_REG"
# RUN_MODE <- "test_GEO"
# RUN_MODE <- "test_comments"
# RUN_MODE <- "full_REG_GEO_no_comments"
# RUN_MODE <- "full_REG_GEO_with_comments"


############################################################
# 5b. Optional API parameters
############################################################
# These are normally set in:
# optional_youtube_api_preworkflow/scripts/00_youtube_search_config.R
#
# Useful settings:
#
# CONFIG$search_modes           # c("REG"), c("GEO"), or c("REG", "GEO")
# CONFIG$max_species_per_batch  # number of species per batch
# CONFIG$max_videos_per_term    # number of videos per search term
# CONFIG$extract_comments       # TRUE/FALSE
# CONFIG$max_comments_per_video # top-level comments per video
# CONFIG$clear_previous_outputs # TRUE/FALSE
#
# In most cases, use RUN_MODE and leave these unchanged.


############################################################
# 5c. Run API search and inspect outputs
############################################################

source("scripts/99_run_youtube_api_preworkflow.R", encoding = "UTF-8")
source("scripts/04_inspect_api_outputs.R", encoding = "UTF-8")


############################################################
# 6. Optional data-preparation workflow
############################################################
# This connects raw API outputs to preparation files used for filtering
# and manual labelling. It is mainly for transparency and small test runs.
#
# The main paper workflow already uses curated files in data/paper_input/.
# Keep OVERWRITE_PAPER_INPUTS as FALSE unless you intentionally want to
# replace those curated input files.
############################################################

rm(list = ls())

PROJECT_DIR <- getwd()  # or set this manually, e.g. "C:/path/to/project"
setwd(PROJECT_DIR)

OVERWRITE_PAPER_INPUTS <- FALSE
# OVERWRITE_PAPER_INPUTS <- TRUE

source("data_preparation_workflow/scripts/99_run_data_preparation_workflow.R", encoding = "UTF-8")


############################################################
# 7. Full sequence: API test, preparation, and all paper outputs
############################################################
# This block shows the complete sequence in one place.
# Run it only if you want to test all three parts.

# 7a. Optional API test
rm(list = ls())

PROJECT_DIR <- getwd()  # or set this manually, e.g. "C:/path/to/project"
setwd(file.path(PROJECT_DIR, "optional_youtube_api_preworkflow"))

Sys.setenv(YOUTUBE_API_KEY = "YOUR_API_KEY_HERE")

RUN_MODE <- "test_REG"
# RUN_MODE <- "test_GEO"
# RUN_MODE <- "test_comments"

source("scripts/99_run_youtube_api_preworkflow.R", encoding = "UTF-8")
source("scripts/04_inspect_api_outputs.R", encoding = "UTF-8")


# 7b. Optional data-preparation workflow
rm(list = ls())

PROJECT_DIR <- getwd()  # or set this manually, e.g. "C:/path/to/project"
setwd(PROJECT_DIR)

OVERWRITE_PAPER_INPUTS <- FALSE

source("data_preparation_workflow/scripts/99_run_data_preparation_workflow.R", encoding = "UTF-8")


# 7c. Main analysis, comments-only check, and validation outputs
rm(list = ls())

PROJECT_DIR <- getwd()  # or set this manually, e.g. "C:/path/to/project"
setwd(PROJECT_DIR)

source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
