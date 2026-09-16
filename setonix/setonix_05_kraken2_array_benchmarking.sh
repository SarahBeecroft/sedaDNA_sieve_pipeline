#!/bin/bash -l
#SBATCH --job-name=kraken2_samples_benchmarking_cpu4_mem64GB
#SBATCH --mail-user=emily.davis@utas.edu.au
#SBATCH --mail-type=BEGIN,END,FAIL
# 10 test samples
#SBATCH --array=1-10
# Conservative per-sample resources (benchmarkable)
#SBATCH --cpus-per-task=4
#SBATCH --mem=64G
#SBATCH --time=48:00:00
#SBATCH --output=%x-%A_%a.out
#SBATCH --error=%x-%A_%a.out

set -euo pipefail

module load Anaconda3/2024.02-1
source activate /u/davisee/.conda/envs/kraken2

DB_DIR="/data/imas_projects/ancient/share/Databases/GTDBr226_k2_ncbitaxonomy"
SAMPLE_DIR="/u/davisee/chapter2_data/collapsed_kxdd_rename_4k2"
THREADS=${SLURM_CPUS_PER_TASK}
CONFIDENCE=0.0

cd "$SAMPLE_DIR"

# Pick exactly ONE sample for this task
SAMPLE=$(sed -n "${SLURM_ARRAY_TASK_ID}p" samples.txt)
IN="${SAMPLE}.ckdd.fastq.gz"

mkdir -p logs k2_classification k2_hits for_competitive

echo "Running sample: $SAMPLE"
echo "Threads: $THREADS"
echo "Host: $(hostname)"
echo "Start time: $(date)"

kraken2 \
  --db "$DB_DIR" \
  --threads "$THREADS" \
  --confidence "$CONFIDENCE" \
  --classified-out   "array_benchmarking/k2_hits/classified-${SAMPLE}.fq" \
  --unclassified-out "array_benchmarking/for_competitive/unclassified-${SAMPLE}.fq" \
  --report           "array_benchmarking/k2_classification/report-${SAMPLE}.txt" \
  --output           "array_benchmarking/k2_classification/classifications-${SAMPLE}.txt" \
  "$IN" \
  2> "array_benchmarking/logs/${SAMPLE}.log"

echo "End time: $(date)"