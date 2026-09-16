#!/bin/bash -l
#SBATCH --job-name=kraken2_array
#SBATCH --mail-user=emily.davis@utas.edu.au
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --array=1-82
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=02:00:00
#SBATCH --output=%x-%A_%a.out
#SBATCH --error=%x-%A_%a.out

set -eu

# ---- User settings ----
MAX_CONCURRENT=2
DB_DIR="/data/imas_projects/ancient/share/Databases/GTDBr226_k2_ncbitaxonomy"
SAMPLE_DIR="/u/davisee/chapter2_data/collapsed_kxdd_rename_4k2"
SAMPLES_LIST="${SAMPLE_DIR}/samples.txt"
LOCKDIR="${SAMPLE_DIR}/array_locks"
THREADS=2
CONFIDENCE=0.0

# ---- Environment ----
module load Anaconda3/2024.02-1
source activate /u/davisee/.conda/envs/kraken2

mkdir -p "$LOCKDIR"
cd "$SAMPLE_DIR"

# ---- Get sample ----
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" "$SAMPLES_LIST")
IN="${SAMPLE}.ckdd.fastq.gz"

echo "Running sample: $SAMPLE   Job: $SLURM_JOB_ID   Index: $SLURM_ARRAY_TASK_ID"

# ---- Concurrency limiter ----
LOCKFILE="${LOCKDIR}/${SLURM_JOB_ID}.${SLURM_ARRAY_TASK_ID}.lock"
trap 'rm -f "$LOCKFILE"' EXIT

while true; do
    current=$(find "$LOCKDIR" -type f -name '*.lock' | wc -l)
    if [ "$current" -lt "$MAX_CONCURRENT" ]; then
        ( set -o noclobber; : > "$LOCKFILE" ) 2>/dev/null && break
    fi
    sleep 10
done

# ---- Run Kraken2 ----
OUT_CLASS="classified-${SAMPLE}-${SLURM_JOB_ID}.fq"
OUT_UNCLASS="unclassified-${SAMPLE}-${SLURM_JOB_ID}.fq"
OUT_REPORT="report-${SAMPLE}-${SLURM_JOB_ID}.txt"
OUT_OUTPUT="classifications-${SAMPLE}-${SLURM_JOB_ID}.txt"
LOGFILE="${SAMPLE}-${SLURM_JOB_ID}.log"

set +e
kraken2 \
  --db "$DB_DIR" \
  --memory-mapping \
  --threads "$THREADS" \
  --confidence "$CONFIDENCE" \
  --classified-out "$OUT_CLASS" \
  --unclassified-out "$OUT_UNCLASS" \
  --report "$OUT_REPORT" \
  --output "$OUT_OUTPUT" \
  "$IN" 2> "$LOGFILE"
RC=$?
set -e

echo "Kraken2 finished for $SAMPLE with exit code $RC"
exit $RC
