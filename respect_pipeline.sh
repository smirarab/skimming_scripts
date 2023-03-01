#!/bin/bash

cov_val=$1
genome=$2
lib_dir=$3
folder=$4
iterations=$5
threads=$6

upper_bound=4.0
set_bound=3.0
ratio_val=1.0

if [ 1 -eq "$(echo "$cov_val < $upper_bound" | bc)" ]
      then
	      echo "Coverage in range"
              echo "Respect running"
              echo "Input	read_length
${genome}_merged.hist	$(grep read_length ${lib_dir}/${genome}_merged/${genome}_merged.dat |cut -f2)" >${folder}/respect/${genome}/info.txt

              respect --debug -N ${iterations} --threads ${threads} -I ${folder}/respect/${genome}/info.txt -i ${lib_dir}/${genome}_merged/${genome}_merged.hist --tmp ${folder}/respect/${genome}/output/tmp -o ${folder}/respect/${genome}/output || true
              echo "Respect done"
              rm ${folder}/respect/${genome}/info.txt
      else
	      ratio_val="$( echo "scale=4; $set_bound / $cov_val" | bc)"
              echo "Coverage not in range, sample to be downsampled by ${ratio_val}"
              seqtk sample ${folder}/bbmap/${genome}_merged.fq $ratio_val> ${folder}/respect/${genome}/downsampled_${genome}_${ratio_val}.fq
              echo "Running respect on downsampled sample"
              respect -i ${folder}/respect/${genome}/downsampled_${genome}_${ratio_val}.fq -N ${iterations} --debug --tmp ${folder}/respect/${genome}/output/tmp -o ${folder}/respect/${genome}/output || true
              echo "Respect done"

fi
