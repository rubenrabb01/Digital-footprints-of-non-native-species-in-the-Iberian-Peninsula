# Species and search-term input files

This folder contains supplementary input files documenting how the species list and YouTube search terms were assembled.

## Files

- `iberian_nns_first_records_filtered_for_search.csv`: machine-readable CSV version of the curated Iberian first-record table used to define the study search scope.
- `iberian_nns_first_records_filtered_for_search.xlsx`: Excel version of the same curated table. This version preserves the visual colour coding used during curation, but the CSV file should be preferred for reproducible scripts.
- `youtube_search_terms_ungrouped.csv`: one-column list of scientific names, vernacular names, and spelling variants used as YouTube search terms.

The terms in `youtube_search_terms_ungrouped.csv` are provided as a transparent one-column search-term list. The full grouped search-term objects used in the private bulk API retrieval workflow are not redistributed in the public package.

## Notes

The first-record table is a row-level curation file. Some species may appear more than once when they are associated with different Iberian regions or source records. The manuscript species count refers to the final harmonised study search scope after exclusions and standardisation.

The full Alien Species First Records Database is not redistributed here. Users should obtain the original database from its official Zenodo record and use the version cited in the manuscript.
