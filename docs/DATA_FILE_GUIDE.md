# Data file guide

This guide defines the main dataset names used in the repository. Each canonical file is paired with a short label in brackets.

## Dataset roles

### `api_regioncode_raw.csv` (**RAW-REG**)

**Path:** `data/preparation_input/api_regioncode_raw.csv`  
**Rows:** 16,844 unique videos  
**Meaning:** Full deduplicated region-code video pool retrieved from YouTube searches before post-filtering and manual Iberia-relevance labelling.

### `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**)

**Path:** `data/preparation_input/api_regioncode_raw_flagged.csv`  
**Rows:** 16,844 unique videos  
**Meaning:** Same full REG pool as `api_regioncode_raw.csv` (**RAW-REG**), with an added `is_iberian` field documenting which rows were retained or excluded during filtering and labelling.

### `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**)

**Path:** `data/preparation_input/api_regioncode_postfiltered_candidates.csv`  
**Rows:** 6,935 unique videos  
**Meaning:** Candidate REG dataset after ecological, linguistic, and Iberian locality filtering. This is an intermediate candidate file, not the final accepted dataset.

### `api_regioncode_labelled.csv` (**REG-labelled**)

**Path:** `data/preparation_input/api_regioncode_labelled.csv`  
**Rows:** 1,884 unique videos  
**Meaning:** Region-code videos labelled as Iberia-relevant (`is_iberian = TRUE`).

### `api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**)

**Path:** `data/preparation_input/api_geotagged_anchor_sourceflag.csv`  
**Rows:** 305 unique videos  
**Meaning:** Geotag/location-based GEO retrieval file. The filename is historical; the file documents videos identified through the GEO retrieval pathway. In the preparation files, the `source_flag` column records whether each video came from GEO, REG, or both retrieval routes.

**Important caveat:** only 68 of these 305 GEO video IDs overlap the current `data/paper_input/videos_validated.csv` (**final LABEL dataset**). Therefore, this file documents the GEO pathway but should not replace the final LABEL dataset used by the manuscript scripts.

### `videos_validated.csv` (**final LABEL dataset**)

**Path:** `data/paper_input/videos_validated.csv`  
**Rows:** 1,899 analysed video records  
**Meaning:** Final validated video-level dataset used by the manuscript scripts. It contains the REG-labelled videos plus a small set of manually added *Xylocopa pubescens* videos and comment-timing metadata.

### `comments_timestamped.csv` (**comments sensitivity input**)

**Path:** `data/paper_input/comments_timestamped.csv`  
**Meaning:** Timestamped comments and replies used for the comments-only sensitivity analysis.

## Recommended citation wording for methods/repository notes

The final LABEL dataset was generated from a deduplicated region-code search pool of 16,844 videos (`api_regioncode_raw.csv`, **RAW-REG**), from which post-filtering based on language and Iberian locality cues produced a 6,935-video candidate set (`api_regioncode_postfiltered_candidates.csv`, **REG post-filtered candidates**). Manual and rule-based Iberian-relevance labelling retained 1,884 REG videos (`api_regioncode_labelled.csv`, **REG-labelled**), which were combined with a small set of manually added records to produce the final validated paper dataset (`videos_validated.csv`, **final LABEL dataset**) of 1,899 analysed video records. The geotag/location-based search pathway is documented separately in `api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**), which contains 305 unique GEO/BOTH video IDs.

## Older working files

Older working files named `label_this_sample_*` or similar were used during exploratory filtering, validation, and testing. They are not canonical repository inputs because some contain duplicate rows, propagated labels, or spreadsheet-corrupted video IDs.

## Audit files

- `docs/source_flag_file_summary.csv`: counts of GEO, REG, and BOTH retrieval-route labels in intermediate preparation files.
- `docs/geo_sourceflag_comparison_summary.csv`: comparison of GEO/BOTH video IDs across intermediate preparation files.
- `docs/geo_retrieval_overlap_with_repo_datasets.csv`: overlap between the GEO retrieval file and the current repository datasets.

## Upstream workflow documentation

The repository includes data-preparation documentation and a minimal API example:

- `optional_youtube_api_example/` provides a single-query illustrative YouTube API example.
- `data_preparation_workflow/` documents how API-derived candidate files were filtered, combined across REG/GEO pathways, manually labelled, and exported.

The manuscript analyses use the canonical files listed above.

### Counting note for the final LABEL dataset

`videos_validated.csv` (**final LABEL dataset**) contains **1,899 analysed video records**, and this is the count used in the manuscript and main workflow. The `video_id` field should not be used to reduce this number for reporting the final corpus. A small number of records may be repeated across search queries or may display oddly in spreadsheet software, but these correspond to valid analysed video records and were retained in the paper dataset.

## Reproducible dataset-count summary

Dataset-layer counts used in the manuscript can be regenerated with `scripts/16_dataset_summary_counts.R`, which writes `outputs/validation/dataset_layer_summary_counts.csv` and `outputs/validation/dataset_layer_summary_for_manuscript.csv`.

## Species and search-term files

Supplementary species-list and search-term inputs are stored in `data/species_input/`. See `docs/SPECIES_AND_SEARCH_TERMS_GUIDE.md` for details. These files document the curated first-record table used to define the study search scope and the ungrouped scientific/vernacular search terms used for YouTube retrieval.

## Validation files and figures

Validation templates, completed validation files, decision rules, and summary outputs are included with the repository. The validation runner reads the completed files, writes summary tables to `outputs/validation/tables/`, and exports the combined validation panel to `outputs/figures/supplement/` (`Figure_S9`).

Note: CSV files included for repository sharing use stable internal identifiers in place of direct YouTube video IDs, video URLs, channel names, comment IDs, and comment-author names. The original identifier mapping is not included.
