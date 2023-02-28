#!/bin/bash
#SBATCH --job-name="postskmer"
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=12
#SBATCH -o skmer_o_%j
#SBATCH -e skmer_e_%j
#SBATCH -t 74:00:00
#SBATCH -A miragrp
#SBATCH --export=ALL

SCRIPT_DIR=~/workspace/skimming_scripts/
#$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

matrix=ref-dist-mat.txt
outname=$( basename `pwd` )

# Convert data format
bash $SCRIPT_DIR/tsv_to_phymat.sh $matrix ref-dist-mat.phy

# Run FastME 
$SCRIPT_DIR/fastme-2.1.5/binaries/fastme-2.1.5-linux64  -i ref-dist-mat.phy  -o tree-$outname.tre

echo "m=as.matrix(read.csv('ref-dist-mat.txt',sep='\t',row.names=1)); 
     pdf('fig"-$outname".pdf',width=12,height=9);plot(hclust(as.dist(m))); heatmap(m, scale = 'none');dev.off(); 
     write.table(file='dist-"$outname".txt',format(data.frame(name = row.names(m), m),digits=3),qu=F,sep='\t',row.names = FALSE);"|R --vanilla

grep "" library/*/*.dat|sed -e "s/:/\t/g" -e "s/^library.//" -e "s:/[^/]*.dat\t:\t:"|sort -k2 >  stats-$outname.csv

zip results-$outname.zip tree-$outname.tre stats-$outname.csv fig-$outname.pdf dist-$outname.txt
