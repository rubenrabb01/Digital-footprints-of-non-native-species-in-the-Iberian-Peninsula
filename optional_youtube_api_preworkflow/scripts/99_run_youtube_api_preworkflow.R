# ============================================================
# 99_run_youtube_api_preworkflow.R
# Runs the standalone YouTube API pre-workflow.
# ============================================================

if (!exists("CONFIG", inherits = FALSE)) {
  source(file.path("scripts", "00_youtube_search_config.R"), encoding = "UTF-8")
}
source(file.path("scripts", "01_youtube_api_helpers.R"), encoding = "UTF-8")

clear_previous_youtube_outputs <- function(config) {
  cat("\nClearing previous generated API outputs...\n")

  # Remove per-batch API outputs. This is the main guard against mixing old
  # test files with a new run.
  if (dir.exists(YT_PER_LIST_DIR)) {
    old_batch_files <- list.files(
      YT_PER_LIST_DIR,
      pattern = "[.](csv|rds)$",
      recursive = TRUE,
      full.names = TRUE
    )
    if (length(old_batch_files) > 0) file.remove(old_batch_files)
  }

  # Remove summary/search-plan/log files created by previous runs.
  old_top_files <- c(
    file.path(YT_OUTPUT_DIR, "search_plan.csv"),
    file.path(YT_OUTPUT_DIR, "api_search_output_summary.csv")
  )
  old_top_files <- old_top_files[file.exists(old_top_files)]
  if (length(old_top_files) > 0) file.remove(old_top_files)

  if (dir.exists(YT_LOG_DIR)) {
    old_log_files <- list.files(YT_LOG_DIR, full.names = TRUE, recursive = TRUE)
    old_log_files <- old_log_files[!grepl("[.]gitkeep$", old_log_files)]
    if (length(old_log_files) > 0) file.remove(old_log_files)
  }

  # Remove generated final raw outputs and aliases. These files are regenerated
  # by scripts/03_combine_youtube_search_outputs.R.
  generated_data_files <- c(
    config$reg_final_file,
    config$geo_final_file,
    config$comments_final_file,
    config$reg_alias_file,
    config$geo_alias_file,
    config$combined_alias_file
  )
  generated_data_files <- generated_data_files[file.exists(generated_data_files)]
  if (length(generated_data_files) > 0) file.remove(generated_data_files)

  cat("Previous generated outputs cleared.\n\n")
}

if (isTRUE(CONFIG$clear_previous_outputs)) {
  clear_previous_youtube_outputs(CONFIG)
}

source(file.path("scripts", "02_run_youtube_search_lists.R"), encoding = "UTF-8")
source(file.path("scripts", "03_combine_youtube_search_outputs.R"), encoding = "UTF-8")

cat("\nYouTube API pre-workflow completed.\n")
cat("Run this optional inspection script to preview outputs:\n")
cat("  source('scripts/04_inspect_api_outputs.R', encoding = 'UTF-8')\n")
