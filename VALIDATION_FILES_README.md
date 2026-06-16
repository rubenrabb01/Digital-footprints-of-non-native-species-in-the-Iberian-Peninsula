# Validation files

This repository includes the files and scripts used to validate two parts of the workflow:

1. the Iberia-relevance of the manually validated video corpus, and
2. the thematic classification of keyword occurrences.

The validation workflow can be run with the example files included in the repository. When final completed validation files are available, they can be placed in the completed-file folders and the same script can be rerun.

## Main locations

```text
data/validation_input/                         Validation templates and completed input files
outputs/validation/tables/                     Validation summary tables and agreement metrics
outputs/figures/supplement/                    Supplementary validation figures
outputs/validation/example_completed_files/    Artificial completed examples for testing only
```

Compatibility copies are also retained under `outputs/validation/` so that earlier folder structures continue to work.

## Folder naming schemes

Two naming schemes are supported:

```text
validation_files_by_reviewer/    Named folders used during private project work
validation_files_by_validator/   Anonymised folders suitable for public sharing
```

The scripts can read both. For public release, the anonymised `validation_files_by_validator/` structure is recommended.

## Where to place completed files

Completed validation files can be placed in either of these locations:

```text
data/validation_input/completed/validation_files_by_reviewer/
data/validation_input/completed/validation_files_by_validator/
```

Legacy fallback locations are also supported:

```text
outputs/validation/completed/validation_files_by_reviewer/
outputs/validation/completed/validation_files_by_validator/
```

Keep the same file names and folder structure when replacing template or example files with completed files.

## Running the validation workflow

Run from the repository root:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

This script runs the validation audit and creates validation figures.

## Output files

The validation workflow writes tables to:

```text
outputs/validation/tables/
```

and supplementary figures to:

```text
outputs/figures/supplement/
```

The generated validation figures are:

```text
Figure_S9    LABEL Iberia-relevance validation outcomes
Figure_S10   LABEL validation metrics and agreement summaries
Figure_S11   Keyword-classification precision, recall, and F1 scores
Figure_S12   Keyword-classification confusion matrix
```

## Notes on example files

The repository includes artificial completed examples so the workflow can be tested before final completed validation files are available. These examples are useful for checking file paths, script behaviour, and figure generation.

Do not report values from artificial examples as final manuscript values. Replace them with the checked completed validation files before final reporting.
