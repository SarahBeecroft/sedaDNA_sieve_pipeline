# sedaDNA Sieve Pipeline

A comprehensive bioinformatics pipeline for processing ancient sedimentary DNA (sedaDNA) sequencing data. This pipeline performs quality control, adapter trimming, demultiplexing, read filtering, and taxonomic classification of sedimentary DNA samples.

## Overview

The **sedaDNA Sieve Pipeline** is designed to process high-throughput sequencing data from ancient sedimentary samples, with a focus on:

- **Quality Control (QC)**: FastQC/MultiQC-based assessment of raw and processed reads
- **Adapter Removal & Demultiplexing**: Using AdapterRemoval for barcode-based sample separation
- **Read Complexity Filtering**: Removing low-complexity reads using Komplexity
- **Deduplication**: Identifying and removing PCR duplicates (BBTools)
- **Taxonomic Classification**: Kraken2-based classification using GTDB reference database
- **Metagenomic Binning & Analysis**: MALT indexing and downstream analysis

## Repository Structure

```
sedaDNA_sieve_pipeline/
├── 01_rosalind_AdapterRemoval_demux_trim_collapse_qc.sh   # Main adapter removal & QC step
├── 03_rosalind_komplexity_dedupe_recursive.sh              # Complexity filtering & deduplication
├── 04_rosalind_renaming_after_preprocessing.sh             # File renaming utilities
├── 05_k2_*.sh                                              # Kraken2 classification variants
├── 06_malt_index_build_Emilyscript.sh                      # MALT database indexing
├── bwa_indexing_scriptfromEmily.sh                         # BWA index construction
├── make_project_subdirs.sh                                 # Directory structure setup
├── k2_gtdb_test.sh                                         # Kraken2 testing scripts
├── MSA_prank_test.sh                                       # Multiple sequence alignment
├── IMAS_Nextflow_2025.config                               # Nextflow configuration
├── Figures/                                                # Output figures & visualizations
├── results/                                                # Pipeline output directory
└── Claude_debugging/                                       # Debugging & development notes
```

## Quick Start Guide

### Prerequisites

- **HPC Environment**: Scripts are designed for PBS/Torque job scheduler (Rosalind cluster)
- **Required Software**:
  - AdapterRemoval (adapter trimming)
  - Kraken2 (taxonomic classification)
  - GTDB reference database (Kraken2 format)
  - Komplexity (complexity filtering)
  - BBTools (deduplication)
  - FastQC/MultiQC (quality control)
  - BWA (reference mapping)
  - MALT (metagenomic alignment)

- **Modules**: Use `module load` commands as specified in scripts

### Step 1: Set Up Project Directory Structure

```bash
# Navigate to your project root directory
cd /path/to/projects

# Create standard subdirectories for each project
./make_project_subdirs.sh /path/to/projects
```

This creates:
- `AdapterRemoval_demux_nocollapse/` & `AdapterRemoval_demux_collapse/`
- `QC_files/` (raw, demux, post-processing)
- `Komplexity_dedupe_for_fastq_renaming/`

### Step 2: Prepare Input Files

Place your raw sequencing files in the project directory:
- `*_R1.fastq.gz` and `*_R2.fastq.gz` (paired-end reads)
- `barcodes_*.txt` (barcode definitions)
- `adapter_list.txt` (adapter sequences)

Example input files:
```
HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R1.fastq.gz
HCCLNDSXF_1_250717_FS28687269_Other_GCAAGAT-AGATCTC_R_250715_LINARM_INDEXLIBNOVASEQ_P001_R2.fastq.gz
```

### Step 3: Run Adapter Removal, Demultiplexing & QC

```bash
# Submit the main preprocessing job
qsub rosalind_01_AdapterRemoval_demux_trim_collapse_qc.sh
```

**What this does:**
- Runs initial FastQC on raw reads
- Demultiplexes samples by barcode (allows 1 mismatch)
- Trims adapter sequences
- Collapses overlapping paired-end reads
- Runs post-QC on trimmed/collapsed reads
- Outputs per-sample FASTQ files with QC reports

**Configuration in script:**
- `THREADS=28` (adjust for your node)
- `BASE_DIR`: Working directory path
- `BARCODE_LIST`: Barcode file
- `ADAPTER_LIST`: Adapter sequences file
- `--minlength 25`: Minimum read length post-trimming

### Step 4: Filter Low-Complexity Reads & Deduplicate

```bash
qsub rosalind_03_komplexity_dedupe_recursive.sh
```

**What this does:**
- Filters out low-complexity reads using Komplexity
- Removes PCR duplicates with BBTools dedup
- Processes all samples in subdirectories recursively

### Step 5: Rename Files & Prepare for Classification

```bash
qsub rosalind_04_renaming_after_preprocessing.sh
```

Standardizes output filenames for downstream analysis.

### Step 6: Taxonomic Classification with Kraken2

```bash
# Load conda environment with Kraken2
module load Anaconda3/2024.02-1
source activate /path/to/kraken2_env

# Single sample test run
qsub rosalind_05_k2_filtering_per_samplebasename.sh
```

**Kraken2 Options** (edit script as needed):
- `DB_DIR`: Path to GTDB Kraken2 database (e.g., `/data/imas_projects/ancient/share/Databases/GTDBr226_k2_ncbitaxonomy`)
- `THREADS=28`: Parallel processing threads
- `CONFIDENCE=0.0`: Classification confidence threshold (increase to 0.1-0.2 for stricter calls)

**Outputs:**
- `k2_classification/`: Classification results
- `k2_hits/`: Classified reads
- `for_competitive/`: Unclassified reads

### Optional: MALT Alignment & Binning

For metagenomic assembly and binning:

```bash
qsub 06_malt_index_build_Emilyscript.sh
```

## Pipeline Statistics

**Language Composition:**
- Python: 64.5%
- Shell/Bash: 33.3%
- R: 2.2%

## Key Scripts by Function

| Step | Script | Purpose |
|------|--------|---------|
| 0 | `make_project_subdirs.sh` | Initialize project folder structure |
| 1 | `rosalind_01_AdapterRemoval_demux_trim_collapse_qc.sh` | Adapter removal & demultiplexing |
| 2 | `rosalind_03_komplexity_dedupe_recursive.sh` | Complexity filtering & deduplication |
| 3 | `rosalind_04_renaming_after_preprocessing.sh` | Standardize filenames |
| 4 | `rosalind_05_k2_*.sh` | Kraken2 taxonomic classification (various configurations) |
| 5 | `06_malt_index_build_Emilyscript.sh` | MALT metagenomic alignment |

## Advanced Configuration

### Kraken2 Variants
The repository includes multiple Kraken2 scripts for different scenarios:
- `rosalind_05_k2_filtering_per_samplebasename.sh` - Per-sample classification
- `rosalind_05_k2_ram_preload_allsamples.sh` - RAM preload for all samples (faster)
- `rosalind_05_throttle_kraken2_lean_for_running.sh` - Resource-constrained version
- `rosalind_05_updatedthrottle_kraken2_benchmarking.sh` - Performance testing

### Database Setup
Pre-built GTDB Kraken2 database available at:
```
/data/imas_projects/ancient/share/Databases/GTDBr226_k2_ncbitaxonomy
```

To build your own:
```bash
qsub kraken_k2build.sh
```

## Quality Control

All QC outputs are organized in the `QC_files/` directory:
- **rawQCfiles/**: FastQC reports from raw reads
- **demux_trim_collapse_QCfiles/**: Reports post-trimming
- **post_komplexity_dedupe/**: Reports post-filtering

View MultiQC reports:
```bash
cd QC_files/
multiqc .
```

## Output Organization

```
project_dir/
├── AdapterRemoval_demux_collapse/      # Trimmed, collapsed reads
├── Komplexity_dedupe_for_fastq_renaming/
├── k2_classification/                  # Kraken2 classification files
├── k2_hits/                             # Classified reads
├── for_competitive/                    # Unclassified reads
└── QC_files/                            # All QC reports
```

## Common Parameters to Modify

Edit scripts to customize:

- **Thread count**: `THREADS=28` (match your node's CPU count)
- **Memory requirements**: PBS `-l select=` line
- **Barcode mismatches**: `--barcode-mm 1` (AdapterRemoval)
- **Minimum read length**: `--minlength 25` (AdapterRemoval)
- **Kraken2 confidence**: `CONFIDENCE=0.0` (adjust as needed)
- **Job email**: `#PBS -M your.email@institution.edu`

## Troubleshooting

### Job Submission Issues
```bash
# Check job status
qstat -u $USER

# Cancel a job
qdel <job_id>

# Check logs in PBS output file
cat <script_name>.o<job_id>
```

### Common Errors
- **Module not found**: Run `module avail` to see available modules
- **Database not found**: Verify database path in script
- **Out of memory**: Reduce `THREADS` or request more memory with `-l select=`

## References

- **AdapterRemoval**: Lindgreen et al. (2016)
- **Kraken2**: Wood et al. (2019)
- **GTDB**: Parks et al. (2022)
- **Komplexity**: Renaud et al. (2015)
- **MALT**: Herbig et al. (2016)

## Contributing

This pipeline is actively developed for sedaDNA analysis. Please document new scripts and scripts with clear comments for reproducibility.

## License

Please check the original repository for licensing information: https://github.com/33davis/sedaDNA_sieve_pipeline

---

**Last Updated**: September 2025  
**Maintainer**: Sarah Beecroft
