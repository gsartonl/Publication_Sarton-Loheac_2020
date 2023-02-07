#######################
### README ###

Metabolic profiler

#######################

This is a snakemake pipeline combining several tools to
assess the completeness of selected metabolic pathways.


For this pipeline to work, amino-acid fasta files of the genomes of interest are
required and the installation of [PaperBLAST](https://github.com/morgannprice/PaperBLAST) and [macsyfinder](https://github.com/gem-pasteur/macsyfinder) are necessary.

To get kegg annotations, we merged the amino-acid fasta files and uploaded them
on https://www.kegg.jp/ghostkoala/ (! several merge-files may be necessary as
there is a file size of up to 300 MB with the limit of 500,000 sequences).
This step can also be done locally if you have access to the kegg database

Ideally the locus-tags follow the format TAG_GeneNumber.



### Snakefile :

 master file with rules.


### faa_input_files :

Create the directory and place your amino-acid fasta file (faa) annotations files here

### ko_pathways :

Create the directory and place GoshtKoala annotation here. Adapt the file name in config.yaml

### PaperBLAST :

Install the [PaperBLAST](https://github.com/morgannprice/PaperBLAST) tool here, and follow the instructions to install [Gapmind](https://github.com/morgannprice/PaperBLAST/tree/master/gaps) (required for the analysis).

### setup :

#### envs:

 yaml files for rules conda environments

#### macsyfinder :

clone and install the macsyfinder tool here. Available at https://github.com/gem-pasteur/macsyfinder

#### scripts:
Snakemake rules scripts

`conda_Profiler.yaml `: config file for the snakemake conda environment

`config.yaml `: config file for the snakemake pipeline, path and filenames can be adapted here

`input_rules_v3.txt` : pathway definition for KO pathways analysis


### logs :

snakemake log files
