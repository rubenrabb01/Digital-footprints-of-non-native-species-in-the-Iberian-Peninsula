# 99_run_data_preparation_workflow.R
# Prepare API outputs for manual screening and, if labels are available, build a validated file.

source("data_preparation_workflow/scripts/01_prepare_api_outputs_for_labeling.R", encoding = "UTF-8")

label_file <- file.path(PROJECT_ROOT, "data", "validation_templates", "manual_iberian_labels.csv")
if (file.exists(label_file)) {
  source("data_preparation_workflow/scripts/02_apply_manual_labels.R", encoding = "UTF-8")
} else {
  message("Manual labels not found. Fill the screening table before running 02_apply_manual_labels.R.")
}
