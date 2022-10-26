#!/usr/bin/env bash

# $1 mate1
# $2 mate2
# $3 output

if [ $# -lt 3 ]; then 
	echo "USAGE: $0 [first fastq(.gz) input] [second fastq(.gz) input] [output filename] ([TMPDIR])"
fi


set -e
set -x 

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

bbmapdir=$SCRIPT_DIR
# To get bbmap:  wget -O bbmap.tar.gz  https://sourceforge.net/projects/bbmap/files/BBMap_38.87.tar.gz/download

dukmem=16
# Keep the following number a product of 4
splitsize=20000000

if [ $# -gt 3 ]; then 
	export TMPDIR=$4
else
	export TMPDIR=.
fi

mate_1=$1 #`mktemp -t "XXXXXX.fq"`
mate_2=$2 #`mktemp -t "XXXXXX.fq"`

if [ $# -gt 4 ]; then
	split=$5
else
	split=`mktemp -t`

	zcat -f ${mate_1} | split -l ${splitsize} -d - ${split}_R1_
	zcat -f ${mate_2} | split -l ${splitsize} -d - ${split}_R2_
fi

for x in `ls ${split}_R1_*`; do 
	# Adapter removal
	$bbmapdir/bbmap/bbduk.sh -Xmx${dukmem}g -Xms${dukmem}g in1=$x in2=${x/_R1_/_R2_} out1=${x/_R1_/_R1DUK_} out2=${x/_R1_/_R2DUK_} ref=adapters,phix ktrim=r k=23 mink=11 hdist=1 tpe tbo overwrite=true
	rm ${x/_R1_/_R2_} $x

	# Deduplicaiton
	$bbmapdir/bbmap/dedupe.sh -Xmx${dukmem}g -Xms${dukmem}g in1=${x/_R1_/_R1DUK_} in2=${x/_R1_/_R2DUK_} out=${x/_R1_/_OUT_} overwrite=true
	rm ${x/_R1_/_R1DUK_} ${x/_R1_/_R2DUK_}

	# reformat back (to fastq?)
	$bbmapdir/bbmap/reformat.sh in=${x/_R1_/_OUT_} out1=${x/_R1_/_OUT1_} out2=${x/_R1_/_OUT2_} overwrite=true
	rm ${x/_R1_/_OUT_}
	
	# merge the two reads
	$bbmapdir/bbmap/bbmerge.sh in1=${x/_R1_/_OUT1_} in2=${x/_R1_/_OUT2_} out1=${x/_R1_/_MERGED_} overwrite=true mix=t
	rm ${x/_R1_/_OUT1_} ${x/_R1_/_OUT2_}
done

cat  ${split}_MERGED_* > $3

rm ${split} ${split}_MERGED_*
