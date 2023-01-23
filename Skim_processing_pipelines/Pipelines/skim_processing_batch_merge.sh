#!/bin/bash

set -e
set -x

out_dir=`pwd`
ref_dir=`pwd`
threads=8
iterations=1000
cores=8

usage="bash skim_processing_batch_merge.sh -h [-x input] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]
Runs nuclear read processing pipeline on a batch of reads split into two mates in reference to a constructed library:
    
    Options:
    -h  show this help text

    Mandatory inputs:
    -x  path to folder containing reads (split reads that need to be merged)
    -g  path to reference library

    Optional inputs:
    -a  path to output directory for bbmap and respect outputs; default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 8
    -f  number of cores for SKMER, default: 8"

while getopts "h::x:a::r::d::f::g:" opts 
do
    case "$opts" in
	h) echo "$usage"; exit;;     
        x) input="$OPTARG";;
	a) out_dir="$OPTARG";;
        r) threads="$OPTARG";;
	d) iterations="$OPTARG";;
	f) cores="$OPTARG";;
	g) lib_dir="$OPTARG";;
        [?]) echo "invalid input param"; exit 1;;
    esac
done

if [ ! "$input" ] || [ ! "$lib_dir" ]; then
  echo "arguments -x, and -g must be provided"; exit 1
fi

f=`ls -d $lib_dir/*`

if [ !"f" ]; then
        echo "kmer_length     31
sketch_size     100000
sketching_seed  42" >$lib_dir/CONFIG
fi

declare -A array

for f in `ls -d ${input}/*`;do

        genome=$(basename -- "$f")
        genome="${genome%_*}"
        
        key=$genome
        value=$f
        array[${key}]="${array[${key}]}${array[${key}]:+,}${value}"

done

mkdir -p ${out_dir}/skim_processing_batch_merge/bbmap
mkdir -p ${out_dir}/skim_processing_batch_merge/respect/{tmp,output}

source conda_source.sh

for key in "${!array[@]}"; do
	
	genome=$key
        genome_value=${array[$key]}
        input_1="${genome_value%,*}"
        input_2="${genome_value#*,}"
	
	cd ${out_dir}/pipeline_r2/bbmap
	
	echo "BBMap cleanup pipeline starts"
 
 	${ref_dir}/bbmap_pipeline.sh ${input_1} ${input_2} ${genome}_merged.fq
 	echo "BBMap cleanup pipeline ends"
 
 	cd ${ref_dir}
	
	echo "Skmer query running"
	skmer --debug query -a -p ${cores} ${out_dir}/skim_processing_batch_merge/bbmap/${genome}_merged.fq ${lib_dir}
	rm dist-${genome}_merged.txt
	echo "Skmer query done"
	
	cov_val=$(grep coverage ${lib_dir}/${genome}_merged/${genome}_merged.dat |cut -f2)

	lower_bound=2.0
	upper_bound=4.0
	set_bound=3.0
	ratio_val=1.0

	if [ 1 -eq "$(echo "$lower_bound < $cov_val" | bc)" ] && [ 1 -eq "$(echo "$cov_val < $upper_bound" | bc)" ]
	then
        	echo "Coverage in range"
        	echo "Respect running"
        	echo "Input     read_length
        	${genome}_merged.hist $(grep read_length ${lib_dir}/${genome}_merged/${genome}_merged.dat |cut -f2)" >${out_dir}/skim_processing_batch_merge/respect/info.txt

        	respect --debug -N ${iterations} --threads ${threads} -I ${out_dir}/skim_processing_batch_merge/respect/info.txt -i ${lib_dir}/${genome}_merged/${genome}_merged.hist --tmp ${out_dir}/skim_processing_batch_merge/respect/tmp -o ${out_dir}/skim_processing_batch_merge/respect/output
        	echo "Respect done"
		rm ${out_dir}/skim_processing_batch_merge/respect/info.txt
	else
        	ratio_val="$( echo "scale=4; $set_bound / $cov_val" | bc)"
        	echo "Coverage not in range, sample to be downsampled by ${ratio_val}"
        	seqtk sample ${out_dir}/skim_processing_batch_merge/bbmap/${genome}_merged.fq $ratio_val> ${out_dir}/skim_processing_batch_merge/respect/downsampled_${genome}_${ratio_val}.fq
        	echo "Running respect on downsampled sample"
        	respect -i ${out_dir}/skim_processing_batch_merge/respect/downsampled_${genome}_${ratio_val}.fq -N 200 --debug --tmp ${out_dir}/skim_processing_batch_merge/respect/tmp -o ${out_dir}/skim_processing_batch_merge/respect/output
        	echo "Respect done"       

	fi
		
done

echo "Skmer distance running"
skmer distance ${lib_dir}
echo "Skmer distance done"

echo "Post processing starts"

${ref_dir}/jc-correction.sh ${ref_dir}/ref-dist-mat.txt > ${ref_dir}/ref-dist-jc.txt

bash ${ref_dir}/tsv_to_phymat.sh ${ref_dir}/ref-dist-jc.txt ${ref_dir}/ref-dist-jc.phy

out_name=$(basename -- "$ref_dir")
${ref_dir}/fastme-2.1.5/binaries/fastme-2.1.5-linux64  -i ${ref_dir}/ref-dist-jc.phy  -o ${ref_dir}/tree-${out_name}.tre

echo "m=as.matrix(read.csv('${ref_dir}/ref-dist-jc.txt',sep='\t',row.names=1));
     pdf('${ref_dir}/fig"-${out_name}".pdf',width=12,height=9);plot(hclust(as.dist(m))); heatmap(m, scale = 'none');dev.off();
     write.table(file='${ref_dir}/dist-"${out_name}".txt',format(data.frame(name = row.names(m), m),digits=3),qu=F,sep='\t',row.names = FALSE);"|R --vanilla

grep "" ${lib_dir}/*/*.dat|sed -e "s/:/\t/g" -e "s/^library.//" -e "s:/[^/]*.dat\t:\t:"|sort -k2 > ${ref_dir}/stats-${out_name}.csv

cd ${ref_dir}

zip results-${out_name}.zip tree-${out_name}.tre stats-${out_name}.csv fig-${out_name}.pdf dist-${out_name}.txt
echo "Post processing ends"

conda deactivate
