#!/bin/bash
## Copy output files in out directory ##
## remove files from common directories ##

outDir=$1
finishFile=$2

pwd -P
# copy ko_results to outDir
mkdir ${outDir}
mkdir ${outDir}/ko_results
mv ko_pathways/*all_genomes* ${outDir}/ko_results

## Gapmind/paperBlast ##
# copy gapmind results to outDir
mkdir ${outDir}/gapmind
mv gapmind_aa_biosynth/*aa_pathways_scores* ${outDir}/gapmind

# empty paperBlast tmp
cd PaperBLAST/tmp
find . -type d -not -name 'path.*' -exec rm -rf {} +
mkdir DvH
cd ../..

# copy heatmap to outDir
mv *HeatMap* ${outDir}/
mv all_completeness_scores.txt ${outDir}/

# copy macsyfinder results to outDir
mkdir ${outDir}/macsyfinder
mv macsyfinder_mainsystems.txt ${outDir}/macsyfinder
rm -r macsyfinder/*

mkdir ${outDir}/faa_input_files
mv faa_input_files/* ${outDir}/faa_input_files
mkdir ~/Documents/Profiler/faa_input_files

echo 'Pipeline is finished' >> ${finishFile}
