# Iberian NNS YouTube workflow

This repository contains the R workflow used to analyse YouTube videos about recently introduced non-native species in the Iberian Peninsula.

The main analyses are reproducible from the curated files in `data/paper_input/`. The repository also includes data-preparation lineage files and a minimal illustrative YouTube API example. Rerunning API searches can produce different results because YouTube content, metadata, comments, and ranking can change over time.

## Repository documentation

- [Data file guide](docs/DATA_FILE_GUIDE.md)
- [YouTube API retrieval overview](docs/API_RETRIEVAL_OVERVIEW.md)
- [Species and search-term guide](docs/SPECIES_AND_SEARCH_TERMS_GUIDE.md)
- [Final LABEL count note](docs/FINAL_LABEL_COUNT_NOTE.md)
- [GEO/REG dataset audit report](docs/GEO_REG_DATASET_AUDIT_REPORT.md)
- [Validation file notes](VALIDATION_FILES_README.md)
- [Public release guide](PUBLIC_RELEASE_GUIDE.md)
- [License options](LICENSE_OPTIONS.md)
- [Workflow notes](WORKFLOW_REVIEW_NOTES.md)

## Repository structure

The repository is organised into four main parts:

```text
data/                         Curated input data and supporting lineage files
data_preparation_workflow/    Optional scripts documenting the upstream data-preparation pathway
optional_youtube_api_example/  Minimal illustrative YouTube API example only
scripts/                      Main R scripts for analysis, figures, tables, validation, and workflow runners
outputs/                      Reproducible figures, tables, validation summaries, and intermediate files
fig_assets/                   Icons and figure assets used by plotting scripts
docs/                         Additional documentation and data guides
```

The main manuscript workflow uses the frozen files in `data/paper_input/` and writes outputs under `outputs/`.

## Main input files

The core analysis inputs are:

```text
data/paper_input/videos_validated.csv
data/paper_input/comments_timestamped.csv
```

`videos_validated.csv` is the final manually validated video-level corpus used by the main analyses. It contains 1,899 analysed video records. `comments_timestamped.csv` contains timestamped comments and replies used only for the comments-only sensitivity analysis.

Additional species-list and search-term files are provided in `data/species_input/`. These document the curated first-record table used to define the study scope and the ungrouped list of scientific, vernacular, and spelling-variant search terms used for YouTube retrieval. The full Alien Species First Records Database should be obtained from its official Zenodo record.

## Output structure

The main generated outputs are organised as follows:

```text
outputs/figures/main/          Main manuscript figures
outputs/figures/supplement/    Supplementary figures, including validation figures
outputs/tables/main/           Main manuscript tables and model tables
outputs/tables/supplement/     Supplementary tables and source data for supplementary figures
outputs/tables/qa/             Quality-control checks and diagnostic tables
outputs/validation/tables/     Validation summaries, agreement statistics, and validation tables
outputs/intermediate/          Intermediate objects used by the plotting and table scripts
```

The figure folders contain only figure files. Tables, model outputs, QA checks, and validation summaries are written to the corresponding table or validation folders.

## Software

The workflow was built in R. Package installation requirements are handled by the setup scripts, but users may need to install missing packages the first time the workflow is run.

Use the repository root as the working directory. Do not set the working directory to the `scripts/` folder.

Example:

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
```

## Running the workflow

### Main workflow only

This reproduces the main title-and-description analysis.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/14_run_all.R", encoding = "UTF-8")
```

### Main workflow plus comments-only sensitivity

This runs the main analysis and the comments-only sensitivity analysis.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
```

### Validation workflow

This creates the validation templates and reads completed validation files when available. It then writes validation summaries and supplementary validation figures.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

Supplementary figures are written to `outputs/figures/supplement/`. The coverage plot is exported as `Figure_S1`, engagement and model-sensitivity figures as `Figure_S2`–`Figure_S7`, the lead/lag and pre-record context panel as `Figure_S8`, the combined validation panel as `Figure_S9`, and the symmetric-window sensitivity figure as `Figure_S10`.

### Full reproducibility run

This runs the main workflow, comments-only sensitivity, and validation workflow.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
setTimeLimit(cpu = Inf, elapsed = Inf, transient = FALSE)
source("scripts/99_run_main_plus_comments_sensitivity.R", encoding = "UTF-8")
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```

### Optional exploratory figure test

An additional exploratory script can be run separately to test video-availability and alternative radial engagement summaries. This script is not sourced by the main workflow runners.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
source("scripts/19_test_video_availability_and_radial_engagement.R", encoding = "UTF-8")
```

The outputs are written to `outputs/figures/exploratory/` and can be inspected before deciding whether to incorporate them into the manuscript or Supplementary Material.

### Optional API example

The manuscript analyses are reproduced from the curated analytical datasets. A minimal illustrative single-query example is provided to show the basic structure of a YouTube Data API request in R.

```r
rm(list = ls())
setwd("YOUR_PROJECT_FOLDER")
Sys.setenv(YOUTUBE_API_KEY = "YOUR_KEY_HERE")
source("optional_youtube_api_example/example_single_species_youtube_api_query.R", encoding = "UTF-8")
```

The example writes a small demonstration output to `optional_youtube_api_example/outputs/`. Do not save or commit an API key.

## Validation files

Validation files are stored under `data/validation_input/`, with compatibility copies under `outputs/validation/`. The workflow supports both named validator folders and generic validator folders. For repository sharing, the generic validator folders and summary outputs are recommended.

More details are provided in [Validation file notes](VALIDATION_FILES_README.md).

## Data availability and reuse

This repository is intended to support transparency and reproducibility of the associated manuscript. It contains curated data, scripts, figures, tables, and documentation needed to inspect and reproduce the analyses.

Users who run new API searches should expect results to differ from the frozen manuscript corpus because platform content and API results change over time. Please cite the associated manuscript and repository when using this workflow to inspect, reproduce, or build upon the analyses.


## Data de-identification

The repository uses de-identified YouTube-derived data. Direct video identifiers, video URLs, channel names, comment identifiers, and comment-author names have been replaced with stable internal labels or withheld. The mapping to original YouTube identifiers is not included. This preserves reproducibility for the analyses while reducing the redistribution of direct platform identifiers. See `docs/PUBLIC_DATA_DEIDENTIFICATION_NOTE.md` for details.
