#!/bin/bash -l
#SBATCH --job-name=QV_postk2_unmatched
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --cpus-per-task=1
#SBATCH --ntasks-per-node=64
#SBATCH --nodes=1
#SBATCH --time=24:00:00
#SBATCH --partition=work
#SBATCH --mem=96G
#SBATCH --nodes=1


# --- Begin script --- #
#establish variables 
home_dir="${MYSCRATCH}/chapter2_data/collapsed_kxdd_rename_4k2/for_competitive_k2_unclassified_fq"
output_dir="${MYSCRATCH}/chapter2_data/collapsed_kxdd_rename_4k2/for_competitive_k2_unclassified_fq/fastqc_multiqc_output"

cd $home_dir
mkdir -p $output_dir


# This is assuming you will make a conda environment called "adapterremoval" with the required packages installed. If you have a different environment name, change it below.
conda_env="multiqc"
conda_activate="${CONDA_EXE%conda}activate"
source $conda_activate $conda_env || true

# Load necessary fastqc modules 
module load fastqc/0.11.9--hdfd78af_1

fastqc -t 64 *.fq -o $output_dir

multiqc *fastqc* -o $output_dir

date

#END OF SCRIPT