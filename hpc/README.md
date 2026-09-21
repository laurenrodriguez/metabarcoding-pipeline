# HPC templates

These files document the marker-specific preprocessing used before the R
workflow. They are templates: cluster modules, conda activation, paths,
resources, APSCALE project configuration, and BLAST database locations must be
adapted locally.

The COI cutadapt script handles the two-forward-primer design before APSCALE.
The linked-adapter sequences reflect the study assay and should not be reused
for another primer system without verification.

Example BLAST submission:

```bash
sbatch --export=ALL,QUERY_FASTA=/path/esvs.fasta,BLAST_DB=/path/nt,BLAST_OUT=/path/blast.tsv,MIN_IDENTITY=80 hpc/05_blast_esvs.slurm
```
