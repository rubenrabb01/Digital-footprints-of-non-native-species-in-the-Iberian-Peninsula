# Preparation-input data

This folder documents the upstream filtering path from raw/API-derived candidate videos to the final paper input. These files are included for transparency and auditability; the manuscript analyses themselves use the curated files in `data/paper_input/`.

## Canonical files

| Label | File | Description |
|---|---|---|
| RAW-REG | `api_regioncode_raw.csv` (**RAW-REG**) | Full raw region-code video pool after deduplication: 16,844 unique videos. This is the raw REG starting point. |
| RAW-REG flagged | `api_regioncode_raw_flagged.csv` (**RAW-REG flagged**) | Same 16,844-video pool with an `is_iberian` flag documenting rows retained or rejected during filtering/labelling. |
| REG post-filtered candidates | `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**) | Clean post-filtered REG candidate dataset after language and Iberian locality filters: 6,935 unique videos. |
| REG-labelled | `api_regioncode_labelled.csv` (**REG-labelled**) | REG videos labelled as Iberia-relevant after filtering and labelling: 1,884 unique videos. |
| GEO anchor / source-flagged GEO | `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**) | Geotag/location-based anchor derived from older source-flagged working files by selecting rows with `source_flag` equal to `GEO` or `BOTH`: 305 unique videos. |
| Final LABEL dataset | `../paper_input/videos_validated.csv` (**final LABEL dataset**) | Final validated video-level dataset used by the manuscript scripts: 1,899 analysed video records. |

## Simplified lineage

```text
api_regioncode_raw.csv (RAW-REG; 16,844 videos)
  -> api_regioncode_postfiltered_candidates.csv (REG post-filtered candidates; 6,935 videos)
  -> api_regioncode_labelled.csv (REG-labelled; 1,884 videos)
  -> data/paper_input/videos_validated.csv (final LABEL dataset; 1,899 analysed video records)

api_geotagged_anchor_sourceflag.csv (GEO anchor / source-flagged GEO; 305 videos)
  -> derived from older source-flagged working files using source_flag == GEO or BOTH
```

The final LABEL dataset contains the REG-labelled videos plus a small set of manually added *Xylocopa pubescens* videos and comment-timing metadata used by the analysis workflow.

## GEO and REG terminology

- **REG** refers to the region-code search path, represented here by `api_regioncode_raw.csv` (**RAW-REG**), `api_regioncode_postfiltered_candidates.csv` (**REG post-filtered candidates**), and `api_regioncode_labelled.csv` (**REG-labelled**).
- **GEO** refers to the geotag/location-based search path. The source-flagged GEO anchor is included as `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**). Across the comparable older source-flagged working files, the same 305 GEO/BOTH video IDs were identified, although the split between `GEO` and `BOTH` changed depending on which REG variant was compared with GEO.
- The file name uses `sourceflag` because this GEO anchor was defined from older working files using the `source_flag` values `GEO` and `BOTH`, rather than from a standalone raw GEO API export.
- Small optional API-test GEO files, if present, are kept under `data/api_test_input/` and should not be interpreted as the historical GEO anchor.

## Relationship between GEO and the current LABEL dataset

The current `data/paper_input/videos_validated.csv` (**final LABEL dataset**) is the analysis-ready dataset. In this audit, 68 of the 305 GEO anchor video IDs overlapped the current final LABEL dataset. Therefore, `api_geotagged_anchor_sourceflag.csv` (**GEO anchor / source-flagged GEO**) documents an upstream/historical source component, not a replacement for the final paper dataset used by the current scripts.

### Counting note for the final LABEL dataset

`videos_validated.csv` (**final LABEL dataset**) contains **1,899 analysed video records**, and this is the count used in the manuscript and main workflow. The `video_id` field should not be used to reduce this number for reporting the final corpus. A small number of records may be repeated across search queries or may display oddly in spreadsheet software (for example as `#¿NOMBRE?` in some older working files or spreadsheet views), but these correspond to valid analysed video records and were retained in the paper dataset.
