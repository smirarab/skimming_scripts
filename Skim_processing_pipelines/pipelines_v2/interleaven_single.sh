#!/bin/bash

set -e
set -x

working_input=$1
ref_dir=$2

mkdir ${ref_dir}/tmp
cd ${ref_dir}/tmp

genome=$(basename -- "$working_input")
genome="${genome%.*}"
genome="${genome%.*}"
	
read_1=${ref_dir}/tmp/${genome}.1.0.fastq
read_2=${ref_dir}/tmp/${genome}.2.0.fastq
whole_read=${ref_dir}/tmp/whole_read_${genome}.fastq

zcat $f > $whole_read

paste - - - - - - - - < $whole_read \
     | tee >(cut -f 1-4 | tr "\t" "\n" > $read_1) \
     |       cut -f 5-8 | tr "\t" "\n" > $read_2

rm "$whole_read"
