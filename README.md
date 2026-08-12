# Multi-marker eDNA metabarcoding workflow

Reproducible R workflow for COI, 16S, and 18S eDNA metabarcoding, including
BLAST/LCA taxonomic assignment, control-based decontamination, positive-PCR-
replicate averaging, sampling-event aggregation, multi-marker integration,
biodiversity analyses, and ecological network inference.

## Workflow

1. Demultiplex plate-level reads into tagged PCR replicate/sample combinations
   with Cutadapt.
2. Process COI, 16S, and 18S independently with APSCALE.
3. Retrieve NCBI lineages for deduplicated BLAST accessions with `metabark`.
4. Retain candidate hits using marker-specific percentage-identity thresholds
   and resolve them by lowest common ancestor (LCA).
5. Subtract ESV reads detected in PCR, extraction, and field controls from the
   corresponding affected PCR replicates.
6. Average non-zero read counts across positive PCR replicates within each
   environmental filter.
7. Collapse ESVs with the same marker-specific taxonomic assignment by summing
   their reads.
8. Remove obvious non-environmental labels and retain taxa supported by at
   least 10 total reads or detection in at least two filters.
9. Sum paired filters associated with the same ecological sampling event.
10. Remove the event-specific target whale taxon.
11. Calculate within-marker event RRA, remove taxa below 1%, and renormalize.
12. Sum overlapping taxonomic groups across markers and renormalize within each
    event.
13. Run richness, paired filter-versus-event, accumulation, rarefaction, NMDS, PERMANOVA,
    dispersion, LCBD, indicator-taxon, and co-detection network analyses.

## Marker-specific identity thresholds

| Marker | Species | Genus | Family | Order |
|---|---:|---:|---:|---:|
| COI | ≥97% | 94–96.9% | 90–93.9% | 85–89.9% |
| 16S | ≥98% | 94–97.9% | 90–93.9% | higher level below 90% |
| 18S | ≥97% | 92–96.9% | 88–91.9% | 85–87.9% |

Thresholds are stored in `config/marker_config.csv` and applied before LCA
resolution. Candidate hits within 99% of the best bit score are retained by
default; this value is recorded in `config/settings.R`.

## Repository structure

```text
config/      marker thresholds and global settings
R/           reusable workflow functions
scripts/     ordered analysis stages
data/        metadata templates and reviewed-taxonomy instructions
results/     generated tables and figures (ignored by Git)
```

## Required R packages

The workflow explicitly uses `metabark`, `vegan`, `indicspecies`, `iNEXT`,
`adespatial`, `igraph`, `ggraph`, `Hmisc`, `tidyverse`, `readxl`, and
`openxlsx`. Package availability is checked by `scripts/00_packages.R`.
Installation is intentionally not performed inside analysis scripts.

## Metadata

Use `data/metadata/sample_metadata_template.csv` as the minimum schema. Each PCR
replicate must map to a filter, PCR plate, extraction batch, field-control
interval, and ecological event. Controls use `sample_type` values
`pcr_control`, `extraction_control`, or `field_control`.

Use `data/metadata/target_taxa_template.csv` to identify the whale taxon removed
from each event.

## NCBI API key

No API key is included. Store it locally in `.Renviron`:

```text
NCBI_API_KEY=your_key_here
```

`.Renviron` is excluded by `.gitignore`.

## Reproducibility

Run scripts from the repository root in numerical order. Manual taxonomic and
ecological review tables should be versioned as explicit inputs. Record package
versions with `renv` or save `sessionInfo()` before release.

Raw FASTQ files, BLAST databases, intermediate files, and generated results are
excluded from Git. Deposit raw reads and supporting data in appropriate public
repositories and link those records here.
