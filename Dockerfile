FROM continuumio/miniconda3:latest
LABEL maintainer="Seb Rauschert <srauschert@minderoo.org>"

ENV PATH=/opt/conda/bin/:${PATH}

# Conda setups
# Taken from here https://github.com/smirarab/skimming_scripts/blob/master/Installation_guide.md

### Order matters here
RUN conda config --add channels defaults
RUN conda config --add channels bioconda
RUN conda config --add channels conda-forge
RUN conda config --add channels https://conda.anaconda.org/gurobi

### Instal Skmer
RUN conda install skmer==3.2.1
