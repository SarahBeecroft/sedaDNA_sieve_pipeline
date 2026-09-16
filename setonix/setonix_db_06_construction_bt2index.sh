#!/bin/bash -l
#SBATCH --job-name=constructiondb06_eukmaster_bt2index
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --cpus-per-task=16
#SBATCH --mem=96G
#SBATCH --time=24:00:00
#SBATCH --partition=work
## BEGIN SCRIPT
set -euo pipefail

module load bowtie2/2.4.5--py36hd4290be_0

#
echo "========== ENV =========="
date
echo "Host: $(hostname)"
echo "JobID: ${SLURM_JOB_ID:-unset}"
echo "Workdir at submit: ${SLURM_SUBMIT_DIR:-unset}"

# ----- paths ----
number="Plants_Algae_Other"
#part="forwhenI split some indexes into several part"
base_dir=${MYSCRATCH}/Databases/2026_SO_RefGen_Chordataheavy_curated/db_part_${number}
cd "$base_dir"

ref_in=all_euks_${number}.fna
index_base=index_part_${number}

[[ -s "$ref_in" ]] || { echo "ERROR: missing $ref_in"; exit 1; }


# --- running index ---
# Most basic option for speedup is enabling multithreading with --threads. 
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 bowtie2-build -p 8 $ref_in $index_base

# Potentially useful options for large databases include --noauto, --bmaxdivn, and --dcv.
#The --noauto option disables automatic parameter tuning, which can be slow for large databases. The --bmaxdivn and --dcv options are advanced parameters that can help with large databases, but they should be used with caution and understanding of their effects.

#srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 \
#    bowtie2-build --threads $SLURM_CPUS_PER_TASK --noauto \
#  --bmaxdivn 4 --dcv 256 "$ref_in" "$index_base"

## Additional option for speedup is to copy the references to the local node storage (if available) before running bowtie2-build. This can reduce I/O overhead and improve performance. However, this requires sufficient local storage space and may not be feasible for very large databases.

## END OF SCRIPT