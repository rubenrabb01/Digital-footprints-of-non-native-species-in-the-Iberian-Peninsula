# GEO/REG dataset audit

This audit documents how the GEO and REG dataset pathways relate to the final LABEL dataset used in the manuscript analyses.

## Main conclusion

The GEO retrieval file contains **305 unique videos** from the geotag/location-based retrieval pathway. This set was identified consistently from intermediate preparation files using the `source_flag` column, which records whether a video was retrieved through GEO, REG, or both routes.

The REG pathway was much larger and required ecological, linguistic, and Iberian locality filtering followed by manual Iberia-relevance verification. The final manuscript analyses use `data/paper_input/videos_validated.csv`, which contains **1,899 analysed video records**.

## Canonical repository files

| Label | File | Rows | Unique videos | Meaning |
|---|---|---:|---:|---|
| RAW-REG | `data/preparation_input/api_regioncode_raw.csv` (**RAW-REG**) | 16,844 | 16,844 | Full raw region-code video pool. |
| RAW-REG flagged | `data/preparation_input/api_regioncode_raw_flagged.csv` (**RAW-REG flagged**) | 16,844 | 16,844 | Same RAW-REG pool with retained/rejected flag. |
| REG post-filtered candidates | `data/preparation_input/api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) | 6,935 | 6,935 | Filtered REG candidate set. |
| REG-labelled | `data/preparation_input/api_regioncode_labelled.csv` (**REG-labelled**) | 1,884 | 1,884 | REG videos labelled as Iberia-relevant. |
| GEO retrieval file | `data/preparation_input/api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**) | 305 | 305 | Geotag/location-based GEO retrieval records. |
| Final LABEL dataset | `data/paper_input/videos_validated.csv` (**final LABEL dataset**) | 1,899 analysed records |  | Final analysis-ready paper dataset. |

## Relationship between GEO retrieval and the final LABEL dataset

The 305-video GEO retrieval file documents the geotag/location-based search pathway. It is not identical to the current final LABEL dataset. Only 68 of the 305 GEO video IDs overlap `data/paper_input/videos_validated.csv` (**final LABEL dataset**).

Therefore:

- `api_geotagged_anchor_sourceflag.csv` (**GEO retrieval file**) documents the geotag/location-based search pathway.
- `videos_validated.csv` (**final LABEL dataset**) remains the analysis-ready paper dataset used by the current scripts.
- The GEO retrieval file should not be used as a replacement for the final LABEL dataset.

## Supporting audit tables

- `docs/source_flag_file_summary.csv`: counts of GEO, REG, and BOTH retrieval-route labels in intermediate preparation files.
- `docs/geo_sourceflag_comparison_summary.csv`: comparison of GEO/BOTH video IDs across intermediate preparation files.
- `docs/geo_retrieval_overlap_with_repo_datasets.csv`: overlap between the GEO retrieval file and current repository datasets.

### Counting note for the final LABEL dataset

`videos_validated.csv` (**final LABEL dataset**) contains **1,899 analysed video records**, and this is the count used in the manuscript and main workflow. The `video_id` field should not be used to reduce this number for reporting the final corpus. A small number of records may be repeated across search queries or may display oddly in spreadsheet software, but these correspond to valid analysed video records and were retained in the paper dataset.
