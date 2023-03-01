#!/bin/bash

set -e
set -x

f=$1
folder=$2
input=$3
lib=$4
cores=$5

if [ "1" -eq "$f" ]; then
	echo "Skmer reference running for first entry in new library"
        skmer --debug reference -p ${cores} -l ${lib} ${folder} || true
        #rm ref-dist-mat.txt
        echo "Skmer reference done"
else
        echo "Skmer query running"
        skmer --debug query -a -p ${cores} ${folder}/${input} ${lib} || true
        #rm dist-*.txt
        echo "Skmer query done"
fi

