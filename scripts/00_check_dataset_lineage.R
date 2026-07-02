############################################################
# Dataset lineage check for the YouTube NNS Iberia workflow
#
# This script does not recreate the full historical filtering
# process. Instead, it checks the canonical public data files
# included in the repository and prints their expected row counts.
############################################################

rm(list = ls())

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
})

script_path <- tryCatch(normalizePath(sys.frame(1)$ofile), error = function(e) NA_character_)
if (is.na(script_path) || !nzchar(script_path)) {
  root_dir <- getwd()
} else {
  root_dir <- normalizePath(file.path(dirname(script_path), ".."), mustWork = FALSE)
}
if (!dir.exists(file.path(root_dir, "data"))) root_dir <- getwd()

read_csv_quiet <- function(path) {
  readr::read_csv(path, show_col_types = FALSE, guess_max = 100000)
}

files <- list(
  raw_reg = file.path(root_dir, "data", "preparation_input", "api_regioncode_raw.csv"),
  raw_reg_flagged = file.path(root_dir, "data", "preparation_input", "api_regioncode_raw_flagged.csv"),
  reg_postfiltered = file.path(root_dir, "data", "preparation_input", "api_regioncode_postfiltered_candidates.csv"),
  reg_labelled = file.path(root_dir, "data", "preparation_input", "api_regioncode_labelled.csv"),
  geo_anchor = file.path(root_dir, "data", "preparation_input", "api_geotagged_anchor_sourceflag.csv"),
  label_final = file.path(root_dir, "data", "paper_input", "videos_validated.csv")
)

lineage <- lapply(names(files), function(nm) {
  dat <- read_csv_quiet(files[[nm]])
  tibble(
    dataset_role = nm,
    file = files[[nm]],
    n_rows = nrow(dat),
    n_columns = ncol(dat),
    unique_video_id = if ("video_id" %in% names(dat)) dplyr::n_distinct(dat$video_id) else NA_integer_
  )
}) |> bind_rows()

print(lineage)

cat("\nExpected values for the current public release:\n")
cat("RAW-REG: 16,844 unique videos\n")
cat("REG post-filtered candidates: 6,935 unique videos\n")
cat("REG labelled: 1,884 unique videos\n")
cat("GEO-anchor / source-flagged GEO: 305 unique videos\n")
cat("final LABEL dataset: 1,895 distinct video-level records\n")
cat("Counting note: report 1,895 distinct video-level records; video_id is unique in the final file after video-level deduplication.\n\n")

if (all(file.exists(unlist(files)))) {
  geo <- read_csv_quiet(files$geo_anchor)
  label <- read_csv_quiet(files$label_final)

  geo_ids <- unique(geo$video_id)
  label_ids <- unique(label$video_id)

  cat("GEO/LABEL overlap check:\n")
  cat("GEO anchor IDs also present in LABEL:", length(intersect(geo_ids, label_ids)), "\n")
  cat("GEO anchor IDs not present in LABEL:", length(setdiff(geo_ids, label_ids)), "\n")
}

cat("\nDone.\n")
