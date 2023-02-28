#!/bin/bash
#SBATCH --job-name="BBMAP"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o calab-jobs_out_%j
#SBATCH -e calab-jobs_err_%j
#SBATCH -t 4:00:00
#SBATCH -A miragrp

x=20231Bbl_11_S4_L001
$HOME/workspace/skimming_scripts/bbmap_pipeline.sh /mirarablab_data/skimming/20231Bbl_N20096/${x}_R1_001.fastq.gz /mirarablab_data/skimming/20231Bbl_N20096/${x}_R2_001.fastq.gz ${x}_merged_001.fastq  1>log_$x.txt 2>&1
