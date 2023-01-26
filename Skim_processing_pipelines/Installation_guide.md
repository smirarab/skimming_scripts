# Installation guide for Genome Skim processing pipelines

**NOTE:** Most of the tools would be installed through the conda distribution within an activated conda environment in the working shell. 

* Whenever you are using any of the pipelines, make sure that you change the env name in the `conda_source.sh` [script](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Pipelines/conda_source.sh). Refer to `CONDAENV=GSkim` in the script where `GSkim` should be changed to your environment's name corresponding to all the tool installations.
* In the example below, we would change the `conda_source.sh` [script](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Pipelines/conda_source.sh) to say `CONDAENV=tutorial`

The `conda_source.sh` [script](https://github.com/smirarab/skimming_scripts/blob/master/Skim_processing_pipelines/Pipelines/conda_source.sh) is meant to allow users to edit the name of their conda environment to easily switch between various configurations. A sample conda environment configuration can be seen [here](https://github.com/smirarab/skimming_scripts/blob/master/environment.yml). 

**Install main tools**

```
mkdir tutorial
cd tutorial

conda create --name tutorial
conda activate tutorial

### Order matters here
conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
conda config --add channels https://conda.anaconda.org/gurobi

### Instal Skmer
conda install skmer
skmer -h

### These dependencies should ideally be installed along with skmer. 
###If not, you can always run this command to install them separately.
conda install jellyfish seqtk mash gurobi 

### Install RESPECT
git clone https://github.com/shahab-sarmashghi/RESPECT.git
cd RESPECT
python setup.py install
cd ..

### To download BBMap
wget -O bbmap.tar.gz https://sourceforge.net/projects/bbmap/files/BBMap_39.01.tar.gz/download
tar xvfz bbmap.tar.gz
rm bbmap.tar.gz

### Install FastME (to get backbone trees)
wget http://www.atgc-montpellier.fr/download/sources/fastme/fastme-2.1.5.tar.gz
tar xvfz fastme-2.1.5.tar.gz
chmod +x fastme-2.1.5/binaries/fastme-2.1.5-osx 
## Change "osx" at the end if using other platforms (linux or windows).
./fastme-2.1.5/binaries/fastme-2.1.5-osx -h
```

