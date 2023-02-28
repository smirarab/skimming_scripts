#!/bin/bash
#SBATCH --job-name="RESPECT"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH -o respect_o_%j
#SBATCH -e respect_e_%j
#SBATCH -t 74:00:00
#SBATCH -A miragrp
#SBATCH --export=ALL
#SBATCH --mem=120G

#source ${HOME}/.bashrc
#source ${HOME}/anaconda3/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"

CONDAENV=GSkim

conda activate $CONDAENV
x=$1
input=`pwd`/library/$x/

tmp=`mktemp -d`
pushd $tmp

ln -s $input/$x.hist .

echo "Input	read_length
$x.hist	$(grep read_length $input/$x.dat |cut -f2)" >info.txt

respect --debug -N 20 -I info.txt -i $x.hist

popd 
cp $tmp/estimated-parameters.txt  `pwd`/library/$x/$x.respect-parameters.txt
cp $tmp/estimated-spectra.txt `pwd`/library/$x/$x.respect-spectra.txt


