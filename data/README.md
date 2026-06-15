# Data folder

This folder contains the curated data files needed to reproduce the manuscript workflow, together with supporting files that document the species list, search terms, validation inputs, and dataset lineage.

## `paper_input/`

Main analysis inputs used directly by the scripts:

- `videos_validated.csv`: final manually validated video-level dataset used by the main analysis scripts; 1,899 analysed video records.
- `comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.

## `species_input/`

Species-list and search-term input files:

- `iberian_nns_first_records_filtered_for_search.csv`: machine-readable curated Iberian first-record table used to define the study search scope.
- `iberian_nns_first_records_filtered_for_search.xlsx`: Excel version of the same curated table, retaining the visual colour coding used during curation.
- `youtube_search_terms_ungrouped.csv`: one-column list of scientific names, vernacular names, and spelling variants used as YouTube search terms.

The full source database is not redistributed. Users should obtain the original Alien Species First Records Database from its official Zenodo record.

## `preparation_input/`

Files documenting the upstream filtering and labelling path from candidate videos to the final analysis corpus:

- `api_regioncode_raw.csv`: full region-code candidate pool after deduplication; 16,844 unique videos.
- `api_regioncode_raw_flagged.csv`: the same region-code pool with an Iberia-relevance flag.
- `api_regioncode_postfiltered_candidates.csv`: candidate REG file after ecological, linguistic, and Iberian locality filters; 6,935 unique videos.
- `api_regioncode_labelled.csv`: REG videos labelled as Iberia-relevant; 1,884 unique videos.
- `api_geotagged_anchor_sourceflag.csv`: geotag/location-based GEO anchor; 305 unique videos.
- `preparation_input_manifest.csv`: file-level manifest for the preparation inputs.
- `preparation_input_lineage_summary.csv`: summary of the main filtering stages.

## `validation_input/`

Validation templates, completed-example files, and returned validation files used by the validation workflow. The scripts read these files to generate validation tables and supplementary validation figures.

## `api_test_input/`

Small files used only by the optional API-test workflow. These are not required for reproducing the manuscript analyses.
