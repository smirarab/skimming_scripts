# General guide on Genome Skim processing pipelines 

Below is a summary of some pipelines that we have designed using various tools that have been developed recently for the assembly-free analysis of all genomic information from genome skims including the nuclear reads. Using these pipelines, you can generate relevant information about genome characteristics (such as repeat spectra, length, and coverage) and phylogenetic characterisation (with or without a reference tree), which can be very useful for downstream applications.

Before we begin, here's a list of the tools that we have combined in these pipelines. 

**Tools:**

* [BBTools](https://sourceforge.net/projects/bbmap/) for reads cleanup
* [Skmer](https://github.com/shahab-sarmashghi/Skmer) for distance calculation between two genome skims
* [RESPECT](https://github.com/shahab-sarmashghi/RESPECT) for accurate repeat/coverage estimates
* [FastMe](http://www.atgc-montpellier.fr/fastme/) for phylogenetic inference using distances

We have also created micro-pipeline for these tools that perform each of their proposed operation on a single input (details and links below). Some of these micro-pipelines have been used as supporting operations in the combined pipelines. 

**Pipeline scripts:**

1. **skim_processing_batch_merge.sh**

Usage:``"bash skim_processing_batch_merge.sh -h [-x input] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``

``Runs nuclear read processing pipeline on a batch of reads split into two mates in reference to a constructed library:``
    
    Options:
    -h  show this help text

    Mandatory inputs:
    -x  path to folder containing reads (split reads to be merged)
    -g  path to reference library

    Optional inputs:
    -a  path to output directory for bbmap and respect outputs; 
    default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 8
    -f  number of cores for SKMER, default: 8"

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

2. **skim_processing_batch_no_merge.sh**

Usage:``'bash skim_processing_batch_no_merge.sh -h -h [-x input] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``
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

Please note that the output directories for bbmap and RESPECT would be ~/skim_processing_batch_no_merge/* , where ~/ is decided by (-a) input argument

3. **skim_processing_single_merge.sh**

Usage:``'bash skim_processing_single_merge.sh -h [-x input_1] [-y input_2] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``
``Runs nuclear read processing pipeline on a single read split into two mates in reference to a constructed library:``
    
    Options:
    -h  show this help text

    Mandatory inputs:
    -x  mate 1 of read
    -y  mate 2 of read
    -g  path to reference library

    Optional inputs:
    -a  path to output directory for bbmap and respect outputs; default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 8
    -f  number of cores for SKMER, default: 8'
    
**NOTE:** This pipeline performs the same set of operations (and produces the respective output) as described under **skim_processing_batch_merge.sh**. However, you should use this pipeline for a single genome divided into its two mates to be merged. 

In this case, the -x and -y input arguments direct to each of the two mates of the genome. 

Please note that the output directories for bbmap and RESPECT would be ~/skim_processing_single_merge/* , where ~/ is decided by (-a) input argument

4. **skim_processing_single_no_merge.sh** 

Usage:``'bash skim_processing_single_no_merge.sh -h [-x input] [-g lib_dir] [-a out_dir] [-r threads] [-d iterations] [-f cores]``
``Runs nuclear read processing pipeline on a single read (not split into two mates) in reference to a constructed library:``
    
    Options:
    -h  show this help text

    Mandatory inputs:
    -x  read to be processed
    -g  path to reference library

    Optional inputs:
    -a  path to output directory; default: current working directory
    -r  threads for RESPECT; default: 8
    -d  number of iteration cycles for RESPECT, default: 8
    -f  number of cores for SKMER, default: 8'
    
**NOTE:** This pipeline performs the same set of operations (and produces the respective output) as described under **skim_processing_batch_merge.sh**. However, you should use this pipeline for a single genome which does not need to be merged. 

In this case, the -x input argument directs to the single genome read. 

Please note that the output directories for bbmap and RESPECT would be ~/skim_processing_single_no_merge/* , where ~/ is decided by (-a) input argument

**Installation instructions:**

Refer to the Installation guide to understand how to install the main tools as well as other dependencies (including micro-pipelines) that would be required to run the described pipelines.


