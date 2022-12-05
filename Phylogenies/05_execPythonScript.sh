#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=4GB
#SBATCH --job-name=pythonScript #insert job name here
#SBATCH --output=logs/%x_%a.out #insert full path to a file where you want std out to go
#SBATCH --error=Phylogenies/logs/%x_%a.err #insert full path to a file where you want std error to go
#SBATCH --time=00:20:00
#SBATCH --export=None

# Load modules #
WorkingDir=Phylogenies
pathToScript=${WorkingDir}/scripts

Genus=

python3 ${pathToScript}/04_FetchAndConcat2.py ${WorkingDir}/${Genus}/04_Aligned_OG ${WorkingDir}/${Genus}/05_Whole_Alignments
