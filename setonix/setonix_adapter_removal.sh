#!/bin/bash -l
#SBATCH --job-name=AdapterRemoval_SWAIS2C
# #SBATCH --mail-user=
# #SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=50G
#SBATCH --time=24:00:00

## BEGIN SCRIPT
cd ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/

date # Print the current time and date to standard output (so you can see when the job started)
# This is assuming you will make a conda environment called "adapterremoval" with the required packages installed. If you have a different environment name, change it below.
conda_env="adapterremoval"
conda_activate="${CONDA_EXE%conda}activate"
source $conda_activate $conda_env || true

#if AVITI: include --qualitymax 60
# V2 doesn't scale above 4 threads, consider moving to V3
srun -c $SLURM_CPUS_PER_TASK -N 1 -n 1 \
    AdapterRemoval \
    --barcode-list ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/barcodes_SWAIS2C.txt \
    --adapter-list ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/adapter_list.txt \
    --file1 ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R1.fastq.gz \
    --file2 ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R2.fastq.gz \
    --basename IMAS  \
    --collapse \
    --trimns \
    --trimqualities \
    --barcode-mm 1 \
    --minlength 25 \
    --threads 4

date

#END OF SCRIPT
