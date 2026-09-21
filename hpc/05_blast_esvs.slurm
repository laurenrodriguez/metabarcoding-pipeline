#!/usr/bin/env bash
#SBATCH --job-name=blast_esvs
#SBATCH --cpus-per-task=12
#SBATCH --mem=32G
#SBATCH --time=5-00:00:00
#SBATCH --output=blast_esvs_%j.out
#SBATCH --error=blast_esvs_%j.err

set -euo pipefail
source "${CONDA_SH:-/path/to/conda.sh}"
conda activate blast

# Supply these variables with sbatch --export or edit them locally.
: "${QUERY_FASTA:?Set QUERY_FASTA to the representative ESV FASTA file}"
: "${BLAST_DB:?Set BLAST_DB to the local nucleotide database prefix}"
: "${BLAST_OUT:?Set BLAST_OUT to the output TSV path}"
: "${MIN_IDENTITY:=80}"

blastn \
  -query "$QUERY_FASTA" \
  -db "$BLAST_DB" \
  -outfmt "6 qseqid sseqid sacc pident qcovs length mismatch gapopen qstart qend sstart send evalue bitscore" \
  -evalue 1e-10 \
  -max_target_seqs 50 \
  -perc_identity "$MIN_IDENTITY" \
  -num_threads "${SLURM_CPUS_PER_TASK:-1}" \
  -out "$BLAST_OUT"
