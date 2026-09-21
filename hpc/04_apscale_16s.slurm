#!/usr/bin/env bash
#SBATCH --job-name=apscale_16s
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=apscale_16s_%j.out
#SBATCH --error=apscale_16s_%j.err

set -euo pipefail
source "${CONDA_SH:-/path/to/conda.sh}"
conda activate apscale
project_dir="/path/to/16s_apscale_project"
cd "$project_dir"
apscale --run_apscale
