# ============================================================
# 99_run_validation_audits.R
# Runner for validator-requested validation/audit analyses.
# ============================================================

# Run this from the project root.
# Recommended sequence:
#   1) source("scripts/14_run_all.R", encoding = "UTF-8")
#   2) source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")  # optional, if comments sensitivity is needed
#   3) source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
#
# This audit runner now creates:
#   - Iberia-relevance validation templates/metrics when completed files exist
#   - keyword-occurrence validation templates/metrics when completed files exist
#   - exploratory lead/lag tables and figures
#   - a manual context-validation template for pre-record YouTube cases
#   - comments-only sensitivity summary text/tables if comments-only tokens exist

ANALYSIS_MODE <- "NO_COMMENTS"
if (!exists("PROJECT_ROOT", inherits = FALSE)) PROJECT_ROOT <- getwd()

source("scripts/00_config_paths_mode.R", encoding = "UTF-8")
if (file.exists("scripts/00_direct_output_config.R")) source("scripts/00_direct_output_config.R", encoding = "UTF-8")
source("scripts/00_helpers.R", encoding = "UTF-8")
source("scripts/01_load_prepare_video_dataset.R", encoding = "UTF-8")
source("scripts/15_validation_audits.R", encoding = "UTF-8")
