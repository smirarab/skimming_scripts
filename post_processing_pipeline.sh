#!/bin/bash

SCRIPT_DIR=$1
ref_dir=$2
direc_name=$3
lib_dir=$4

echo "Post processing starts"

${SCRIPT_DIR}/jc-correction.sh ${ref_dir}/ref-dist-mat.txt > ${ref_dir}/ref-dist-jc.txt

bash ${SCRIPT_DIR}/tsv_to_phymat.sh ${ref_dir}/ref-dist-jc.txt ${ref_dir}/ref-dist-jc.phy

out_name=${direc_name}

${SCRIPT_DIR}/fastme-2.1.5/binaries/fastme-2.1.5-linux64  -i ${ref_dir}/ref-dist-jc.phy  -o ${ref_dir}/tree-${out_name}.tre

echo "m=as.matrix(read.csv('${ref_dir}/ref-dist-jc.txt',sep='\t',row.names=1));
     pdf('${ref_dir}/fig"-${out_name}".pdf',width=12,height=9);plot(hclust(as.dist(m))); heatmap(m, scale = 'none');dev.off();
     write.table(file='${ref_dir}/dist-"${out_name}".txt',format(data.frame(name = row.names(m), m),digits=3),qu=F,sep='\t',row.names = FALSE);"|R --vanilla

grep "" ${lib_dir}/*/*.dat|sed -e "s/:/\t/g" -e "s/^library.//" -e "s:/[^/]*.dat\t:\t:"|sort -k2 > ${ref_dir}/stats-${out_name}.csv

cd ${ref_dir}

zip results-${out_name}.zip tree-${out_name}.tre stats-${out_name}.csv fig-${out_name}.pdf dist-${out_name}.txt
echo "Post processing ends"
