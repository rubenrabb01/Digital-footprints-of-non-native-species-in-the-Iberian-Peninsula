# Iberian NNS YouTube workflow

This repository contains the R workflow used to analyse YouTube videos about recently introduced non-native species in the Iberian Peninsula.

The main analyses are reproducible from the curated files in `data/paper_input/`. The YouTube API search is kept as an optional upstream step because YouTube results, comments, and metadata can change over time and because full retrieval can be slow and quota-limited.

## Repository documentation

- [Public release guide](PUBLIC_RELEASE_GUIDE.md)
- [Workflow review notes](WORKFLOW_REVIEW_NOTES.md)
- [License options](LICENSE_OPTIONS.md)
- [Validation file notes](VALIDATION_FILES_README.md)
- [Data file guide](docs/DATA_FILE_GUIDE.md)

## Main inputs

- `data/paper_input/videos_validated.csv`: validated video-level dataset used in the paper.
- `data/paper_input/comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.
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

## Optional API search

The folder `optional_youtube_api_preworkflow/` shows how raw YouTube API files can be generated. Rerunning this step is not required to reproduce the paper figures and tables.

## Optional data preparation

The folder `data/preparation_input/` documents the handoff from raw/API-derived candidate files to manual screening and validated video files. It is optional for normal paper reproduction, but useful for transparency and for checking how the curated paper inputs were derived. A file-by-file guide is provided in `data/preparation_input/README.md` and `docs/DATA_FILE_GUIDE.md`.

## Public release note

For a GitHub/Zenodo release, the recommended minimal reproducible package is: `scripts/`, `data/paper_input/`, `data/preparation_input/`, `fig_assets/`, `docs/keyword_lists_cleaned.R`, and the validation consensus/context files needed by `scripts/99_run_validation_audits.R`. Raw API outputs, reviewer-specific validation files, intermediate outputs, and archived exploratory scripts are not required for reproducing the final paper outputs.
