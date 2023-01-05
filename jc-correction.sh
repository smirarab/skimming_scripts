#!/bin/bash

dist=${1:-ref-dist-mat.txt}  

cat $dist  |awk 'BEGIN{OFS="\t";} (NR>1) {for(i=2;i<=NF;i++){$i=-3/4*log(1-4/3*$i)}; print $0} (NR==1) $0'
