# Data folder

This folder contains the curated data files needed to reproduce the manuscript workflow, together with supporting files for species lists, search terms, validation, and dataset lineage.

## `paper_input/`

Main analysis inputs used directly by the scripts:

- `videos_validated.csv`: final manually curated Iberia-relevant video-level corpus; 1,895 distinct YouTube videos from 1,002 channels and 94 species.
- `comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.

## `species_input/`

Species-list and search-term files:

- `iberian_nns_first_records_filtered_for_search.csv`: curated Iberian first-record table used to define the study search scope.
- `iberian_nns_first_records_filtered_for_search.xlsx`: Excel version of the same table.
- `youtube_search_terms_ungrouped.csv`: scientific names, vernacular names, and spelling variants used as YouTube search terms.

The full Alien Species First Records Database is not redistributed.

## `preparation_input/`

Files documenting the upstream filtering and labelling path:

- `api_regioncode_raw.csv`: full region-code candidate pool after deduplication; 16,844 unique videos.
- `api_regioncode_raw_flagged.csv`: the same pool with an Iberia-relevance flag.
- `api_regioncode_postfiltered_candidates.csv`: filtered REG candidate file; 6,935 unique videos.
- `api_regioncode_labelled.csv`: REG videos labelled as Iberia-relevant; 1,884 unique videos.
- `api_geotagged_anchor_sourceflag.csv`: geotag/location-based GEO anchor; 305 unique videos.
- `preparation_input_manifest.csv`: file-level manifest.
- `preparation_input_lineage_summary.csv`: filtering-stage summary.

## `validation_input/`

Validation templates and completed anonymised files used by the validation workflow. The scripts read these files to generate validation tables and supplementary validation figures.

## `api_test_input/`

Small files used only by the optional API-test workflow.

CSV files intended for public release use stable internal identifiers in place of direct YouTube video IDs, video URLs, channel names, comment IDs, and comment-author names.
