# ============================================================
# 99_run_main_plus_comments_sensitivity.R
#
# Runs:
#   1) Main paper workflow using titles + descriptions only
#      ANALYSIS_MODE = "NO_COMMENTS"
#
#   2) Comments-only sensitivity analysis using timestamped
#      comments + replies only
#
# IMPORTANT:
# The comments-only sensitivity is intentionally limited to the
# Figure 2 / thematic-composition workflow and its compact tables.
# It does NOT run the full multinomial/weighted model workflow,
# because that analysis is part of the main title/description paper
# workflow and is not required for the audience-response sensitivity.
# ============================================================

# ------------------------------
# 1) Main paper workflow
# ------------------------------
rm(list = ls())

ANALYSIS_MODE <- "NO_COMMENTS"
source("scripts/14_run_all.R", encoding = "UTF-8")

message("\n============================================================")
message("Main no-comments workflow completed.")
message("Starting comments-only Figure 2/thematic sensitivity analysis...")
message("============================================================\n")

# ------------------------------
# 2) Comments-only sensitivity workflow
# ------------------------------
rm(list = ls())

ANALYSIS_MODE <- "COMMENTS_ONLY"

# Use only the scripts needed for timestamped comments and Figure 2-style
# thematic sensitivity outputs.
source("scripts/00_config_paths_mode.R", encoding = "UTF-8")
if (file.exists("scripts/00_direct_output_config.R")) {
  source("scripts/00_direct_output_config.R", encoding = "UTF-8")
}
source("scripts/00_helpers.R", encoding = "UTF-8")
source("scripts/01_load_prepare_video_dataset.R", encoding = "UTF-8")
source("scripts/02_prepare_timestamped_comments.R", encoding = "UTF-8")
source("scripts/03_keyword_lists.R", encoding = "UTF-8")
source("scripts/04_tokenization_strict.R", encoding = "UTF-8")
source("scripts/05_select_analysis_tokens.R", encoding = "UTF-8")

# Compact thematic summaries / Tables S6-S8 style for comments only.
source("scripts/06_tables_S6_S8_thematic_content.R", encoding = "UTF-8")

# Figure 2-style comments-only sensitivity figure.
source("scripts/09_figure2_thematic_content.R", encoding = "UTF-8")

message("\n============================================================")
message("Main workflow + comments-only Figure 2 sensitivity completed.")
message("============================================================\n")

# Remove stale diagnostic sensitivity figure folder from older workflow versions.
if (dir.exists(file.path("outputs", "figures", "sensitivity_comments"))) {
  unlink(file.path("outputs", "figures", "sensitivity_comments"), recursive = TRUE, force = TRUE)
}
message("Supplementary Fig. S6 written directly to outputs/figures/supplement.")
