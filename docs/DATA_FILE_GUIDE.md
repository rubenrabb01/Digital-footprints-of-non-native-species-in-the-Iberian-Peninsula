# Data file guide

This guide defines the main dataset names used in the repository. To avoid ambiguity, each canonical file is paired with a short label in brackets.

## Dataset roles

### `api_regioncode_raw.csv` (**RAW-REG**)

**Path:** `data/preparation_input/api_regioncode_raw.csv`  
**Rows:** 16,844 unique videos  
**Meaning:** Full deduplicated region-code video pool retrieved from YouTube searches before the post-filtering and manual Iberian-relevance labelling steps.

### `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**)

**Path:** `data/preparation_input/api_regioncode_raw_flagged.csv`  
**Rows:** 16,844 unique videos  
**Meaning:** Same full REG pool as `api_regioncode_raw.csv` (**RAW-REG**), with an added `is_iberian` field documenting which rows were retained or excluded during filtering/labelling.

### `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**)

**Path:** `data/preparation_input/api_regioncode_postfiltered_candidates.csv`  
**Rows:** 6,935 unique videos  
**Meaning:** Candidate REG dataset after language and Iberian locality filtering. This is an intermediate candidate file, not the final accepted dataset.

### `api_regioncode_labelled.csv` (**REG-labelled**)

**Path:** `data/preparation_input/api_regioncode_labelled.csv`  
**Rows:** 1,884 unique videos  
**Meaning:** Region-code videos labelled as Iberia-relevant (`is_iberian = TRUE`).

### `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**)

**Path:** `data/preparation_input/api_geotagged_anchor_sourceflag.csv`  
**Rows:** 305 unique videos  
**Meaning:** Geotag/location-based anchor derived from older source-flagged working files by selecting rows with `source_flag` equal to `GEO` or `BOTH`. The same 305 GEO/BOTH video IDs were identified across all comparable source-flagged working datasets. The split between `GEO` and `BOTH` differs among files because `BOTH` depends on which REG variant was compared with the GEO anchor.

**Important caveat:** only 68 of these 305 GEO anchor video IDs overlap the current `data/paper_input/videos_validated.csv` (**final LABEL dataset**). Therefore, this file documents the GEO pathway but should not replace the current final LABEL dataset used by the manuscript scripts.

### `videos_validated.csv` (**final LABEL dataset**)

**Path:** `data/paper_input/videos_validated.csv`  
**Rows:** 1,899 analysed video records  
**Meaning:** Final validated video-level dataset used by the manuscript scripts. It contains the REG-labelled videos plus a small set of manually added *Xylocopa pubescens* videos and comment-timing metadata.

### `comments_timestamped.csv` (**comments sensitivity input**)

**Path:** `data/paper_input/comments_timestamped.csv`  
**Meaning:** Timestamped comments and replies used for the comments-only sensitivity analysis.

## Recommended citation wording for methods/repository notes

The final LABEL dataset was generated from a deduplicated region-code search pool of 16,844 videos (`api_regioncode_raw.csv`, **RAW-REG**), from which post-filtering based on language and Iberian locality cues produced a 6,935-video candidate set (`api_regioncode_postfiltered_candidates.csv`, **REG post-filtered candidates**). Manual and rule-based Iberian-relevance labelling retained 1,884 REG videos (`api_regioncode_labelled.csv`, **REG-labelled**), which were combined with a small set of manually added records to produce the final validated paper dataset (`videos_validated.csv`, **final LABEL dataset**) of 1,899 analysed video records. The geotag/location-based search pathway is documented separately in `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**), which contains 305 unique GEO/BOTH video IDs derived from older source-flagged working files.

## Older working files

Older working files named `label_this_sample_*` or similar were used during exploratory filtering, validation, and testing. They are not recommended as canonical public inputs unless explicitly documented, because some contain duplicate rows, propagated labels, or spreadsheet-corrupted video IDs.

## Audit files

- `docs/geo_sourceflag_comparison_summary.csv`: comparison of uploaded working files containing `source_flag` values (`GEO`, `REG`, `BOTH`).
- `docs/geo_anchor_overlap_with_repo_datasets.csv`: overlap between the derived 305-video GEO anchor and the current repository datasets.
- `docs/source_flag_file_summary.csv`: row counts and source-flag counts for source-flagged working datasets.

## Upstream workflow scripts

The repository also includes optional upstream scripts:

- `optional_youtube_api_preworkflow/` documents how YouTube API searches can be rerun.
- `data_preparation_workflow/` documents how raw API outputs can be filtered, combined across REG/GEO pathways, manually labelled and exported.

These scripts are included for transparency. The frozen manuscript analyses use the canonical files listed above.

### Counting note for the final LABEL dataset

`videos_validated.csv` (**final LABEL dataset**) contains **1,899 analysed video records**, and this is the count used in the manuscript and main workflow. The `video_id` field should not be used to reduce this number for reporting the final corpus. A small number of records may be repeated across search queries or may display oddly in spreadsheet software (for example as `#¿NOMBRE?` in some older working files or spreadsheet views), but these correspond to valid analysed video records and were retained in the paper dataset.


## Reproducible dataset-count summary

Dataset-layer counts used in the manuscript can be regenerated with `scripts/16_dataset_summary_counts.R`, which writes `outputs/validation/dataset_layer_summary_counts.csv` and `outputs/validation/dataset_layer_summary_for_manuscript.csv`.


## Species and search-term files

Supplementary species-list and search-term inputs are stored in `data/species_input/`. See `docs/SPECIES_AND_SEARCH_TERMS_GUIDE.md` for details. These files document the curated first-record table used to define the study search scope and the ungrouped scientific/vernacular search terms used for YouTube retrieval.

## Validation reviewer files and figures

Reviewer-specific validation templates are stored in `outputs/validation/validation_files_by_validator/`. Artificial completed examples are stored separately in `outputs/validation/example_completed_files/` for workflow testing only. Real returned reviewer files should be placed under `outputs/validation/completed/validation_files_by_validator/` before rerunning `scripts/99_run_validation_audits.R`. The validation runner writes summary tables to `outputs/validation/tables/` and paper-ready validation figures to `outputs/figures/supplement/` (`Figure_S9`–`Figure_S12`).


Note: CSV files intended for public release use stable internal identifiers in place of direct YouTube video IDs, video URLs, channel names, comment IDs, and comment-author names. The original identifier mapping is not included.
