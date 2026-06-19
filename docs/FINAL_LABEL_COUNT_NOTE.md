# Final LABEL dataset count note

The manuscript count should remain **1,899 analysed YouTube video records**.

The file `data/paper_input/videos_validated.csv` contains the final LABEL dataset used by the manuscript analyses. Its row count is 1,899 analysed records, and this is the number reported for the final corpus.

A smaller number can appear if the dataset is summarised only by distinct values in the `video_id` column. That distinct-ID count should not replace the manuscript count. A small number of records may be repeated across search queries or may display oddly in spreadsheet software, but these records correspond to valid analysed videos and were retained in the final dataset.

For technical checks, row counts can be inspected with `scripts/00_check_dataset_lineage.R`, but the manuscript/reporting count for the final corpus is **1,899 analysed records**.
