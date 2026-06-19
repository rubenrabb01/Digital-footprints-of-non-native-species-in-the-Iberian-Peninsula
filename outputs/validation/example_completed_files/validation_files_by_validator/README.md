# Example completed validation files

This folder contains artificial completed examples for testing the validation workflow.

The examples allow the scripts to run before final completed validation files are available. They should not be used for final manuscript values.

When final completed files are available, place them in the completed-file folders described in `VALIDATION_FILES_README.md` and rerun:

```r
source("scripts/99_run_validation_audits.R", encoding = "UTF-8")
```
