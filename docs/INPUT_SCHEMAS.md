# Input schemas

## BLAST table

The taxonomy script expects a tab-delimited BLAST table containing at least:

```text
qseqid sseqid pident length evalue bitscore
```

`qcovs`, `sacc`, and additional standard BLAST fields may also be supplied.
Taxonomic lineage columns can either be joined in advance or retrieved with the
optional `metabark` helper.

## ESV occurrence table

The occurrence table must contain one `qseqid` column and one numeric read-count
column per PCR replicate. Replicate column names must match `sample_rep_id` in
the metadata table.

## Sample metadata

Required columns are:

- `sample_rep_id`: PCR replicate identifier matching an occurrence-table column;
- `filter_id`: environmental filter or control identifier;
- `event_id`: ecological sampling-event identifier;
- `marker`: COI, 16S, or 18S;
- `sample_type`: environmental, pcr_control, extraction_control, or field_control;
- `pcr_plate`: scope for PCR-control subtraction;
- `extraction_batch`: scope for extraction-control subtraction;
- `field_interval`: scope for field-control subtraction;
- `event_type`: ecological grouping used in downstream analyses;
- `target_taxon`: optional event-associated target removed before community analysis.

## Reviewed taxonomy

Manual review should be stored as data, not encoded as undocumented edits in an
analysis script. See `data/reviewed_taxonomy/README.md`.
