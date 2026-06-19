# Validation files

This repository includes the files and scripts used to validate two parts of the workflow:

1. the Iberia-relevance of the manually validated video corpus, and
2. the thematic classification of keyword occurrences.

The repository includes validation templates, completed validation files, decision rules, summary tables, agreement metrics, and the combined validation figure used in the revised manuscript and Supplementary Material.

## Main locations

```text
data/validation_input/                         Validation templates and completed input files
outputs/validation/tables/                     Validation summary tables and agreement metrics
outputs/figures/supplement/                    Supplementary validation figures
```

Compatibility copies are also retained under `outputs/validation/` so that earlier folder structures continue to work.

## Folder naming schemes

Two naming schemes are supported:

```text
validation_files_by_reviewer/    Named validator folders from the validation round
validation_files_by_validator/   Generic validator-ID folders
```

The scripts can read both naming schemes.

## Completed files

Completed validation files are stored in:

```text
data/validation_input/completed/validation_files_by_reviewer/
data/validation_input/completed/validation_files_by_validator/
```

Legacy fallback locations are also supported:

```text
outputs/validation/completed/validation_files_by_reviewer/
outputs/validation/completed/validation_files_by_validator/
```

Keep the same file names and folder structure when rerunning the validation workflow.

## Running the validation workflow

Run from the repository root:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

This script reads the completed validation files, summarises validation outcomes and agreement metrics, and creates the validation figure.

## Output files

The validation workflow writes tables to:

```text
outputs/validation/tables/
```

and supplementary figures to:

```text
outputs/figures/supplement/
```

The generated validation figure is:

```text
Figure_S9    Combined validation panel: LABEL outcomes, LABEL metrics, keyword performance, and keyword confusion matrix
```

## Notes on validation files

The validation files document the manual checks of Iberia-relevance, keyword classification, and pre-record YouTube-video context. The validation scripts use the completed files to reproduce the reported validation summaries, tables, and supplementary figures.
