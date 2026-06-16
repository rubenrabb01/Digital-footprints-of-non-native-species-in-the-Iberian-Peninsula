############################################################
# 16_dataset_summary_counts.R
#
# Small reproducibility check for dataset-layer counts used in
# the manuscript and Supplementary Material.
#
# This script reports the number of records, distinct video_id
# strings, species, and channels for the main GEO/REG/LABEL
# data layers documented in the repository.
############################################################

find_script_path <- function() {
  cmd <- commandArgs(trailingOnly = FALSE)
  file_arg <- "--file="
  hit <- grep(file_arg, cmd, value = TRUE)
  if (length(hit) > 0) return(normalizePath(sub(file_arg, "", hit[1]), mustWork = FALSE))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    return(normalizePath(rstudioapi::getSourceEditorContext()$path, mustWork = FALSE))
  }
  return(normalizePath(file.path("scripts", "16_dataset_summary_counts.R"), mustWork = FALSE))
}

script_path <- find_script_path()
root_dir <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)

read_csv_base <- function(rel_path) {
  utils::read.csv(file.path(root_dir, rel_path), stringsAsFactors = FALSE, check.names = FALSE)
}

n_distinct_safe <- function(x) length(unique(x[!is.na(x) & x != ""]))
count_layer <- function(label, rel_path, primary_count = c("records", "comments"), notes = "") {
  primary_count <- match.arg(primary_count)
  x <- read_csv_base(rel_path)
  video_col <- intersect(c("video_id", "videoId", "id"), names(x))[1]
  species_col <- intersect(c("TaxonName", "CleanName", "species_normalized"), names(x))[1]
  channel_col <- intersect(c("channel_id", "channelId", "channelTitle", "channel_title"), names(x))[1]
  data.frame(
    dataset_label = label,
    file = rel_path,
    n_records = nrow(x),
    n_distinct_video_id_strings = if (!is.na(video_col)) n_distinct_safe(x[[video_col]]) else NA_integer_,
    n_species = if (!is.na(species_col)) n_distinct_safe(x[[species_col]]) else NA_integer_,
    n_channels = if (!is.na(channel_col)) n_distinct_safe(x[[channel_col]]) else NA_integer_,
    primary_count_for_reporting = primary_count,
    notes = notes,
    stringsAsFactors = FALSE
  )
}

layers <- rbind(
  count_layer("GEO anchor", "data/preparation_input/api_geotagged_anchor_sourceflag.csv", "records", "Source-flagged GEO anchor used to document the geotag/location-based pathway."),
  count_layer("RAW-REG", "data/preparation_input/api_regioncode_raw.csv", "records", "Full raw region-code video pool after deduplication."),
  count_layer("RAW-REG flagged", "data/preparation_input/api_regioncode_raw_flagged.csv", "records", "Same RAW-REG pool with Iberian-relevance flag used during filtering/labelling."),
  count_layer("REG post-filtered candidates", "data/preparation_input/api_regioncode_postfiltered_candidates.csv", "records", "REG candidate file after Iberian language/toponymic post-filtering."),
  count_layer("REG-labelled", "data/preparation_input/api_regioncode_labelled.csv", "records", "REG records manually labelled as Iberia-relevant."),
  count_layer("Final LABEL dataset", "data/paper_input/videos_validated.csv", "records", "Final analysis dataset. Report n_records = 1,899 analysed video records; do not reduce this count by distinct video_id strings."),
  count_layer("Comments input", "data/paper_input/comments_timestamped.csv", "comments", "Timestamped comments/replies used only for the comments-only sensitivity analysis.")
)

raw_reg_n <- layers$n_records[layers$dataset_label == "RAW-REG"]
post_reg_n <- layers$n_records[layers$dataset_label == "REG post-filtered candidates"]
reg_labelled_n <- layers$n_records[layers$dataset_label == "REG-labelled"]
final_label_n <- layers$n_records[layers$dataset_label == "Final LABEL dataset"]
comments_video_n <- layers$n_distinct_video_id_strings[layers$dataset_label == "Comments input"]

summary_text <- data.frame(
  statistic = c(
    "REG post-filtered candidates retained from RAW-REG",
    "REG-labelled retained from post-filtered REG",
    "REG-labelled retained from RAW-REG",
    "Final LABEL analysed video records",
    "Videos with timestamped comments/replies relative to final LABEL records"
  ),
  value = c(
    sprintf("%s/%s (%.1f%%)", format(post_reg_n, big.mark=","), format(raw_reg_n, big.mark=","), 100 * post_reg_n / raw_reg_n),
    sprintf("%s/%s (%.1f%%)", format(reg_labelled_n, big.mark=","), format(post_reg_n, big.mark=","), 100 * reg_labelled_n / post_reg_n),
    sprintf("%s/%s (%.1f%%)", format(reg_labelled_n, big.mark=","), format(raw_reg_n, big.mark=","), 100 * reg_labelled_n / raw_reg_n),
    sprintf("%s records", format(final_label_n, big.mark=",")),
    sprintf("%s/%s (%.1f%%)", format(comments_video_n, big.mark=","), format(final_label_n, big.mark=","), 100 * comments_video_n / final_label_n)
  ),
  stringsAsFactors = FALSE
)

out_dir <- file.path(root_dir, "outputs", "validation")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
utils::write.csv(layers, file.path(out_dir, "dataset_layer_summary_counts.csv"), row.names = FALSE)
utils::write.csv(summary_text, file.path(out_dir, "dataset_layer_summary_for_manuscript.csv"), row.names = FALSE)

print(layers)
print(summary_text)
