# YouTube API retrieval overview

The manuscript analyses are reproduced from the curated analytical datasets provided in `data/paper_input/`. The YouTube Data API retrieval strategy is described in the manuscript and Supplementary Methods, including the scientific and vernacular search terms, GEO and REG retrieval modes, publication-date limits, API result limits, post-filtering, manual Iberia-relevance validation, and deduplication.

YouTube search results, metadata, comments, availability, and ranking can change over time. For this reason, rerunning API searches may not reproduce the exact manuscript corpus. The repository therefore provides the frozen analytical corpus, supporting species and search-term files, preparation-lineage files, validation files, scripts, and outputs used for the revised manuscript.

A minimal illustrative API example is provided in `optional_youtube_api_example/`. This example shows the structure of a single YouTube Data API request in R using an example query and an API key stored in the `YOUTUBE_API_KEY` environment variable. It is included only to illustrate the request structure; the manuscript analyses are reproduced from the curated analytical datasets.
