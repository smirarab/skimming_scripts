#!/bin/bash

set -e
set -x

working_directory=$1
ref_dir=$2

mkdir ${ref_dir}/interleaven_reads || true
cd $working_directory

for f in *.fastq.gz; do
	
    genome=$(basename -- "$f")
    genome="${genome%.*}"
    genome="${genome%.*}"
	
    read_1=${ref_dir}/interleaven_reads/${genome}.1.0.fastq
    read_2=${ref_dir}/interleaven_reads/${genome}.2.0.fastq
    whole_read=${ref_dir}/interleaven_reads/whole_read_${genome}.fastq

    zcat $f > $whole_read

    paste - - - - - - - - < $whole_read \
        | tee >(cut -f 1-4 | tr "\t" "\n" > $read_1) \
        |       cut -f 5-8 | tr "\t" "\n" > $read_2

    rm "$whole_read"

done
