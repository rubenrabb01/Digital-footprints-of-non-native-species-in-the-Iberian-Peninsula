# Workflow review notes

This note summarises minor documentation and robustness updates made to the reproducible workflow. The analytical sequence, model structure, and figure-generation logic were preserved.

## Documentation and robustness updates

- The root `README.md` describes the main run options, validation workflow, optional API example, and output structure.
- `scripts/HOW_TO_RUN_WORKFLOW.R` provides generic project-path examples and separates the main workflow, comments-only sensitivity workflow, validation workflow, and optional API example.
- Validation documentation was updated to describe the completed validation files, decision rules, summary outputs, and validation figure.
- `data/README.md` and supporting documentation describe the curated analytical inputs, species-list inputs, and upstream preparation files.
- `scripts/15_validation_audits.R` includes fallback support for compact releases that use consensus validation files without individual validator folders.
- A duplicated candidate path in `scripts/01_load_prepare_video_dataset.R` was removed.

## Script naming and release structure

The numbered script names are retained because they define the execution order used by the runner scripts. Keeping these names stable reduces the risk of broken source calls and supports reproducibility across local and archived versions of the workflow.

The repository is organised around the curated analytical inputs in `data/paper_input/`. The data-preparation files document how the analysis-ready corpus was generated, while the main manuscript figures and tables are reproduced from the curated analytical files.

For archiving, the core reproducibility materials are the curated analytical inputs, scripts, documentation, validation summaries, and final outputs. Local development archives, temporary files, duplicated exploratory outputs, and machine-specific intermediate paths are outside the standard release.
