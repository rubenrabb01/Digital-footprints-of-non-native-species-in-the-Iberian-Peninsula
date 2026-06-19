# Species and search-term guide

This guide describes the supplementary species-list and search-term files included in `data/species_input/`.

## `iberian_nns_first_records_filtered_for_search.csv`

**Path:** `data/species_input/iberian_nns_first_records_filtered_for_search.csv`  
**Role:** curated first-record table for the study search scope.  
**Rows:** 250 data rows.  
**Columns:** `Region`, `LifeForm`, `TaxonName`, `PresentStatus`, `FirstRecord`.

This file is the machine-readable version of the curated Iberian first-record table used during construction of the study species list. It was derived from the Alien Species First Records Database v3.1 and Iberian updates after study-specific filtering.

Because it is a row-level first-record table, some species can appear more than once when records differ among Iberian regions or source entries. The manuscript species count refers to the final harmonised search scope, not simply to the raw number of rows in this table.

## `iberian_nns_first_records_filtered_for_search.xlsx`

**Path:** `data/species_input/iberian_nns_first_records_filtered_for_search.xlsx`  
**Role:** Excel version of the same curated table.  

This file preserves visual colour coding used during curation. It is included for transparency, but the CSV version should be preferred for reproducible scripting.

## `youtube_search_terms_ungrouped.csv`

**Path:** `data/species_input/youtube_search_terms_ungrouped.csv`  
**Role:** ungrouped YouTube search-term list.  
**Rows:** 520 search terms, plus header.

This file contains scientific names, vernacular names, and spelling variants used in YouTube searches. The terms are stored as a simple one-column list so the search vocabulary can be inspected directly.

## Source database

The full Alien Species First Records Database v3.1 should be obtained from the official Zenodo record cited in the manuscript. This repository includes the curated first-record table used to define the study search scope and first-record timelines.
