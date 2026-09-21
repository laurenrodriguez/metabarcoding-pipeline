# Multi-marker eDNA metabarcoding workflow

An adaptable workflow for processing and analyzing multi-marker environmental
DNA metabarcoding data. The repository documents the sequence-processing and R
analysis steps used in a study combining COI, 18S rRNA, and vertebrate-targeted
16S rRNA assays.

The workflow covers:

- marker-specific APSCALE processing;
- BLASTn searches and lowest-common-ancestor taxonomic reconciliation;
- control-based contaminant subtraction at the PCR-replicate level;
- PCR-replicate, filter, and sampling-event aggregation;
- marker-specific relative read abundance filtering;
- multi-marker presence-absence integration;
- richness, accumulation, ordination, PERMANOVA, LCBD, indicator-taxon, and
  co-detection network analyses.

This repository is an analysis companion rather than a one-command software
package. File paths, metadata values, control scopes, and manually reviewed
taxonomy must be adapted to each project before use.

## Workflow overview

```text
paired-end FASTQ files
        |
        v
primer handling and APSCALE processing (COI, 18S, and 16S separately)
        |
        v
ESV occurrence tables and representative sequences
        |
        v
BLASTn searches and NCBI lineage retrieval
        |
        v
candidate-hit filtering and LCA assignment
        |
        v
control subtraction and PCR-replicate aggregation
        |
        v
manual taxonomy review and event-level aggregation
        |
        v
marker-specific filtering and multi-marker matrices
        |
        v
community, sampling-effort, indicator, and network analyses
```

## Repository structure

```text
config/      marker thresholds and project-wide settings
data/        metadata and reviewed-taxonomy templates
docs/        run order, input schemas, and methodological notes
hpc/         generic SLURM templates for APSCALE, BLASTn, and COI trimming
R/           reusable helper functions
scripts/     ordered R workflow stages
results/     generated outputs; contents ignored by Git
workflow_template.R
```

## Quick start

1. Clone or download the repository.
2. Create the local input and output directories listed in
   `config/settings.R`.
3. Copy and complete the templates in `data/metadata/`.
4. Adapt the paths and scheduler settings in `hpc/` before running the
   marker-specific preprocessing jobs.
5. Copy `workflow_template.R`, populate the input file paths, and run the R
   scripts in numerical order.
6. Review LCA assignments and save the accepted tables under
   `data/reviewed_taxonomy/` before building final ecological matrices.

Detailed instructions are provided in [docs/RUN_ORDER.md](docs/RUN_ORDER.md).

## Marker-specific identity thresholds

| Marker | Species | Genus | Family | Order |
|---|---:|---:|---:|---:|
| COI | >=97% | >=94% | >=90% | >=85% |
| 16S | >=98% | >=94% | >=90% | not assigned by identity threshold |
| 18S | >=97% | >=92% | >=88% | >=85% |

Candidate hits must also agree taxonomically. A high percentage identity alone
does not guarantee a species-level assignment. Thresholds are stored in
`config/marker_config.csv`.

## Multi-marker integration

Read abundance is calculated and filtered independently within each marker.
Because read proportions are not directly comparable among assays, the default
cross-marker community matrix is presence-absence. The repository retains a
separate marker-level RRA table for marker-specific summaries and plots.

## Required software

- R 4.3 or later
- Cutadapt
- APSCALE
- BLAST+
- A local NCBI nucleotide database or another documented reference database

Required R packages are checked in `scripts/00_packages.R`. The optional online
NCBI lineage-retrieval step additionally requires `metabark` and an NCBI API
key stored locally as `NCBI_API_KEY` in `.Renviron`. No credentials are stored
in this repository.

## Reproducibility and data availability

Raw FASTQ files, BLAST databases, large intermediate tables, manually reviewed
project data, and generated results are intentionally excluded from Git. Public
data accessions and the associated manuscript can be added when available.

Before creating a release, record package versions with `renv` or save the
output of `sessionInfo()`.

## License

Code is released under the [MIT License](LICENSE).
