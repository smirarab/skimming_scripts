#!/bin/bash

set -e
set -x

working_directory=$1
ref_dir=$2

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

mkdir ${ref_dir}/interleaven_reads || true
cd $working_directory

for f in ./*; do
	
    genome=$(basename -- "$f")
    extension="${genome##*.}"

    if [ "$extension" = "gz" ]; then
	    genome="${genome%.*}"
            extension="${genome##*.}"
	    
	    if [ "$extension" = "fastq" ] ||[ "$extension" = "fq" ]; then
		    
		    genome="${genome%.*}"

		    counter=0

        	    if [ -f "${ref_dir}/interleaven_reads/${genome}.1.fastq" ] || [ -f "${ref_dir}/interleaven_reads/${genome}.2.fastq" ] || [ -f "${ref_dir}/interleaven_reads/whole_read_${genome}.fastq" ]; then

                	test_var=0
			test_var=`grep "$genome" $SCRIPT_DIR/log_file.txt | grep -c "I"` || true
                	if [ "1" -eq "$test_var" ]; then
                        	counter=1
                	else
                        	rm ${ref_dir}/interleaven_reads/${genome}.1.fastq || true
				rm ${ref_dir}/interleaven_reads/${genome}.2.fastq || true
				rm ${ref_dir}/interleaven_reads/whole_read_${genome}.fastq || true
                	fi
        	    fi

		    if [ "0" -eq "$counter" ]; then
    		    	
			read_1=${ref_dir}/interleaven_reads/${genome}.1.fastq
    		    	read_2=${ref_dir}/interleaven_reads/${genome}.2.fastq
    		    	whole_read=${ref_dir}/interleaven_reads/whole_read_${genome}.fastq

    		    	zcat $f > $whole_read

    		    	paste - - - - - - - - < $whole_read \
        			| tee >(cut -f 1-4 | tr "\t" "\n" > $read_1) \
        			|       cut -f 5-8 | tr "\t" "\n" > $read_2

    		    	rm "$whole_read"
		    	
			if [ -z "`grep "$genome" $SCRIPT_DIR/log_file.txt`" ]; then
	                        echo "$genome"".I">>$SCRIPT_DIR/log_file.txt
        	        else
                	        var=`grep "$genome" $SCRIPT_DIR/log_file.txt`
                        	var1="$genome"".I"
                        	sed -i "s/$var/$var1/" $SCRIPT_DIR/log_file.txt
                	fi

		    else
		    	echo "Interleaved split operation on this sample already performed"	
		    fi

	    fi
	
     elif [ "$extension" = "fastq" ] || [ "$extension" = "fq" ]; then

	     genome="${genome%.*}"

	     counter=0

             if [ -f "${ref_dir}/interleaven_reads/${genome}.1.fastq" ] || [ -f "${ref_dir}/interleaven_reads/${genome}.2.fastq" ]; then

                        test_var=0
		        test_var=`grep "$genome" $SCRIPT_DIR/log_file.txt | grep -c "I"` || true
                        if [ "1" -eq "$test_var" ]; then
                                counter=1
                        else
                                rm ${ref_dir}/interleaven_reads/${genome}.1.fastq || true
                                rm ${ref_dir}/interleaven_reads/${genome}.2.fastq || true
                        fi
             fi
	     
	     if [ "0" -eq "$counter" ]; then
	     
		     read_1=${ref_dir}/interleaven_reads/${genome}.1.fastq
    	     	     read_2=${ref_dir}/interleaven_reads/${genome}.2.fastq
	     
	     	     paste - - - - - - - - < $f \
        	 	| tee >(cut -f 1-4 | tr "\t" "\n" > $read_1) \
        	 	|       cut -f 5-8 | tr "\t" "\n" > $read_2
	     
	     	     if [ -z "`grep "$genome" $SCRIPT_DIR/log_file.txt`" ]; then
                                echo "$genome"".I">>$SCRIPT_DIR/log_file.txt
                     else
                                var=`grep "$genome" $SCRIPT_DIR/log_file.txt`
                                var1="$genome"".I"
                                sed -i "s/$var/$var1/" $SCRIPT_DIR/log_file.txt
                     fi
     	     else

		     echo "Interleaved split operation on this sample already performed"
	     
	     fi

     fi

done
