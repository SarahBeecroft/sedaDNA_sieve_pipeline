#!/bin/bash -l
#SBATCH --job-name=kraken2_samples_benchmarking_cpu2_memGB20_concurrency_test
#SBATCH --mail-user=emily.davis@utas.edu.au
#SBATCH --mail-type=BEGIN,END,FAIL
# 10 test samples
#SBATCH --array=1-10%2
# Conservative per-sample resources (benchmarkable)
#SBATCH --cpus-per-task=2
#SBATCH --mem=20G
#SBATCH --time=02:00:00
#SBATCH --output=%x-%A_%a.out
#SBATCH --error=%x-%A_%a.out

set -euo pipefail

# environment set up 
module load Anaconda3/2024.02-1
source activate /u/davisee/.conda/envs/kraken2
echo "Conda: $(which conda || echo no_conda)"
echo "Env: ${CONDA_PREFIX:-unset}"
echo "Kraken2: $(which kraken2 || echo missing)"
kraken2 --version || { echo "kraken2 --version failed"; exit 1; }

# variables
DB_DIR="/data/imas_projects/ancient/share/Databases/GTDBr226_k2_ncbitaxonomy"
SAMPLE_DIR="/u/davisee/chapter2_data/collapsed_kxdd_rename_4k2"
THREADS=2
CONFIDENCE=0.0

cd "$SAMPLE_DIR"

# Pick exactly ONE sample for task from array list (subset file already in place)
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
IN="${SAMPLE}.ckdd.fastq.gz"

echo "========== INPUTS =========="
echo "THREADS=$THREADS"
echo "SAMPLE=$SAMPLE"
echo "DB_DIR=$DB_DIR"
echo "JobID=$SLURM_JOB_ID"
echo "Host: $(hostname)"
echo "Start time: $(date)"

# Validate input exists and gzip integrity
ls -l "$IN"
zcat -t "$IN" >/dev/null 2>&1 || { echo "GZIP test FAILED for $IN"; exit 1; }

echo "========== RUN =========="
SECONDS=0

kraken2 \
  --db "$DB_DIR" \
  --memory-mapping \
  --threads "$THREADS" \
  --confidence "$CONFIDENCE" \
  --classified-out   "array_benchmarking/k2_hits/classified-${SAMPLE}-${SLURM_JOB_ID}.fq" \
  --unclassified-out "array_benchmarking/for_competitive/unclassified-${SAMPLE}-${SLURM_JOB_ID}.fq" \
  --report           "array_benchmarking/k2_classification/report-${SAMPLE}-${SLURM_JOB_ID}.txt" \
  --output           "array_benchmarking/k2_classification/classifications-${SAMPLE}-${SLURM_JOB_ID}.txt" \
  "$IN" \
  2> "array_benchmarking/logs/${SAMPLE}-${SLURM_JOB_ID}.log"

RC=$?
ELAPSED=$SECONDS
echo "Kraken2 exit code: $RC"
echo "End time: $(date)"
echo "Elapsed seconds: $ELAPSED"

# ===== Slurm accounting (authoritative usage for scaling) =====
sacct -j "$SLURM_JOB_ID" --format=JobID,State,Elapsed,MaxRSS,TotalCPU --allocations || true

exit $RC
