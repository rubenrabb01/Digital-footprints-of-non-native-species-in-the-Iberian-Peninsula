# Iberian NNS YouTube workflow

This repository contains the R workflow used to analyze YouTube videos about recently introduced non-native species in the Iberian Peninsula.

The main analyses are reproducible using the curated files in `data/paper_input/`. The YouTube API search is optional because YouTube results, comments, and metadata can change over time, and full retrieval may be slow and subject to quota limits.

## Repository documentation

- [Public release guide](PUBLIC_RELEASE_GUIDE.md)
- [Workflow review notes](WORKFLOW_REVIEW_NOTES.md)
- [License options](LICENSE_OPTIONS.md)
- [Validation file notes](VALIDATION_FILES_README.md)

## Main inputs

- `data/paper_input/videos_validated.csv`: validated video-level dataset used in the paper.
- `data/paper_input/comments_timestamped.csv`: timestamped comments and replies used for the comments-only sensitivity analysis.
- `fig_assets/`: icons used by the publication figures.

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

The folder `optional_youtube_api_preworkflow/` demonstrates how raw YouTube API files can be generated. Rerunning this step is not required to reproduce the figures and tables in the paper.

## Optional data preparation

The folder `data_preparation_workflow/` documents the transition from raw API outputs to manual screening and validated video files. This step is optional for standard paper reproduction but useful when starting from newly retrieved API outputs.

## Public release note

For a GitHub/Zenodo release, the recommended minimal reproducible package is: `scripts/`, `data/paper_input/`, `fig_assets/`, `docs/keyword_lists_cleaned.R`, and the validation consensus/context files needed by `scripts/99_run_validation_audits.R`. Raw API outputs, reviewer-specific validation files, intermediate outputs, and archived exploratory scripts are not necessary for reproducing the final paper outputs.

## Reuse and citation

This repository is provided to support review, transparency, and reproducibility of the associated manuscript. Reuse of scripts, workflow structure, or derivative code for other projects requires permission from the authors unless a separate license is added later.

Please cite the associated manuscript and repository if you use this workflow to inspect, reproduce, or build upon the analyses.
