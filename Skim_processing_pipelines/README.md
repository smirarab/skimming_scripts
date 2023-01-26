# General guide on Genome Skim processing pipelines 

Below is a summary of some pipelines that we have designed using various tools that have been developed recently for the assembly-free analysis of all genomic information from genome skims including the nuclear reads. Using these pipelines, you can generate relevant information about genome characteristics (such as repeat spectra, length, and coverage) and phylogenetic characterisation (with or without a reference tree), which can be very useful for downstream applications.

Before we begin, here's a list of the tools that we have combined in these pipelines. 

### Tools:

* [BBTools](https://sourceforge.net/projects/bbmap/) for reads cleanup
* [Skmer](https://github.com/shahab-sarmashghi/Skmer) for distance calculation between two genome skims
* [RESPECT](https://github.com/shahab-sarmashghi/RESPECT) for accurate repeat/coverage estimates
* [FastMe](http://www.atgc-montpellier.fr/fastme/) for phylogenetic inference using distances

We have also created micro-pipeline for some of these tools that perform their respective operation on a single input. These micro-pipelines (details can be found [here](https://github.com/smirarab/skimming_scripts/tree/master/Skim_processing_pipelines/Pipelines)) have been used as supporting operations in the combined pipelines. 

### Installation instructions:

Refer to the [Installation guide](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Installation_guide.md) to understand how to install the main tools as well as other dependencies (including micro-pipelines) that would be required to run the described pipelines.

### Pipeline scripts:

You can find all the pipelines mentioned below [here](https://github.com/smirarab/skimming_scripts/tree/master/Skim_processing_pipelines/Pipelines).

1. [**skim_processing_batch.sh**](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Pipelines/skim_processing_batch.sh)

Usage: ``bash skim_processing_batch.sh -h [-x input] [-l interleaven_counter] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``

``Runs nuclear read processing pipeline on a batch of reads split into two mates in reference to a constructed library:``
    
    Options:
    -h  show this help text
   
    Mandatory inputs:
    -x  path to folder containing reads (split reads that need to be merged)
    
    Optional inputs:
    -l  can be set as 0(default) or 1, input 1 if the input directory consists of single interleaved paired-end reads instead of two mate pair reads
    -g  path to reference library
    -a  path to output directory for bbmap and respect outputs; default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 1000
    -f  number of cores for SKMER, default: 8"

The inputs are as follows:

* `-x`: a folder containing two files per sample, one per read. 

* `-g`: the path of the reference library. If this path exists, the pipeline will just add to it. If it does not exist, the pipeline will create the library. 

This pipeline performs the following set of operations (and produces the respective output) for each genome mate pair in the batch of files:

* BBMap operations: 
    * 1) remove adapters, 2) deduplicate reads, and 3) merge paired-end reads
    * Outputs the cleaned and merged read for each pair; output location is ~/skim_processing_batch_merge/bbmap where ~/ is decided by (-a) input argument
* Skmer operations:
    * Augments the reference library by adding the input genome query (saves the *.hist*, *.dat*, and *.msh* files of the query inside the library)
        * The .hist file gives 𝑘-mer frequency histogram
        * The .dat file gives genome length, coverage , sequencing error, and average read length. For genomes, all but genome length are left as NA.
        * The .msh file includes the minimum-hashed version of 𝑘-mer sets produced using Mash. The default size is 100000 (can be changed with -s).
    * Outputs a text file (*dist-Query.txt*) containing the distance between the input genome query and every query in the reference library; output location is the current working directory
* RESPECT operations:
    *   Characterises the input genome by computing its k-mer repeat spectra; for larger sized genomes, we downsample the sample to an appropriate level (corresponding to a coverage of ~3x) before running RESPECT
    *   Outputs two tab-separated tables files called *estimated-parameters.txt* and *estimated-spectra.txt* for each genome; output location is ~/skim_processing_batch_merge/respect where ~/ is decided by (-a) input argument
*   Post-processing operations:
    *   Infers the phylogenetic tree and pairwaise distance of the input batch of genomes against the reference set (from the *library*)
    *   Outputs a zipped folder containing the following files to the current working directory:
        *   tree-${out_name}.tre 
        *   stats-${out_name}.csv - summary of all genetic parameters (genome length, coverage , sequencing error, and average read length) for all genomes
        *   fig-${out_name}.pdf - phylogenetic tree inferred using FastMe
        *   dist-${out_name}.txt - pairwise distance between all genomes in the library (existing and input)

2. [**skim_processing_batch_interleaved.sh**](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Pipelines/skim_processing_batch_interleaved.sh)

Usage: ``bash skim_processing_batch_interleaved.sh -h -h [-x input] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``

``Runs nuclear read processing pipeline on a batch of reads (not split into two mates) in reference to a constructed library:``
    
    Options:
    -h  show this help text

    Mandatory inputs:
    -x  path to folder containing reads (reads not to be merged)
    -g  path to reference library

    Optional inputs:
    -a  path to output directory for bbmap and respect outputs; default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 8
    -f  number of cores for SKMER, default: 8'

**NOTE:** This pipeline performs the same set of operations (and produces the respective output) as described under **skim_processing_batch_merge.sh**. However, you should use this pipeline if the original set of genomes are not divided into two mates and therefore. **do not have to be merged** using BBMap toolkit. 

In this case, the -x input argument directs to a folder containing reads, with each read corresponding to an individual genome instead of a pair of reads corresponding to one.

Please note that the output directories for bbmap and RESPECT would be ~/skim_processing_batch_interleaved/* , where ~/ is decided by (-a) input argument
