#!/usr/bin/env bash
#SBATCH --job-name=trim_coi
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=24:00:00
#SBATCH --output=trim_coi_%j.out
#SBATCH --error=trim_coi_%j.err

set -euo pipefail

# Adapt environment activation and paths to the local cluster.
source "${CONDA_SH:-/path/to/conda.sh}"
conda activate cutadapt

input_dir="/path/to/coi_fastq"
output_dir="/path/to/coi_fastq_trimmed"
mkdir -p "$output_dir"
cd "$input_dir"

for r1 in *_R1*.fastq.gz; do
  r2="${r1/_R1/_R2}"
  if [[ ! -f "$r2" ]]; then
    echo "Missing R2 mate for $r1" >&2
    continue
  fi
  stem="${r1%.fastq.gz}"
  stem="${stem/_R1/}"

  cutadapt \
    -g "^GGWACWRGWTGRACWITITAYCCYCC...TGRTTYTTYGGICAYCCIGARGTITA;optional" \
    -G "^TAIACYTCIGGRTGICCRAARAAYCA...GGRGGRTAIAIWGTYCAWCYWGTWCC;optional" \
    -g "^GGDACWGGWTGAACWGTWTAYCCHCC...TGRTTYTTYGGICAYCCIGARGTITA;optional" \
    -G "^TAIACYTCIGGRTGICCRAARAAYCA...GGDGGRTAWACWGTTCAWCCWGTHCC;optional" \
    --cores "${SLURM_CPUS_PER_TASK:-1}" \
    -o "$output_dir/${stem}_trimmed_R1.fastq.gz" \
    -p "$output_dir/${stem}_trimmed_R2.fastq.gz" \
    "$r1" "$r2"
done
