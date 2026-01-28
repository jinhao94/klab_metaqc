README: klab_metaqc
Overview

klab_metaqc is a high-performance bioinformatics pipeline designed for the quality control (QC) and host contamination removal of metagenomic sequencing data. Developed by the Key Laboratory of Dairy Biotechnology and Engineering (K-Lab), this tool leverages the Snakemake workflow management system to provide a scalable, reproducible, and efficient processing environment for large-scale datasets.

The pipeline integrates industry-standard tools like fastp for adapter trimming/filtering and bowtie2 for identifying and removing host-specific reads.
Core Features

    Automated Workflow: Uses Snakemake to handle complex dependencies and parallel execution.

    Host Removal: Supports multiple host genomes including Human, Mouse (C57BL/6NJ), Pig, and Sheep.

    Comprehensive Reporting: Generates detailed TSV reports containing raw read counts, trimming statistics, and final clean data metrics.

    Short Read Optimization: Includes a specialized module (shortqc) for sequencing data shorter than 100bp.

    Flexible Deployment: Can be run as a simple shell command with customizable thread and job allocations.

Installation & Requirements

The pipeline requires a Linux environment with Conda installed.
Dependencies

    Snakemake (via Conda environment snakemake)

    fastp (Quality filtering)

    bowtie2 (Host mapping)

    seqkit & csvtk (Statistics and report merging)

Usage Guide
1. Generate Sample List

Before running the QC, generate a compatible sample list from your raw data.
Bash

klab_metaqc list [input_directory] > samples.txt

Sample List Format: The list should be tab-delimited, containing the Sample ID and the paths to R1 and R2 files:
Plaintext

Sample_A    /path/to/A.r1.fq.gz    /path/to/A.r2.fq.gz

2. Run the QC Pipeline (superqc)

The superqc module is the recommended method for standard metagenomic workflows.
Bash

klab_metaqc superqc -s samples.txt -o result_folder -t [host_type] -j [jobs]

Parameters: | Flag | Description | Options | | :--- | :--- | :--- | | -s | Path to the sample list | Required | | -o | Output folder name | Required | | -t | Host type for removal | human, c57mouse, pig, sheep, None | | -j | Number of parallel jobs | Default: 1 (Max: 4) |
Workflow Architecture

The pipeline follows a structured three-step process:

    Read Filtering (fastp): Performs quality trimming (Q>20), poly-G tail trimming, and base correction.

    Host Depletion (bowtie2): Maps reads against the specified host database. Non-concordant (unmapped) reads are kept as "clean data".

    Report Aggregation: Summarizes statistics from fastp and seqkit into a final QC_report.tsv.

Output Files

The results are organized within the specified output folder:

    clean_data.files/: Contains the final .clean.r1.fq.gz and .clean.r2.fq.gz files.

    clean_data_info/: Intermediate logs, fastp HTML/JSON reports, and bowtie2 alignment logs.

    QC_report.tsv: The master summary file containing all quality and quantity metrics for the batch.

Author & Version

    Author: Jinhao (K-Lab)

    Version: Beta 0.1

    Last Update: 2024.04.15 (Added shortqc module)
