#!/usr/bin/env bash

# $1 mate1
# $2 mate2
# $3 output

set -e
set -x 

dukmem=16
# Keep the following number a product of 4
splitsize=20000000

bbmapdir=/calab_data/mirarab/home/smirarab/workspace
if [ $# -gt 3 ]; then 
	export TMPDIR=$4
else
	export TMPDIR=.
fi

mate_1=$1 #`mktemp -t "XXXXXX.fq"`
mate_2=$2 #`mktemp -t "XXXXXX.fq"`

split=`mktemp -t`

split -l ${splitsize} -d ${mate_1} ${split}_R1_
split -l ${splitsize} -d ${mate_2} ${split}_R2_

for x in `ls ${split}_R1_*`; do 
	# Adapter removal
	$bbmapdir/bbmap/bbduk.sh -Xmx${dukmem}g -Xms${dukmem}g in1=$x in2=${x/_R1_/_R2_} out1=${x/_R1_/_R1DUK_} out2=${x/_R1_/_R2DUK_} ref=adapters,phix ktrim=r k=23 mink=11 hdist=1 tpe tbo overwrite=true
	rm ${x/_R1_/_R2_} $x

	# Deduplicaiton
	$bbmapdir/bbmap/dedupe.sh -Xmx${dukmem}g -Xms${dukmem}g in1=${x/_R1_/_R1DUK_} in2=${x/_R1_/_R2DUK_} out=${x/_R1_/_OUT_} overwrite=true
	rm ${x/_R1_/_R1DUK_} ${x/_R1_/_R2DUK_}

	# reformat back 
	$bbmapdir/bbmap/reformat.sh in=${x/_R1_/_OUT_} out1=${x/_R1_/_OUT1_} out2=${x/_R1_/_OUT2_} overwrite=true
	rm ${x/_R1_/_OUT_}
	
	$bbmapdir/bbmap/bbmerge.sh in1=${x/_R1_/_OUT1_} in2=${x/_R1_/_OUT2_} out1=${x/_R1_/_MERGED_} overwrite=true mix=t
	rm ${x/_R1_/_OUT1_} ${x/_R1_/_OUT2_}
done

cat  ${split}_MERGED_* > $3

rm ${spli}*
