## Installations

1. Install conda env:

~~~bash
conda env create -f environment.yml
~~~

2. RESPECT
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


## Tools

* [bbmap_pipeline.sh](bbmap_pipeline.sh): takes as input two fastq files (for paired reads), splits them, removes the adapters, deduplicates, and merges
	* You can provide `TMPDIR` as 4th parameter. 
	* The input can be .gz files

* `submit*`: these scripts are used to submit jobs. Others can use them to with minimal changes
	* For [submit-calab-skmer.sh](submit-calab-skmer.sh), note that it purposefully uses fewer cores than available because of memory issues

* [submit-calab-analyzetrees.sh](submit-calab-analyzetrees.sh): a post skmer script that makes a tree, format files, and makes some figures. 
