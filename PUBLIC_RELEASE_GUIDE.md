# Repository release guide

This repository is intended to provide a transparent, reproducible version of the workflow used in the associated manuscript.

## Recommended repository contents

The GitHub/Zenodo version should include:

- `scripts/`: main analysis and validation scripts.
- `optional_youtube_api_example/`: minimal illustrative YouTube API example.
- `data_preparation_workflow/`: upstream filtering, GEO/REG combination, and manual-labelling preparation scripts.
- `data/paper_input/`: curated paper input files.
  - `videos_validated.csv` (**final LABEL dataset**)
  - `comments_timestamped.csv` (**comments sensitivity input**)
- `data/preparation_input/`: upstream preparation files documenting the filtering and labelling path.
  - `api_regioncode_raw.csv` (**RAW-REG**)
  - `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**)
  - `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**)
  - `api_regioncode_labelled.csv` (**REG-labelled**)
  - `api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**)
- `fig_assets/`: icons and graphical assets used by the scripts.
- `docs/`: keyword lists and documentation.
- `outputs/validation/`: validation files and summaries needed to reproduce validation outputs.

## Files not needed for the manuscript workflow

The manuscript figures, tables, validation summaries, and sensitivity checks are reproduced from the curated analytical files included in this repository. Local development archives, duplicated exploratory datasets, machine-specific paths, temporary files, and ad hoc rerun outputs are not needed for the standard workflow.

## Main dataset labels

- `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**) = full raw REG pool.
- `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) = filtered REG candidate pool.
- `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**) = REG Iberia-relevant labelled subset.
- `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**) = geotag/location-based GEO retrieval file.
- `data/paper_input/videos_validated.csv` (**final LABEL dataset**) = final validated dataset used by the scripts.

Older exploratory `label_this_sample_*` files should not be uploaded as canonical inputs unless they are moved to an archive folder and explicitly documented as non-canonical.

## Suggested release sequence

1. Check that the repository contains the expected scripts, data, documentation, figures, and tables.
2. Confirm that no API keys, local paths, temporary files, or unnecessary archives are present.
3. Confirm that `README.md`, `docs/DATA_FILE_GUIDE.md`, `docs/API_RETRIEVAL_OVERVIEW.md`, and `data/preparation_input/README.md` display correctly.
4. Run the workflow locally from the GitHub-style folder structure.
5. Make a tagged GitHub release when the repository is stable.
6. Archive the tagged release in Zenodo and add the DOI to the manuscript/repository.

## Species-list and search-term inputs

The release includes `data/species_input/`, which contains a curated first-record table and an ungrouped YouTube search-term list. These files document the search-scope construction. The full external Alien Species First Records Database should be downloaded from the official Zenodo record cited in the manuscript.

## Validation files

During peer review, validator-specific CSV files were used to check the audit workflow. For repository sharing, generic validator folders, consensus validation outputs, and summary metrics are easiest to inspect and reuse. The artificial files in `outputs/validation/example_completed_files/` are only workflow tests and should not be used for final reported values.

Note: CSV files included for repository sharing use stable internal identifiers in place of direct YouTube video IDs, video URLs, channel names, comment IDs, and comment-author names. The original identifier mapping is not included.
