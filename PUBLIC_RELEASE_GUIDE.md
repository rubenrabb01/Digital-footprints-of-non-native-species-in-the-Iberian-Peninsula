# Public release guide

This repository is intended to provide a transparent, reproducible version of the workflow used in the associated manuscript.

## Recommended public contents

The public GitHub/Zenodo version should include:

- `scripts/`: main analysis and validation scripts.
- `optional_youtube_api_preworkflow/`: optional upstream YouTube API search scripts; generated API outputs should remain local unless intentionally released.
- `data_preparation_workflow/`: optional upstream filtering, GEO/REG combination and manual-labelling preparation scripts.
- `data/paper_input/`: curated paper input files.
  - `videos_validated.csv` (**final LABEL dataset**)
  - `comments_timestamped.csv` (**comments sensitivity input**)
- `data/preparation_input/`: upstream preparation files documenting the filtering and labelling path.
  - `api_regioncode_raw.csv` (**RAW-REG**)
  - `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**)
  - `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**)
  - `api_regioncode_labelled.csv` (**REG-labelled**)
  - `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**)
- `fig_assets/`: icons and graphical assets used by the scripts.
- `docs/`: keyword lists and documentation.
- `outputs/validation/`: consensus validation files needed to reproduce validation summaries.

## Files that should normally remain private

The public repository does not need full development archives, reviewer-specific validation files, local raw API dumps generated during reruns, or duplicated exploratory datasets. Optional API/data-preparation scripts can be included for transparency, but their generated outputs should not be treated as canonical public inputs. If such files are retained privately, they should not be treated as canonical public inputs.

## Main dataset labels

- `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**) = full raw REG pool.
- `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) = clean filtered REG candidate pool.
- `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**) = REG Iberia-relevant labelled subset.
- `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**) = source-flagged geotag/location-based anchor.
- `data/paper_input/videos_validated.csv` (**final LABEL dataset**) = final validated dataset used by the scripts.

Older exploratory `label_this_sample_*` files should not be uploaded as canonical inputs unless they are moved to an archive folder and explicitly documented as non-canonical.

## Suggested release sequence

1. Keep the GitHub repository private while checking files.
2. Confirm that no API keys, private paths, reviewer-specific files, or unnecessary archives are present.
3. Confirm that `README.md`, `docs/DATA_FILE_GUIDE.md`, and `data/preparation_input/README.md` display correctly.
4. Run the workflow locally from the GitHub-style folder structure.
5. Make a tagged GitHub release only after the repository is stable.
6. Archive the tagged release in Zenodo and add the DOI to the manuscript/repository.


## Species-list and search-term inputs

The public release includes `data/species_input/`, which contains a curated first-record table and an ungrouped YouTube search-term list. These files improve transparency of the search-scope construction. The full external Alien Species First Records Database is not redistributed; users should download it from the official Zenodo record cited in the manuscript.

## Validation files for public release

During peer review, reviewer-specific CSV files may be useful for checking the audit workflow. For a public GitHub/Zenodo release, prefer anonymised consensus validation outputs and summary metrics rather than individual reviewer files, unless reviewers/coauthors explicitly agree to share those files. The artificial files in `outputs/validation/example_completed_files/` are only workflow tests and should be removed or clearly retained as examples before public release.


Note: CSV files intended for public release use stable internal identifiers in place of direct YouTube video IDs, video URLs, channel names, comment IDs, and comment-author names. The original identifier mapping is not included.
