#!/bin/bash -l
#SBATCH --job-name=fastqc_1
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=64
#SBATCH --cpus-per-task=1
#SBATCH --time=24:00:00

## BEGIN SCRIPT
cd ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/

date # Print the current time and date to standard output (so you can see when the job started)
# This is assuming you will make a conda environment called "multiqc" with the required packages installed. If you have a different environment name, change it below.
conda_env="multiqc"
conda_activate="${CONDA_EXE%conda}activate"
source $conda_activate $conda_env || true

module load fastqc/0.11.9--hdfd78af_1 
# adding threads to fastqc means it will process multiple files at once, but each file will still be processed with a single thread.
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 fastqc -t 64 *fastq.gz
multiqc *fastqc*q

date

#END OF SCRIPT
