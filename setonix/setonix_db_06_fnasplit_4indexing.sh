#!/bin/bash -l
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --job-name=split_Reptiles_byparts
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --time=24:00:00
set -euo pipefail 

#START SCRIPT
conda_env="SeqKit"
conda_activate="${CONDA_EXE%conda}activate"
source $conda_activate $conda_env || true

BASE_DIR=${MYSCRATCH}/Databases/2026_SO_RefGen_Chordataheavy_curated
cd $BASE_DIR
# This approach streams the file directly into seqkit, which should be more efficient 
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 \
    seqkit \
    split2 -s 250000 \
    --out-dir fna_parts/ \
    -O Reptiles_part_ \
    -e .fna \
    db_part_Reptiles/all_euks_Reptiles_clean.fna

date 
# END SCRIPT