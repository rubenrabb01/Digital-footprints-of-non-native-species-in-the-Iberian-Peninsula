# Validation input files

This folder contains the CSV files used to validate the manually curated video corpus and the keyword-classification workflow.

Two folder naming schemes are supported:

- `validation_files_by_reviewer/`: named folders used during private project work.
- `validation_files_by_validator/`: anonymised folders using generic validator IDs.

The scripts can read both structures. For public release, the anonymised `validation_files_by_validator/` structure is recommended.

## Using completed files

When completed validation files are available, place them in one of these folders, keeping the same file names and folder structure:

```text
data/validation_input/completed/validation_files_by_reviewer/
data/validation_input/completed/validation_files_by_validator/
```

Legacy fallback folders under `outputs/validation/completed/` are also supported.

Then run from the repository root:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

The script writes validation tables to `outputs/validation/tables/` and supplementary validation figures to `outputs/figures/supplement/`.

## Figures produced from these inputs

After running `scripts/99_run_validation_audits.R`, the following figures are written to `outputs/figures/supplement/`:

- `Figure_S9`: combined validation panel with LABEL Iberia-relevance outcomes, LABEL validation metrics, keyword-classification performance, and the keyword-validation confusion matrix.

Files included as completed examples may contain artificial placeholder decisions. Replace them with the checked completed files before reporting final validation values.
