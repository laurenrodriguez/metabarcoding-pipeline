# Running the workflow

The repository separates computationally intensive preprocessing from the R
workflow used for taxonomic reconciliation and ecological analysis.

## 1. Prepare metadata

Copy the templates in `data/metadata/`, remove the example rows, and add the
project records. Every PCR-replicate column in an APSCALE occurrence table must
have one matching `sample_rep_id` row.

## 2. Process sequence data by marker

Adapt the scripts in `hpc/` to the local cluster, conda environments, file
layout, and BLAST database. COI is trimmed before APSCALE because two forward
primers were used. The 18S and 16S templates run APSCALE directly.

Expected outputs per marker are an ESV occurrence table and representative ESV
FASTA file. The FASTA files are searched with BLASTn using the full tabular
output needed for LCA reconciliation.

## 3. Assign taxonomy

Run `run_taxonomy()` from `scripts/01_taxonomic_assignment.R` once per marker.
The script filters near-best candidate hits, retrieves NCBI lineages through
`metabark`, applies marker-specific identity ceilings, and assigns the most
specific rank supported by candidate agreement.

Do not proceed directly from automated output to ecological interpretation.
Review assignments and save the accepted, documented tables in
`data/reviewed_taxonomy/`.

## 4. Remove control-associated reads

Run `process_marker_replicates()` separately for COI, 18S, and 16S. Read
subtraction is applied at the PCR-replicate level according to PCR plate,
extraction batch, and field-control interval. When several controls of the same
type contain an ESV, the maximum relevant control count is subtracted once.
Counts are bounded at zero.

Non-zero PCR-replicate counts are then averaged within each filter. This
matches the study workflow; projects using a different replicate-consensus rule
should edit and document that decision.

## 5. Build event-level matrices

`build_event_dataset()` collapses ESVs sharing an accepted taxonomic label,
applies the documented support filter, sums filters belonging to the same
event, optionally removes the event-associated target taxon, calculates
marker-specific RRA, and applies the marker-level abundance threshold.

The default cross-marker matrix is presence-absence because RRA values from
different assays are not assumed to be quantitatively equivalent.

## 6. Run ecological analyses

`run_statistical_analyses()` produces richness comparisons, NMDS, PERMANOVA,
dispersion tests, LCBD values, indicator-taxon results, and a co-detection
network. `run_sampling_effort()` produces accumulation, iNEXT, paired-filter,
and filter-similarity outputs.

Co-detection edges are statistical associations and must not be interpreted as
demonstrated trophic interactions.

## 7. Archive outputs

Save final figures and tables under `results/`, record `sessionInfo()`, create a
versioned GitHub release, and link raw reads and large supporting datasets from
their permanent repositories.
