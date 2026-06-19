# 99_run_data_preparation_workflow.R
# Run the optional preparation steps from API output to labelled input files.

source("data_preparation_workflow/scripts/01_collect_api_outputs.R", encoding = "UTF-8")
source("data_preparation_workflow/scripts/02_filter_regioncode_outputs.R", encoding = "UTF-8")
source("data_preparation_workflow/scripts/03_combine_reg_geo_outputs.R", encoding = "UTF-8")
source("data_preparation_workflow/scripts/04_prepare_manual_label_template.R", encoding = "UTF-8")

label_candidates <- c(
  file.path(PROJECT_ROOT, "data", "validation_templates", "manual_iberian_labels.csv"),
  file.path(PROJECT_ROOT, "data", "validation_templates", "manual_iberian_labels_completed.csv"),
  file.path(PROJECT_ROOT, "data", "preparation_input", "manual_iberian_labels.csv"),
  file.path(PROJECT_ROOT, "data", "preparation_input", "api_regioncode_labelled.csv")
)

if (any(file.exists(label_candidates))) {
  source("data_preparation_workflow/scripts/05_apply_manual_labels.R", encoding = "UTF-8")
  source("data_preparation_workflow/scripts/06_export_paper_input_files.R", encoding = "UTF-8")
} else {
  message("Manual labels were not found.")
  message("Fill data/validation_templates/manual_iberian_labels_template.csv and save it as manual_iberian_labels.csv, then run scripts 05 and 06.")
}
