# Validation files

This repository includes the files and scripts used to validate:

1. Iberia-relevance of the final manually curated video corpus,
2. thematic classification of keyword occurrences, and
3. context of pre-record lead/lag cases used for Figure S8.

## Main locations

```text
data/validation_input/                         Validation templates and completed input files
data/validation_input/completed/               Completed validation inputs used by the scripts
outputs/validation/tables/                     Generated validation summaries and agreement metrics
outputs/validation/completed/                  Generated consensus files
outputs/figures/supplement/                    Supplementary validation figures
```

Completed validator files are stored under:

```text
data/validation_input/completed/validation_files_by_validator/
```

## Active completed files

- `Reviewer_A`: video-level Iberia-relevance validation only.
- `Reviewer_B`: video-level Iberia-relevance validation and keyword-category validation.
- `Reviewer_D`: video-level Iberia-relevance validation and keyword-category validation.

The completed pre-record context file is:

```text
data/validation_input/completed/lead_lag_context/lead_lag_prerecord_context_completed.csv
```

## Running the validation workflow

Run from the repository root:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

This reads the completed validation files, writes validation summaries to `outputs/validation/tables/`, and updates supplementary Figures S8 and S9.

Generated files under `outputs/` should not be edited manually. To update validation results, edit or replace the completed input files under `data/validation_input/completed/` and rerun the workflow.
