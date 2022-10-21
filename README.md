## Installations

~~~bash
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge

conda install skmer

skmer -h
~~~


* [bbmap_pipeline.sh](bbmap_pipeline.sh): takes as input two fastq files (for paired reads), splits them, removes the adapters, deduplicates, and merges
	* You can provide `TMPDIR` as 4th parameter. 
	* The input can be .gz files

* `submit*`: these scripts are used to submit jobs. Others can use them to with minimal changes
	* For [submit-calab-skmer.sh](submit-calab-skmer.sh), note that it purposefully uses fewer cores than available because of memory issues
