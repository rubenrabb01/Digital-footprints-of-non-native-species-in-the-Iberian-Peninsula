# Preparation input files

This folder documents the optional upstream preparation workflow that links raw YouTube API outputs to the curated paper input files.

The main paper analyses use `data/paper_input/`. The files in this folder are included for transparency, auditing, and rerunning or checking the optional data-preparation steps.

Important note: `api_regioncode_raw.csv` is the full raw region-code video pool from the earlier working preparation package. It contains the complete pre-filtering pool used upstream of `api_regioncode_labelled.csv`. The latest full archive contained a much smaller API-test version of this file, so the full-size version is retained here.

## File guide

| File | Description |
|---|---|
| `api_all_raw_videos.csv` | Combined raw API example/output file from the latest optional API preparation run; retained for workflow traceability. |
| `api_candidate_source_summary.csv` | Counts of candidate videos by source after joining region-code and geotagged candidate pools. |
| `api_candidates_for_manual_labeling.csv` | Candidate video table prepared for manual Iberian-relevance screening. |
| `api_candidates_labelled.csv` | Candidate video table after merging manual Iberian-relevance labels. |
| `api_collection_summary.csv` | Small summary of the optional API pre-workflow inputs collected before filtering. |
| `api_comments_raw.csv` | Raw timestamped YouTube comments/replies available from the optional API pre-workflow. |
| `api_geotagged_raw.csv` | Raw geotagged YouTube video output used as the geospatial candidate source when available. |
| `api_reg_geo_candidates_long.csv` | Long-format candidate table combining region-code and geotagged sources before manual labelling. |
| `api_regioncode_filtered_candidates.csv` | Region-code candidates retained after the light Iberian/topical filtering step. |
| `api_regioncode_labelled.csv` | Region-code candidate dataset with manual Iberian-relevance labels; this file links the large raw region-code pool to the curated paper input. |
| `api_regioncode_light_screen_rejected.csv` | Region-code candidates rejected by the light filtering step. |
| `api_regioncode_raw.csv` | Full raw region-code video pool retrieved from YouTube searches before filtering; used upstream to derive the filtered and labelled region-code candidate datasets. |
| `manual_iberian_labels_template.csv` | Template prepared for manually labelling whether candidate videos are Iberia-relevant. |
| `manual_label_summary.csv` | Summary of the manual Iberian-relevance labels applied during the optional preparation workflow. |
| `paper_input_export_summary.csv` | Summary of the final curated files exported from the preparation workflow into data/paper_input/. |
| `videos_excluded_after_labeling.csv` | Videos excluded after manual Iberian-relevance labelling. |
| `videos_validated_from_api.csv` | Videos retained as validated Iberia-relevant outputs from the optional API preparation workflow. |

| `preparation_input_manifest.csv` | Automatically generated manifest with row counts, column counts, file sizes, checksums, and short descriptions. |

