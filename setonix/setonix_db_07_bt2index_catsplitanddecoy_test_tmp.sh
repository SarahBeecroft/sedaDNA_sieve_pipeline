#!/bin/bash -l
#SBATCH --job-name=bt2index_cat_fungiprotist_test
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --cpus-per-task=16
#SBATCH --ntasks=1
#SBATCH --mem=96G
#SBATCH --time=24:00:00
#SBATCH --partition=work

module load bowtie2/2.4.5--py36hd4290be_0

# -------- Variables and directories --------
BASE="${MYSCRATCH}/Databases/2026_SO_RefGen_Chordataheavy_curated"
PART="Fungi_Protists_part_001"
DECOY="${BASE}/prokaryotic_decoy_withHuman.fna"
FNA_DIR="${BASE}/fna_parts"
IDX_DIR="${BASE}/indexes"
LOG_DIR="${BASE}/logs"
TMP_FNA="${MYSCRATCH}/${SLURM_JOB_ID}/${PART}_with_decoy.fna"

mkdir -p "$LOG_DIR" "${MYSCRATCH}/${SLURM_JOB_ID}"
cd "$BASE"
## -------- Trap: cleanup temp file and stop logging loop on any exit --------
#cleanup() {
#    kill "$MEM_LOG_PID" 2>/dev/null || true
#    wait  "$MEM_LOG_PID" 2>/dev/null || true
#    rm -f "$TMP_FNA"
#    rmdir "${MYSCRATCH}/${SLURM_JOB_ID}" 2>/dev/null || true
#    echo "$(date '+%Y-%m-%d %H:%M:%S') bowtie2-build exited" \
#        >> "${LOG_DIR}/${PART}_mem_log.txt"
#}
#trap cleanup EXIT

# -------- Start memory + I/O logging in the background --------
#while true; do
#    TIMESTAMP="$(date '+%Y-%m-%d %H:%M:%S')"
#
#    # --- RAM usage from Slurm ---
#    echo -n "${TIMESTAMP} " >> "${LOG_DIR}/${PART}_mem_log.txt"
#    sstat -j "${SLURM_JOB_ID}.batch" --format=MaxRSS --noheader \
#        >> "${LOG_DIR}/${PART}_mem_log.txt" || true
#
#    # --- Disk I/O pressure (3 snapshots, 2 sec apart, averaged by iostat) ---
#    echo "=== ${TIMESTAMP} ===" >> "${LOG_DIR}/${PART}_io_log.txt"
#    iostat -x 2 3 \
#        | grep -E "^(Device|sd|nvm|xv)" >> "${LOG_DIR}/${PART}_io_log.txt"
#
#     # --- Temp file growth ---
#    echo -n "${TIMESTAMP} tmp_size=" >> "${LOG_DIR}/${PART}_io_log.txt"
#    du -sh "${TMP_FNA}" 2>/dev/null | awk '{print $1}' \
#        >> "${LOG_DIR}/${PART}_io_log.txt"
#
#    # --- Scratch space remaining (shared across all jobs) ---
#    echo -n "${TIMESTAMP} scratch_avail=" >> "${LOG_DIR}/${PART}_io_log.txt"
#    df -h /scratch \
#        | awk 'NR==2 {print $4}' >> "${LOG_DIR}/${PART}_io_log.txt"
#
#    sleep 300
#done &
#MEM_LOG_PID=$!

# -------- Concatenate input into a real file --------
echo "$(date '+%Y-%m-%d %H:%M:%S') Concatenating FASTA files..." \
    >> "${LOG_DIR}/${PART}_mem_log.txt"

cat "${FNA_DIR}/${PART}.fasta.fna" "${DECOY}" > "$TMP_FNA"

# -------- Run the index build --------
echo "$(date '+%Y-%m-%d %H:%M:%S') Starting bowtie2-build..." \
    >> "${LOG_DIR}/${PART}_mem_log.txt"

# Most basic option for speedup is enabling multithreading with --threads. 
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 bowtie2-build -p $SLURM_CPUS_PER_TASK "$TMP_FNA" "${IDX_DIR}/${PART}"