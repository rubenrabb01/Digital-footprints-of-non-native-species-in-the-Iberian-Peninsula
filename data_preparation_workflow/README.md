# Data preparation workflow

This folder contains optional upstream scripts that document how API-derived files were filtered, combined, manually labelled, and exported to the curated paper inputs.

The main manuscript analyses do not require rerunning these scripts. They are reproducible from the curated files in `data/paper_input/`.

Run from the repository root:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
source("data_preparation_workflow/scripts/99_run_data_preparation_workflow.R", encoding = "UTF-8")
```

## Main steps

1. `01_collect_api_outputs.R`: collects REG, GEO, and comment files from the optional API pre-workflow.
2. `02_filter_regioncode_outputs.R`: applies screening to region-code results.
3. `03_combine_reg_geo_outputs.R`: combines REG and GEO candidates and deduplicates videos.
4. `04_prepare_manual_label_template.R`: creates a table for manual Iberian-relevance labelling.
5. `05_apply_manual_labels.R`: merges completed labels and keeps Iberia-relevant videos.
6. `06_export_paper_input_files.R`: exports curated files to `data/paper_input/`.

The original long filtering script is kept in `archive/original_regioncode_filtering_script.R` for traceability.

## Main output files

The preparation workflow documents the path leading to:

```text
data/preparation_input/api_regioncode_raw.csv
data/preparation_input/api_regioncode_postfiltered_candidates.csv
data/preparation_input/api_regioncode_labelled.csv
data/preparation_input/api_geotagged_anchor_sourceflag.csv
data/paper_input/videos_validated.csv
```

## Note

These scripts are included to document the upstream workflow. Recreating the exact API-derived candidate pool may not be possible because YouTube results can change over time.
