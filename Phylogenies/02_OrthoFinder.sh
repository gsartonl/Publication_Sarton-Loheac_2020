#!/bin/bash

####--------------------------------------
##SLURM options
####--------------------------------------
#SBATCH --job-name OrthoFinder
#SBATCH --partition wally
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 16
#SBATCH --mem 36G
#SBATCH --time 02:30:00
#SBATCH --output logs/%x_%A_%a.out
#SBATCH --error logs/%x_%A_%a.err

####--------------------------------------${sample}
##preparation
##set you bash variables in order to quickly call them in the script
####

module load Phylogeny/OrthoFinder/2.3.8

username=
Genus=

working_directory=Phylogenies/${Genus}
AnnotationsDir=${working_directory}/02_PROKKA
FilesLocation=${working_directory}/03_GenesFaa

mkdir -p ${FilesLocation}

for FILE in $(find ${AnnotationsDir} | grep -v 'Data' | grep -v 'intergenic' | grep -v 'genes' | grep -v 'Ga' | grep 'faa') ;
  do cp ${FILE} ${FilesLocation} ;
done

orthofinder -f ${FilesLocation} -t 16 -n ${Genus}
