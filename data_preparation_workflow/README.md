# Data preparation workflow

This folder contains the optional upstream preparation scripts documenting the handoff from raw API outputs to manually screened and paper-ready datasets.

The main manuscript analyses do **not** require rerunning these scripts, because the curated paper inputs are already provided in `data/paper_input/`. The scripts are included for transparency and to document the filtering/labelling pathway.

Run from the project root:

```r
source("data_preparation_workflow/scripts/99_run_data_preparation_workflow.R", encoding = "UTF-8")
```

## Main steps

1. `01_collect_api_outputs.R`: collects REG, GEO and comment files from the optional API pre-workflow.
2. `02_filter_regioncode_outputs.R`: applies a light screen to region-code results.
3. `03_combine_reg_geo_outputs.R`: combines REG and GEO candidates and deduplicates videos.
4. `04_prepare_manual_label_template.R`: creates a table for manual Iberian-relevance labels.
5. `05_apply_manual_labels.R`: merges completed labels and keeps Iberia-relevant videos.
6. `06_export_paper_input_files.R`: exports API-derived files to `data/paper_input/`.

The original long filtering script is kept in `archive/original_regioncode_filtering_script.R` for traceability.

## Canonical repository files

The frozen public repository uses the following canonical files:

- `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**): full raw REG pool.
- `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**): clean filtered REG candidate pool.
- `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**): REG Iberia-relevant labelled subset.
- `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**): source-flagged geotag/location-based anchor.
- `data/paper_input/videos_validated.csv` (**final LABEL dataset**): final validated paper dataset.

## Safety note

The scripts are designed as documentation and optional rerun tools. They should not overwrite the curated manuscript input files unless overwrite options are deliberately enabled.
