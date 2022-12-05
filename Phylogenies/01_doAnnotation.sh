#!/bin/bash

####--------------------------------------
##SLURM options
####--------------------------------------
#SBATCH --job-name
#SBATCH --nodes 1
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 6G
#SBATCH --time 00:10:00
#SBATCH --output logs/%x_%A_%a.out
#SBATCH --error logs/%x_%A_%a.err
#SBATCH --array 0-NbOfGenomes
####--------------------------------------${sample}
##preparation
##set you bash variables in order to quickly call them in the script
####--------------------------------------
-----------------
username=
SAMPLE=( #array )
LocusTag=(#array)
threads=8

Genus=
working_directory=Phylogenies/${Genus}
FilesLocation=${working_directory}/GenomesFNA
Overall_output_directory=${working_directory}/02_PROKKA


####---------------------
##modules
####--------------------------------------

module load HPC/Software
module load UHTS/Analysis/prokka/1.13

####--------------------------------------
##start of script
####--------------------------------------

start=$SECONDS
echo "Step: PROKKA annotation"

#done
echo "=========================================================="
date +"START : %a %b %e %Y %H:%M:%S "
echo -e "Sample Name: "${SAMPLE[$SLURM_ARRAY_TASK_ID]}


###===========================
##PROKKA
echo -e "-------1. PROKKA annotation"
###===========================


prokka --compliant  --outdir ${Overall_output_directory}/${SAMPLE[$SLURM_ARRAY_TASK_ID]} --locustag ${LocusTag[$SLURM_ARRAY_TASK_ID]} --prefix ${LocusTag[$SLURM_ARRAY_TASK_ID]} --evalue 0.001 ${FilesLocation}/${SAMPLE[$SLURM_ARRAY_TASK_ID]}

####--------------------------------------
##End of script
####--------------------------------------
date +"END : %a %b %e %H:%M:%S %Z %Y"
echo "=========================================================="

duration=$(( SECONDS - start ))
echo -e "The script ran for "${duration} "seconds"
