# Validation input files

This folder contains the reviewer/validator CSV files used to audit the manually validated LABEL corpus and the keyword-classification workflow.

Two folder naming schemes are supported:

- `validation_files_by_reviewer/`: legacy/private structure using the original reviewer names (e.g. Ana, Gabriel, Loreto, Valerio).
- `validation_files_by_validator/`: anonymised structure using generic reviewer IDs (Reviewer_A–Reviewer_D).

The analysis scripts accept both structures. For a public release, the anonymised `validation_files_by_validator/` structure is recommended. For private manuscript revision work, the legacy reviewer-name folders can be used if that is how the completed files were returned.

## How to use completed files

When completed validation files are returned by coauthors/reviewers, place them in one of the completed folders below, keeping the same file names and folder structure:

- `data/validation_input/completed/validation_files_by_reviewer/`
- `data/validation_input/completed/validation_files_by_validator/`
- legacy fallback: `outputs/validation/completed/validation_files_by_reviewer/`
- legacy fallback: `outputs/validation/completed/validation_files_by_validator/`

Then run:

```r
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

The script will update the validation tables and validation figures in `outputs/validation/tables/` and `outputs/figures/validation/`.

The files included here as completed examples may contain artificial placeholder decisions. Replace them with the real completed files before reporting final validation values.

## Figures produced from these inputs

After running `scripts/99_run_validation_audits.R`, the following figures are written to `outputs/figures/validation/`:

- `Figure_S9_LABEL_validation_outcomes`: LABEL Iberia-relevance audit outcome categories.
- `Figure_S10_LABEL_validation_metrics`: LABEL validation metrics and agreement summaries.
- `Figure_S11_keyword_validation_performance`: keyword-classification precision, recall, and F1 by category.
- `Figure_S12_keyword_validation_confusion_matrix`: keyword-validation confusion matrix.

These outputs use the currently available completed/placeholder files. Replace the completed CSV files with the real returned reviewer files before reporting final values in the manuscript or response letter.
