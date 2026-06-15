############################################################
# HOW_TO_RUN_WORKFLOW.R
# Iberian NNS YouTube reproducible workflow
############################################################
# Use one block at a time.
# Restart R or run rm(list = ls()) before switching between
# the optional API test, data preparation, validation checks,
# and main analysis.
#
# IMPORTANT:
# Run from the repository root folder, not from scripts/.
# The repository root is the folder containing data/, scripts/,
# outputs/, docs/, and README.md.
############################################################


############################################################
# 0. Set the main project folder
############################################################

rm(list = ls())

# Option A: if RStudio is already open in the repository root:
PROJECT_DIR <- getwd()

# Option B: set the path manually, for example:
# PROJECT_DIR <- "/home/rubenrabb/ms_recent_IAS_post_WSIIV4_SP_NAMES_UPDATED_Rev4/youtube-nns-iberia-reproducible-workflow_v15_optional_api_run_guide"
# PROJECT_DIR <- "C:/Users/YOUR_USER/Documents/youtube-nns-iberia-reproducible-workflow"

setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

stopifnot(dir.exists("data"))
stopifnot(dir.exists("scripts"))
stopifnot(file.exists("scripts/14_run_all.R"))


############################################################
# 1. Main analysis: titles and descriptions only
############################################################
# This uses the curated labelled dataset in data/paper_input/.
# It reproduces the main analysis without the comments-only check.
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

source("scripts/14_run_all.R", encoding = "UTF-8")


############################################################
# 2. Main analysis plus comments-only sensitivity
############################################################
# This runs the main analysis and then the comments-only thematic
# sensitivity workflow.
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")


############################################################
# 3. Validation summaries, validation figures, and lead-lag checks
############################################################
# This creates the validation summaries and figures for the
# Iberia-relevance audit and keyword-occurrence validation, plus
# the supplementary lead-lag figures and tables.
#
# Main outputs:
#   outputs/validation/tables/
#   outputs/figures/validation/
#   outputs/figures/supplement/Figure_S7.png
#   outputs/figures/supplement/Figure_S8.png
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

source("scripts/99_run_validation_audits.R", encoding = "UTF-8")


############################################################
# 4. Full manuscript test run
############################################################
# This is the usual option if you want all reproducible outputs:
# main analysis + comments-only sensitivity + validation/lead-lag outputs.
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")


############################################################
# 5. Check main outputs after running
############################################################

check_dirs <- c(
  "outputs/figures/main",
  "outputs/figures/supplement",
  "outputs/figures/validation",
  "outputs/tables",
  "outputs/validation",
  "outputs/intermediate"
)

for (d in check_dirs) {
  cat("\n\n---", d, "---\n")
  if (dir.exists(d)) {
    print(list.files(d, recursive = TRUE))
  } else {
    cat("Folder does not exist\n")
  }
}


############################################################
# 6. Optional dataset-layer count summary
############################################################
# This creates compact count tables used for manuscript/response
# wording and dataset-lineage checks.
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

source("scripts/16_dataset_summary_counts.R", encoding = "UTF-8")


############################################################
# 7. Optional YouTube API example search
############################################################
# This step is optional and is NOT required to reproduce the paper.
# It runs a small API test using the optional upstream workflow.
#
# Requirements:
# - A valid YouTube Data API key.
# - Do not save or commit your API key.
# - API results may differ from the frozen manuscript data.
#
# Test modes:
#   test_REG       = small regionCode search, no comments
#   test_GEO       = small geolocation search, no comments
#   test_REG_GEO   = small REG + GEO test, no comments
#   test_comments  = small REG test with comments/replies
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
RUN_MODE <- "test_REG"
# RUN_MODE <- "test_GEO"
# RUN_MODE <- "test_REG_GEO"
# RUN_MODE <- "test_comments"

source("scripts/99_run_optional_api_test.R", encoding = "UTF-8")


############################################################
# 8. Optional data-preparation workflow
############################################################
# This connects optional API outputs to preparation files used for
# filtering and manual labelling. It is mainly for transparency and
# small test runs.
#
# The main paper workflow already uses curated files in data/paper_input/.
# Keep OVERWRITE_PAPER_INPUTS as FALSE unless you intentionally want to
# replace those curated input files.
############################################################

rm(list = ls())
setwd(PROJECT_DIR)
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)

OVERWRITE_PAPER_INPUTS <- FALSE
# OVERWRITE_PAPER_INPUTS <- TRUE

source("data_preparation_workflow/scripts/99_run_data_preparation_workflow.R", encoding = "UTF-8")
