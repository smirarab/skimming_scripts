## General guide on Genome Skim processing pipelines 

Here, we have summarised the skim processing pipeline that we have designed using various tools that have been developed recently for the assembly-free analysis of all genomic information from genome skims including the nuclear reads. Using this pipeline, you can generate relevant information about genome characteristics (such as repeat spectra, length, and coverage) and phylogenetic characterisation (with or without a reference tree), which can be very useful for downstream applications.

Before we begin, here's a list of the tools that we have combined in these pipelines. 

### Tools:

* [BBTools](https://sourceforge.net/projects/bbmap/) for reads cleanup
* [Skmer](https://github.com/shahab-sarmashghi/Skmer) for distance calculation between two genome skims
* [RESPECT](https://github.com/shahab-sarmashghi/RESPECT) for accurate repeat/coverage estimates
* [FastMe](http://www.atgc-montpellier.fr/fastme/) for phylogenetic inference using distances

We have also created micro-pipelines for some of these tools that perform their respective operation on a single input. These micro-pipelines (found [here](https://github.com/smirarab/skimming_scripts)) have been used as supporting operations in the integrated pipeline. A brief summary about these auxilliary pipelines has also been provided below.

### Installation instructions:

Refer to the [Installation guide](https://github.com/smirarab/skimming_scripts/blob/master/Installation_guide.md) to understand how to install the main tools as well as other dependencies (including micro-pipelines) that would be required to perform the described operations.

### Pipeline scripts:

You can find the pipeline mentioned below [here](https://github.com/smirarab/skimming_scripts).

1. [**skims_processing_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/skims_processing_pipeline.sh)

Usage: ``bash skims_processing_pipeline.sh -h [-x input] [-l interleaven_counter] [-g lib_dir] [-r threads] [-d iterations] [-f cores]``

``Runs nuclear read processing pipeline on a batch of reads split into two mates in reference to a constructed library:``
    
    Options:
    -h  show this help text
   
    Mandatory inputs:
    -x  path to folder containing reads (split reads that need to be merged)
    
    Optional inputs:
    -l  can be set as 0(default) or 1, input 1 if the input directory consists of single interleaved paired-end reads instead of two mate pair reads
    -g  path to reference library
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 1000
    -f  number of cores for SKMER, default: 8"

The inputs are as follows:

* `-x`: a folder containing two files (or a single interleaved file) in fastq.gz/fq.gz/fastq/fq format per sample denoting the two mates of the genome read. A test dataset has been provided in this repo [here](https://github.com/smirarab/skimming_scripts/tree/master/test/skims). **Please provide the absolute path to the input directory here, even if it is contained in the working directory.** 

* `-g`: the path of the reference library. This is an optional argument: if this path is provided, the pipeline will just add to it and if it is not provided, the pipeline will create the library in the working directory. 

* `-l`: This optional parameter is default set at 0. You should set it to 1 [by adding `-l 1` to the CL input for this pipeline] if the input directory contains one interleaved file per sample in fastq.gz/fq.gz/fastq/fq format. 

This pipeline performs the following set of operations (and produces the respective output) for each genome sample in the batch of files:

* BBMap operations: 
    * 1) remove adapters, 2) deduplicate reads, and 3) merge paired-end reads
    * Outputs the cleaned and merged read for each pair; output location is ~/skims_processing_pipeline/bbmap where ~/ is the current working directory
* Skmer operations:
    * Augments the reference library by adding the input genome query (saves the *.hist*, *.dat*, and *.msh* files of the query inside the library)
        * The .hist file gives 𝑘-mer frequency histogram
        * The .dat file gives genome length, coverage , sequencing error, and average read length. For genomes, all but genome length are left as NA.
        * The .msh file includes the minimum-hashed version of 𝑘-mer sets produced using Mash. The default size is 100000 (can be changed with -s).
* RESPECT operations:
    *   Characterises the input genome by computing its k-mer repeat spectra; for larger sized genomes, we downsample the sample to an appropriate level (corresponding to a coverage of ~3x) before running RESPECT
    *   Outputs two tab-separated tables files called *estimated-parameters.txt* and *estimated-spectra.txt* for each genome; output location is ~/skims_processing_pipeline/respect/output where ~/ is the current working directory
    *   Outputs tmp files created by Respect during its operations, which contain the parameter estimates during all the iteration cycles of the analysis; output location is ~/skims_processing_pipeline/respect/output/tmp where ~/ is the current working directory 
*   Post-processing operations:
    *   Infers the phylogenetic tree and pairwaise distance of the input batch of genomes against the reference set (from the *library*)
    *   Outputs a zipped folder containing the following files to the current working directory:
        *   tree-${out_name}.tre 
        *   stats-${out_name}.csv - summary of all genetic parameters (genome length, coverage , sequencing error, and average read length) for all genomes
        *   fig-${out_name}.pdf - phylogenetic tree inferred using FastMe
        *   dist-${out_name}.txt - pairwise distance between all genomes in the library (existing and input)

**NOTE**: The pipeline creates a log file (named as `log_file.txt`) in the directory containing the scripts. This log file tracks the various input files that have been processed using this pipeline as well as the specific operations conducted on those input files by appending the following string to the text file: `<genome_name><IABC>`; 

where each letter means the successful completion of a particular operation on the input file corresponding to that genome. The nomenclature for the letters is as follows:

* I -> Split the interleaved file into two paired fastq files per sample (if `-l` is set to 1)
* A -> BBMap operation (Cleaning and merging the two reads per sample)
* B -> Skmer operation (adding the query to the library and building the library)
* C -> Respect operation (Characterising the genome skim)

**Deleting or moving the file would force the pipeline to repeat operations performed earlier on the same input files, thus compromising with the speed and efficiency of the entire process. Therefore, it is advised not to make changes to this file.**

Here on, we discuss the auxilliary scripts used in the integrated pipeline.

2. [**bbmap_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/bbmap_pipeline.sh): Takes as input two fastq/fastq.gz files (for paired reads), splits them, removes the adapters, deduplicates, and merges them.
	* You can provide `TMPDIR` as 4th parameter. 

3. [**conda_source.sh**](https://github.com/smirarab/skimming_scripts/blob/master/conda_source.sh): Allows the user to switch between different environment configurations with the essential tools installed to run this pipeline. Refer to `CONDAENV=GSkim4` in the script where GSkim4 should be changed to your environment's name before running the pipeline.

4. [**interleaved_bbmap_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/interleaved_bbmap_pipeline.sh): Takes as input two fastq/fastq.gz files (for paired reads) which have been obtained by splitting an interleaved (fastq/fastq.gz) file for a genome sample. The script then splits them, removes the adapters, deduplicates, and merges them.
	* You can provide `TMPDIR` as 4th parameter. 

5. [**interleaven.sh**](https://github.com/smirarab/skimming_scripts/blob/master/interleaven.sh): Takes as input a directory of interleaved (fastq/fastq.gz) files and splits each of them into a batch of two fastq files for each interleaved file present in the original directory. The output location is ~/interleaven_reads, where ~/ is the current working directory

6. [**jc-correction.sh**](https://github.com/smirarab/skimming_scripts/blob/master/jc-correction.sh): Takes as input the dist-matrix txt file produced by `skmer distance` and applies the Jukes-Cantor correction on the data contained in the input file. 

7. [**post_processing_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/post_processing_pipeline.sh): Takes as input the dist-matrix txt file produced by `skmer distance` as well as the *library* directory built from skim samples, and outputs a zipped folder with contents as described under '**Post-processing operations**' for **skims_processing_pipeline.sh**.

8. [**respect_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/respect_pipeline.sh): Takes as an input the merged and cleaned fastq file for the genome skim sample and produces the output as described under '**RESPECT operations**' for **skims_processing_pipeline.sh**.

9. [**skmer_pipeline.sh**](https://github.com/smirarab/skimming_scripts/blob/master/skmer_pipeline.sh): Takes as an input the merged and cleaned fastq file for the genome skim sample and produces the output as described under '**Skmer operations**' for **skims_processing_pipeline.sh**.

10. [**tsv_to_phymat.sh**](https://github.com/smirarab/skimming_scripts/blob/master/tsv_to_phymat.sh): Takes as an input the Jukes-Cantor corrected dist-matrix file (outputted by **jc-correction.sh**) and converts the dataframe into a format suitable for fastme operations.

##Additional folders

1. [**bbmap**](https://github.com/smirarab/skimming_scripts/tree/master/bbmap): contains the scripts used by **bbmap_pipeline.sh** pipeline for cleaning and merging operations on a pair of fastq/fastq.gz files. You can download it from the source repository (instructions provided in the [installation guide](https://github.com/smirarab/skimming_scripts/blob/master/Installation_guide.md)) or simply clone this repository to use them.

2. [**fastme-2.1.5**](https://github.com/smirarab/skimming_scripts/tree/master/fastme-2.1.5): contains the FastME scripts used by **post_processing_pipeline.sh** pipeline to infers the phylogenetic tree and pairwaise distances between the query samples. You can download it from the source repository (instructions provided in the [installation guide](https://github.com/smirarab/skimming_scripts/blob/master/Installation_guide.md)) or simply clone this repository to use them.

3. [**Obsolete**](https://github.com/smirarab/skimming_scripts/tree/master/Obsolete): contains additional scripts developed earlier, that are not required for the working of the newer version of the pipeline.

4. [**test/skims**](https://github.com/smirarab/skimming_scripts/tree/master/test/skims): contains the test dataset of yeast genomes based skim samples, that can be used to test the working of this pipeline.

<!-- 
## Installations

1. Install conda env:

~~~bash
conda env create -f environment.yml
~~~

2. RESPECT (also covered in the [installation guide](https://github.com/smirarab/skimming_scripts/blob/master/Installation_guide.md)) 

~~~bash
pushd ..
git clone https://github.com/shahab-sarmashghi/RESPECT.git
cd RESPECT/
python setup.py install
popd
~~~

3. Newick utilities (not necessary):

Download and install fromm https://anaconda.org/bioconda/newick_utils/1.6/download/linux-64/newick_utils-1.6-hec16e2b_5.tar.bz2

4. Note: FastME is already made available but can also be downloaded directly

```bash
wget http://www.atgc-montpellier.fr/download/sources/fastme/fastme-2.1.5.tar.gz
tar xvfz fastme-2.1.5.tar.gz
chmod +x fastme-2.1.5/binaries/fastme-2.1.5-linux64 ## Change "linux64" at the end if using other platforms (osx or windows).
./fastme-2.1.5/binaries/fastme-2.1.5-linux64 -h
```
<!-- 
<!-- 
## Scripts

* [bbmap_pipeline.sh](bbmap_pipeline.sh): takes as input two fastq files (for paired reads), splits them, removes the adapters, deduplicates, and merges
	* You can provide `TMPDIR` as 4th parameter. 
	* The input can be .gz files -->
<!-- 
* `submit*`: these scripts are used to submit jobs. Others can use them to with minimal changes
	* For [submit-calab-skmer.sh](submit-calab-skmer.sh), note that it purposefully uses fewer cores than available because of memory issues -->

<!-- * [submit-calab-analyzetrees.sh](submit-calab-analyzetrees.sh): a post skmer script that makes a tree, format files, and makes some figures.  -->

## Tutorials

See https://github.com/smirarab/tutorials/blob/master/skimming-tutorials.md
