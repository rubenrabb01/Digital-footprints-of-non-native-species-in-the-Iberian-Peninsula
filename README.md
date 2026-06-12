# Iberian NNS YouTube workflow

This repository contains the R workflow used to analyse YouTube videos about recently introduced non-native species in the Iberian Peninsula.

The main analyses are reproducible from the curated files in `data/paper_input/`. The YouTube API search is kept as an optional upstream step because YouTube results, comments, and metadata can change over time and because full retrieval can be slow and quota-limited.

## Repository documentation

- [Public release guide](PUBLIC_RELEASE_GUIDE.md)
- [Workflow review notes](WORKFLOW_REVIEW_NOTES.md)
- [License options](LICENSE_OPTIONS.md)
- [Validation file notes](VALIDATION_FILES_README.md)
- [Data file guide](docs/DATA_FILE_GUIDE.md)
- [GEO/REG dataset audit report](docs/GEO_REG_DATASET_AUDIT_REPORT.md)

## Dataset terminology

The repository separates raw search outputs, post-filtered candidates, manually labelled files, and the final paper input. The main dataset labels used throughout the repository are:

- `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**): full raw region-code video pool retrieved from YouTube searches before filtering; 16,844 unique videos.
- `data/preparation_input/api_regioncode_raw_flagged.csv` (**RAW-REG flagged**): the same full REG pool with an `is_iberian` flag documenting which records were retained or rejected during filtering/labelling.
- `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**): clean candidate REG set after language and Iberian locality filters; 6,935 unique videos. This is an intermediate candidate file, not the final paper dataset.
- `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**): REG videos labelled as Iberia-relevant after filtering and labelling; 1,884 unique videos.
- `data/preparation_input/api_geotagged_anchor_reconstructed.csv` (**GEO anchor reconstructed / reconstructed RAW-GEO**): geotag/location-based anchor recovered from older source-flagged working files by selecting records marked `GEO` or `BOTH`; 305 unique videos.
  The file name uses `reconstructed` because this GEO anchor was recovered from older source-flagged working files rather than from a standalone raw GEO API export.
- `data/paper_input/videos_validated.csv` (**final LABEL dataset**): final validated video-level dataset used by the manuscript scripts; 1,899 rows and 1,895 unique videos.
- `data/paper_input/comments_timestamped.csv` (**comments sensitivity input**): timestamped comments and replies used for the comments-only sensitivity analysis.

In short, `api_regioncode_raw.csv` (**RAW-REG**) documents the full raw REG search pool; `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) documents the filtered candidate pool; `api_regioncode_labelled.csv` (**REG-labelled**) documents the accepted REG subset; `api_geotagged_anchor_reconstructed.csv` (**GEO anchor reconstructed / reconstructed RAW-GEO**) documents the historical geotagged pathway; and `videos_validated.csv` (**final LABEL dataset**) is the file used by the paper workflow.

## Dataset lineage in brief

```text
api_regioncode_raw.csv (RAW-REG; 16,844 videos)
  -> api_regioncode_postfiltered_candidates.csv (REG post-filtered candidates; 6,935 videos)
  -> api_regioncode_labelled.csv (REG-labelled; 1,884 videos)
  -> videos_validated.csv (final LABEL dataset; 1,899 rows / 1,895 unique videos)

api_geotagged_anchor_reconstructed.csv (GEO anchor reconstructed / reconstructed RAW-GEO; 305 videos)
  -> documents the geotag/location-based search pathway recovered from older source-flagged working files
```

See [`docs/DATA_FILE_GUIDE.md`](docs/DATA_FILE_GUIDE.md) for details.

## Main inputs

- `data/paper_input/videos_validated.csv` (**final LABEL dataset**): validated video-level dataset used in the paper.
- `data/paper_input/comments_timestamped.csv` (**comments sensitivity input**): timestamped comments and replies used for the comments-only sensitivity analysis.
- `fig_assets/`: icons used by the publication figures.
- `data/preparation_input/`: optional upstream preparation files documenting how API-derived candidate videos were filtered and manually screened before export to the curated paper inputs.

## Main runs

Run the main paper analysis using titles and descriptions only:

```r
source("scripts/14_run_all.R", encoding = "UTF-8")
```

Run the main analysis plus the comments-only sensitivity check:

```r
source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
```

Create validation summaries and supplementary lead-lag checks:

```r
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

A more detailed run guide is available in `scripts/HOW_TO_RUN_WORKFLOW.R`.
Additional audit summaries comparing GEO/REG source labels are available in `docs/geo_sourceflag_comparison_summary.csv` and `docs/geo_anchor_overlap_with_repo_datasets.csv`.

## Optional API search

The folder `optional_youtube_api_preworkflow/` shows how raw YouTube API files can be generated. Rerunning this step is not required to reproduce the paper figures and tables.

## Optional data preparation

The folder `data/preparation_input/` documents the handoff from raw/API-derived candidate files to manual screening and validated video files. It is optional for normal paper reproduction, but useful for transparency and for checking how the curated paper inputs were derived. A file-by-file guide is provided in `data/preparation_input/README.md` and `docs/DATA_FILE_GUIDE.md`.

## Public release note

For a GitHub/Zenodo release, the recommended minimal reproducible package is: `scripts/`, `data/paper_input/`, `data/preparation_input/`, `fig_assets/`, `docs/keyword_lists_cleaned.R`, and the validation consensus/context files needed by `scripts/99_run_validation_audits.R`. Full development archives, reviewer-specific validation files, and non-canonical exploratory datasets are not required for reproducing the final paper outputs.

## Reuse and citation

This repository is shared to support review, transparency, and reproducibility of the associated manuscript. Reuse of scripts, workflow structure, or derivative code for other projects requires permission from the authors unless a separate license is added later.

Please cite the associated manuscript and repository if using this workflow to inspect, reproduce, or build upon the analyses.
