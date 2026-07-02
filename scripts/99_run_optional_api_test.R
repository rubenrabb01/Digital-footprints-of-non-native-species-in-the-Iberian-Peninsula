############################################################
# 99_run_optional_api_test.R
# Optional YouTube API example search from the repository root
############################################################
# Purpose:
#   Runs a small YouTube API test using the optional upstream API workflow.
#   This step is NOT required to reproduce the manuscript figures/tables.
#   Use it only to verify that the optional API scripts work locally.
#
# Before running:
#   1. Open R/RStudio in the repository root folder.
#   2. Set your YouTube API key locally, for example:
#        Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
#   3. Do not save or commit your API key.
#
# Default test:
#   RUN_MODE = "test_REG" (small region-code search, no comments)
#
# Other optional modes:
#   "test_GEO"       small geolocation search, no comments
#   "test_REG_GEO"   small REG + GEO test, no comments
#   "test_comments"  very small REG test including comments/replies
############################################################

PROJECT_DIR <- getwd()
OPTIONAL_API_DIR <- file.path(PROJECT_DIR, "optional_youtube_api_preworkflow")

if (!dir.exists(OPTIONAL_API_DIR)) {
  stop(
    "Cannot find optional_youtube_api_preworkflow/. ",
    "Run this script from the repository root folder."
  )
}

if (!nzchar(Sys.getenv("YOUTUBE_API_KEY"))) {
  stop(
    "YOUTUBE_API_KEY is not set. Run this first, using your own key:\n",
    "Sys.setenv(YOUTUBE_API_KEY = 'YOUR_KEY_HERE')\n",
    "Do not save or commit your API key."
  )
}

# Choose the small default test unless RUN_MODE was already defined.
RUN_MODE <- if (exists("RUN_MODE", inherits = FALSE)) RUN_MODE else "test_REG"

cat("Running optional YouTube API test from:\n", OPTIONAL_API_DIR, "\n")
cat("RUN_MODE:", RUN_MODE, "\n")

old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)
setwd(OPTIONAL_API_DIR)

source("scripts/99_run_youtube_api_preworkflow.R", encoding = "UTF-8")
source("scripts/04_inspect_api_outputs.R", encoding = "UTF-8")

cat("\nOptional YouTube API test completed.\n")
cat("Generated files are in optional_youtube_api_preworkflow/data_raw/ and yt_api_outputs/.\n")
