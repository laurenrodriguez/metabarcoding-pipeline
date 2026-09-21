#!/usr/bin/env bash
#SBATCH --job-name=apscale_18s
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=48:00:00
#SBATCH --output=apscale_18s_%j.out
#SBATCH --error=apscale_18s_%j.err

set -euo pipefail
source "${CONDA_SH:-/path/to/conda.sh}"
conda activate apscale
project_dir="/path/to/18s_apscale_project"
cd "$project_dir"
apscale --run_apscale
