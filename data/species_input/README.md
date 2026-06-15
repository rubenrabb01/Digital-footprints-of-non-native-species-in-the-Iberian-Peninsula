# Species and search-term input files

This folder contains supplementary input files documenting how the species list and YouTube search terms were assembled.

## Files

- `iberian_nns_first_records_filtered_for_search.csv`: machine-readable CSV version of the curated Iberian first-record table used to define the study search scope. It contains row-level first-record information derived from the Alien Species First Records Database v3.1 and Iberian updates, after study-specific filtering.
- `iberian_nns_first_records_filtered_for_search.xlsx`: Excel version of the same curated table. This version preserves the original visual colour coding used during curation, but the CSV version should be preferred for reproducible scripts.
- `youtube_search_terms_ungrouped.csv`: one-column list of scientific names, vernacular names, and spelling variants used as YouTube search terms. The terms are not grouped by species in this file; grouped search-term lists used by the optional API workflow are available in `optional_youtube_api_preworkflow/scripts/species_names_lists_full.R`.

## Notes

The first-record table is a row-level curation file. Some species may appear more than once if they occur in different Iberian regions or source records. The manuscript species count refers to the final study search scope after harmonisation and exclusions.

The full Alien Species First Records Database is not redistributed here. Users should obtain the original database from its official Zenodo record and use the version cited in the manuscript.
