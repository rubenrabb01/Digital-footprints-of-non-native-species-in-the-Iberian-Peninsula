# Iberian NNS YouTube workflow

This repository contains the R workflow used to analyse YouTube videos about recently introduced non-native species in the Iberian Peninsula.

The main analyses are reproducible from the curated files in `data/paper_input/`. Optional upstream folders document the YouTube API search and preparation steps. Rerunning API searches can produce different results because YouTube content, metadata, comments, and ranking change over time.

## Repository documentation

- [Data file guide](docs/DATA_FILE_GUIDE.md)
- [YouTube API retrieval overview](docs/API_RETRIEVAL_OVERVIEW.md)
- [Species and search-term guide](docs/SPECIES_AND_SEARCH_TERMS_GUIDE.md)
- [Final LABEL count note](docs/FINAL_LABEL_COUNT_NOTE.md)
- [GEO/REG dataset audit report](docs/GEO_REG_DATASET_AUDIT_REPORT.md)
- [Validation file notes](VALIDATION_FILES_README.md)
- [Repository release guide](PUBLIC_RELEASE_GUIDE.md)
- [Workflow notes](WORKFLOW_REVIEW_NOTES.md)

## Repository structure

```text
data/                         Curated input data and supporting lineage files
data_preparation_workflow/    Optional upstream data-preparation scripts
optional_youtube_api_preworkflow/ Optional YouTube API retrieval scripts
scripts/                      Main R scripts for analyses, figures, tables, validation, and workflow runners
outputs/                      Reproducible figures, tables, validation summaries, and intermediate files
fig_assets/                   Icons and figure assets used by plotting scripts
docs/                         Additional documentation and data guides
```

The manuscript workflow uses the frozen files in `data/paper_input/` and writes outputs under `outputs/`.

## Main input files

```text
data/paper_input/videos_validated.csv
data/paper_input/comments_timestamped.csv
```

`videos_validated.csv` is the final manually curated Iberia-relevant video-level corpus used by the main analyses. It contains **1,895 distinct YouTube videos from 1,002 channels and 94 species**. In the workflow this file is also referred to as the final LABEL dataset. `comments_timestamped.csv` contains timestamped comments and replies used only for the comments-only sensitivity analysis.

Additional species-list and search-term files are provided in `data/species_input/`. These document the curated first-record table and the ungrouped list of scientific, vernacular, and spelling-variant search terms used for YouTube retrieval. The full Alien Species First Records Database is not redistributed.

## Output structure

```text
outputs/figures/main/          Main manuscript figures
outputs/figures/supplement/    Supplementary figures, including validation figures
outputs/tables/main/           Main manuscript tables and model tables
outputs/tables/supplement/     Supplementary tables and source data for supplementary figures
outputs/tables/qa/             Quality-control checks and diagnostic tables
outputs/validation/tables/     Validation summaries, agreement statistics, and validation tables
outputs/intermediate/          Intermediate objects used by plotting and table scripts
```

## Running the workflow

Run all commands from the repository root, not from the `scripts/` folder.

### Main workflow

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/14_run_all.R", encoding = "UTF-8")
```

### Main workflow plus comments-only sensitivity

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
```

### Validation workflow

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

This reads the completed validation files in `data/validation_input/completed/`, writes validation tables under `outputs/validation/tables/`, and updates the supplementary validation figures.

### Full run

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

## Validation files

The public package uses anonymised validator folders under `data/validation_input/completed/validation_files_by_validator/`.

Active completed files:

- `Reviewer_A`: video-level Iberia-relevance validation only.
- `Reviewer_B`: video-level Iberia-relevance validation and keyword-category validation.
- `Reviewer_D`: video-level Iberia-relevance validation and keyword-category validation.

More details are provided in [Validation file notes](VALIDATION_FILES_README.md).

## Data de-identification

Direct YouTube video identifiers, URLs, channel names, comment identifiers, and comment-author names have been replaced with stable internal labels or withheld. The mapping to original YouTube identifiers is not included. See `docs/PUBLIC_DATA_DEIDENTIFICATION_NOTE.md`.

## Reuse

This repository supports transparency and reproducibility of the associated manuscript. Please cite the manuscript and repository when using the workflow to inspect, reproduce, or build upon the analyses.
