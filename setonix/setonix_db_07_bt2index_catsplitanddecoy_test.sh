#!/bin/bash -l
#SBATCH --job-name=rosalind_bt2index_cat_fungiprotist_test
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --mem=96G
#SBATCH --time=24:00:00

set -euo pipefail

module load bowtie2/2.4.5--py36hd4290be_0

# -------- Variables and directories --------
#basic script with variables to add
    #name="Fungi_Protists"
    #number=1:7
    #PART_FNA=fna_parts/${name}_part${number}.fna
    #DECOY_FNA=prokaryotic_decoy.fna 
    #INDEX_OUT=indexes/${name}_part${number}
BASE="${MYSCRATCH}/Databases/2026_SO_RefGen_Chordataheavy_curated"
PART="Fungi_Protists_part_001"
DECOY="${BASE}/prokaryotic_decoy_withHuman.fna"
FNA_DIR="${BASE}/fna_parts"
IDX_DIR="${BASE}/indexes"
LOG_DIR="${BASE}/logs"

mkdir -p  $LOG_DIR
cd $BASE

## -------- Start memory logging in the background --------
#while true; do
#    echo -n "$(date '+%Y-%m-%d %H:%M:%S') " >> "${LOG_DIR}/${PART}_mem_log.txt"
#    sstat -j "${SLURM_JOB_ID}.batch" --format=MaxRSS --noheader \
#        >> "${LOG_DIR}/${PART}_mem_log.txt" || true
#    sleep 300
#done &
#MEM_LOG_PID=$!   # capture the loop's PID so we can stop it later
#
# -------- Run the index build --------
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 bowtie2-build -p $SLURM_CPUS_PER_TASK \
    <(cat "${FNA_DIR}/${PART}.fasta.fna" "${DECOY}") \
    "${IDX_DIR}/${PART}"

BT2_EXIT=$?   # save bowtie2 exit code before anything else runs

## -------- Stop the logging loop --------
#kill "$MEM_LOG_PID" 2>/dev/null
#wait  "$MEM_LOG_PID" 2>/dev/null   # reap the background process cleanly

echo "bowtie2-build finished with exit code ${BT2_EXIT}" \
    >> "${LOG_DIR}/${PART}_mem_log.txt"

exit "$BT2_EXIT"

#end of script 
