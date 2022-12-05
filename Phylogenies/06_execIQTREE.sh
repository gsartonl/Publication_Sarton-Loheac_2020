#!/bin/bash

#SBATCH --account
#SBATCH --mem 8G
#SBATCH --mail-user
#SBATCH	--mail-type BEGIN,END,FAIL,TIME_LIMIT_80
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --time 03:00:00
#SBATCH --cpus-per-task 16

#SBATCH --job-name IQTREE_Phylogenies
#SBATCH --output=logs/%x_%A_%a.out
#SBATCH --error=logs/%x_%A_%a.err

#Load modules
module load Phylogeny/iqtree

# Variables
username=
WorkingDir=Phylogenies
Genus=
data=${WorkingDir}/${Genus}/05_Whole_Alignments

cd ${WorkingDir}/${Genus}

iqtree -s ${data}/CoreGeneAlignment.fasta\
	-st AA -nt 16 -bb 1000 -seed 12345 -m TEST\
	-pre ${Genus}_Phylogeny
