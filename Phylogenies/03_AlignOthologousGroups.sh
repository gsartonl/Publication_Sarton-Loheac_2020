#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=100MB
#SBATCH --job-name=mafft #insert job name here
#SBATCH --output=%x_%a.out #insert full path to a file where you want std out to go
#SBATCH --error=%x_%a.err #insert full path to a file where you want std error to go
#SBATCH --time=01:00:00
#SBATCH --export=None


# Load modules #
source /dcsrsoft/spack/bin/setup_dcsrsoft
module load gcc/8.3.0
module load mafft/7.453

### Set variables ####
username=
Genus=

workingDir=/users/${username}/scratch/${username}/Phylogenies

data=${workingDir}/${Genus}/03_GenesFaa/Orthofinder/Results_${Genus}/Single_Copy_Orthologue_Sequences/
outDir=${workingDir}/${Genus}/04_Aligned_OG

FILES=($(ls -A ${data})) # files names will be stored in an array (! without their path)

mkdir -p ${outDir} # make output directory
# Align OGs

for f in ${FILES}; do

	mafft --amino --inputorder --localpair --maxiterate 1000 ${data}/${F} > ${outDir}/${f/.fa/_aligned.fa};

done
