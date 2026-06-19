# YouTube API retrieval overview

The public repository reproduces the manuscript analyses from curated, de-identified analytical datasets. The full bulk YouTube API retrieval workflow and raw API outputs are not redistributed in this public package.

This choice reflects three practical considerations:

1. YouTube API results are dynamic. Search ranking, metadata, availability, comments, and API behaviour can change after the original collection period.
2. Raw API outputs and direct platform identifiers are not needed to reproduce the manuscript analyses from the frozen analytical corpus.
3. Bulk retrieval scripts can include project-specific batching, quota handling, and collection logic that is better retained in the private project archive rather than released as reusable harvesting code.

For transparency, the manuscript and Supplementary Methods describe the retrieval strategy, including the use of scientific and vernacular search terms, the GEO and REG retrieval modes, publication-date limits, API result limits, post-filtering, manual Iberia-relevance validation, and deduplication. The repository also includes curated species and search-term files in `data/species_input/`, preparation-lineage files in `data/preparation_input/`, and the final analytical corpus in `data/paper_input/`.

A minimal illustrative API example is provided in `optional_youtube_api_example/`. This example shows the structure of a single YouTube Data API request in R, using a placeholder API key and one example query. It is not intended to reproduce the full corpus construction workflow.
