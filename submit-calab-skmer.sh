#!/bin/bash
#SBATCH --job-name="Skmer"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH -o skmer_o_%j
#SBATCH -e skmer_e_%j
#SBATCH -t 74:00:00
#SBATCH -A miragrp
#SBATCH --export=ALL
#SBATCH --mem=120G

source ${HOME}/.bashrc
source /calab_data/mirarab/home/smirarab/anaconda3/etc/profile.d/conda.sh

conda activate

skmer --debug reference skmerinput -p 2
