#!/bin/bash

cov_val=$1
genome=$2
lib_dir=$3
folder=$4
iterations=$5
threads=$6
assembly_counter=$7
extension=$8
extra=$9

upper_bound=4.0
set_bound=3.0
ratio_val=1.0

if [ 1 -eq "$(echo "$cov_val < $upper_bound" | bc)" ] && [ "0" -eq "$assembly_counter" ]; then
	      echo "Coverage in range"
              echo "Respect running"
              echo "Input	read_length
unclassified-kra_${genome}.hist	$(grep read_length ${lib_dir}/unclassified-kra_${genome}/unclassified-kra_${genome}.dat |cut -f2)" >${folder}/respect/${genome}/info.txt

              respect --debug -N ${iterations} --threads ${threads} -I ${folder}/respect/${genome}/info.txt -i ${lib_dir}/unclassified-kra_${genome}/unclassified-kra_${genome}.hist --tmp ${folder}/respect/${genome}/output/tmp -o ${folder}/respect/${genome}/output || true
              echo "Respect done"
              rm ${folder}/respect/${genome}/info.txt
      elif [ "0" -eq "$assembly_counter" ]; then
	      ratio_val="$( echo "scale=4; $set_bound / $cov_val" | bc)"
              echo "Coverage not in range, sample to be downsampled by ${ratio_val}"
              seqtk sample ${folder}/kraken/unclassified-kra_${genome}.fq $ratio_val> ${folder}/respect/${genome}/downsampled_${genome}_${ratio_val}.fq
              echo "Running respect on downsampled sample"
              respect -i ${folder}/respect/${genome}/downsampled_${genome}_${ratio_val}.fq -N ${iterations} --debug --tmp ${folder}/respect/${genome}/output/tmp -o ${folder}/respect/${genome}/output || true
              echo "Respect done"
      else
	      if [ "$extension" = "gz" ]; then
		      echo "Running respect on genome assembly"
              	      respect -i ${folder}/assemblies/${genome}.fna -N ${iterations} --debug --tmp ${folder}/respect/${genome}/output/tmp -o ${folder}/respect/${genome}/output || true
              	      echo "Respect done"
              else
		      temp=${folder}/${genome}.${extension}
		      input=$(dirname $lib_dir)
		      echo "Running respect on genome assembly"
                      respect -i ${temp} -N ${iterations} --debug --tmp ${extra}/respect/${genome}/output/tmp -o ${extra}/respect/${genome}/output || true
                      echo "Respect done"
              fi
fi
