# Workflow review notes

This note summarises minor documentation and robustness updates made to the reproducible workflow. The analytical sequence, model structure, and figure-generation logic were preserved.

## Documentation and robustness updates

- The root `README.md` describes the main run options, validation workflow, optional API test, and output structure.
- `scripts/HOW_TO_RUN_WORKFLOW.R` provides generic project-path examples and separates the main workflow, comments-only sensitivity workflow, validation workflow, and optional API test.
- Validation documentation was updated to distinguish anonymised public-release folders from named private working folders.
- `data/README.md` and supporting documentation describe the curated analytical inputs, species-list inputs, and optional upstream preparation files.
- `scripts/15_validation_audits.R` includes fallback support for compact public releases that use consensus validation files without reviewer-specific folders.
- A duplicated candidate path in `scripts/01_load_prepare_video_dataset.R` was removed.

## Script naming and release structure

The numbered script names are retained because they define the execution order used by the runner scripts. Keeping these names stable reduces the risk of broken source calls and supports reproducibility across local and archived versions of the workflow.

The repository is organised as a reproducible release centred on the curated analytical inputs in `data/paper_input/`. Optional upstream API and data-preparation folders are included for transparency and future reuse, but they are not required to reproduce the manuscript figures and tables from the frozen analytical corpus.

For public archiving, de-identified analytical inputs, scripts, documentation, validation summaries, and final outputs are the core reproducibility materials. Raw API outputs, private reviewer-specific files, archived exploratory scripts, and machine-specific intermediate paths should remain excluded from the compact public release unless they are explicitly needed for audit purposes and can be shared under the relevant platform and privacy constraints.
