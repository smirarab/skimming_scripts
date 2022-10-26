#!/bin/bash
#SBATCH --job-name="BBMAP"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o calab-jobs_out_%j
#SBATCH -e calab-jobs_err_%j
#SBATCH -t 8:00:00
#SBATCH --mem 18GB
#SBATCH -A miragrp


A=/mirarablab_data/skimming/minderoo/fish_wgs/fish_wgs_not_assembly/scratch/pawsey0390/pbayer/fish_wgs/210812_VH00640_3_AAAH3H7HV/Analysis/1/Data/fastq/
A=/mirarablab_data/skimming/minderoo/fish_wgs/fish_wgs_not_assembly/scratch/pawsey0390/pbayer/fish_wgs/210815_VH00640_4_AAAH3HHHV/Analysis/1/Data/fastq

x=N1142_GreyReefShark_S1
x=N1142_GreyReefShark_S1
x=M254_TigerShark_S2

t=tmp.3knybfVlq3

$HOME/workspace/skimming_scripts/bbmap_pipeline.sh $A/${x}_R1_001.fastq.gz $A/${x}_R2_001.fastq.gz ${x}_merged_001.fastq . $t 1>>log_$x.txt 2>&1
