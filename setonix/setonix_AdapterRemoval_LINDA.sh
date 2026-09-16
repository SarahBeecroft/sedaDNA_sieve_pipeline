#!/bin/bash -l
#SBATCH --job-name=AdapterRemoval_SWAIS2C
# #SBATCH --mail-user=linda.armbrecht@utas.edu.au
# Send mail for (a)borted, (b)eginning and (e)nd job
# #SBATCH --mail-type=BEGIN,END,FAIL
# Select 2 nodes with 28 cpus per node
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=48
# Allow the job to run for up to 24 hours
#SBATCH --time=24:00:00
# force the job to a specific queue
#### Slurm partition can be selected with --partition if required by the project.

## BEGIN SCRIPT
cd ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/

date # Print the current time and date to standard output (so you can see when the job started)
# This is assuming you will make a conda environment called "adapterremoval" with the required packages installed. If you have a different environment name, change it below.
conda_env="adapterremoval"
conda_activate="${CONDA_EXE%conda}activate"
source $conda_activate $conda_env || true

#module load rosalind adapterremoval komplexity bbtools megan
#module load java/jdk-18.0.2
#Not sure if this is the equivlent module or not 
module load openjdk/17.0.8.1_1
module load fastqc/0.11.9--hdfd78af_1 

fastqc *fastq.gz
multiqc *fastqc*q

#if AVITI: include --qualitymax 60
AdapterRemoval --barcode-list /u/lindaa3/Scratch/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/barcodes_SWAIS2C.txt --adapter-list /u/lindaa3/Scratch/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/adapter_list.txt --file1 /u/lindaa3/Scratch/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R1.fastq.gz --file2 /u/lindaa3/Scratch/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R2.fastq.gz --basename IMAS  --collapse --trimns --trimqualities --barcode-mm 1 --minlength 25 --threads 2

#fastqc multiqc
cd ${MYSCRATCH}/SED25SeqPool2_KCCGNovaSeq_SWAIS2C/
fastqc *collapsed
multiqc *fastqc*

date

#END OF SCRIPT
