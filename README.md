# Publication_Sarton-Loheac_2022
Scripts associated with Sarton-Loheac et al. 2022

##### README DADA2 #####


16S rRNA gene amplicon sequencing data were analysed using the DADA2 pipeline
[Callahan, B., McMurdie, P., Rosen, M. et al., 2016](https://doi.org/10.1038/nmeth.3869).

We based our pipeline based on [DADA2 tutorial](https://benjjneb.github.io/dada2/tutorial.html).

For each of the three sequencing runs, primers were identified using a
[custom function](https://benjjneb.github.io/dada2/ITS_workflow.html) and removed
with [cutadapt](http://cutadapt.readthedocs.io/en/stable/index.html).

Samples from each run were processed independently for the:
  - Trimming (function *filterAndTrim*)
  - Dereplication (function *derepFastq*)
  - Infering the error rates (function *learnErrors*)
  - Sample inference (function *dada*)
  - Merging paired reads (function *mergePairs*)
  - Building the sequence table (function *makeSequenceTable*)

The tables from the three runs were then merged (function *mergeSequenceTables*) and sequences were combined using the *collapseNoMismatch* function which "Combine together sequences that are identical up to shifts and/or length" [see](https://www.bioconductor.org/packages/3.6/bioc/manuals/dada2/man/dada2.pdf).

The resulting sequence table was filtered to keep sequences in range 251-254bp (the length of the amplified region) from which we removed chimeric sequences (function *removeBimeraDenovo*).

Taxonomic assignment of the reads was performed with the [SILVA v132 database](https://zenodo.org/record/1172783#.Y4TjH-zMKHE)
silva_species_assignment_v132.

###################### README ######################
##              whole genome phylogeny								 
####################################################



For each phylogeny, the genomes of interest have been re-annotated with PROKKA
to get consistent annotations.
File names are identical to the respective locus-tags.
The strain name/number is used as locus tag.
Then orthologous groups are inferred with OrthoFinder. Single copy orthologous
groups are then aligned and merged into a single sequence per species.

The alignment was used to compute the phylogeny with IQTree http://www.iqtree.org/


## ${Family} :

main directory for each family

### GenomesFiles :

#### Genomes :

 genomes annotations and data from NCBI / IMG downloads

#### 01_GenomesFNA :

 cmd :
  ```{bash}
  for FILE in $(find . )|grep -v 'interge' |grep -v 'genomic'|grep -v 'genes'| grep 'fna') ; do cp  ${FILE} ../GenomesFNA ; done 
  ```

 .fna files from all genomes that will be included in to the phylogeny

#### 02_PROKKA :
cmd : 
```{bash}
sbatch 01_doAnnotation.sh
```
Genomes are annotated with (most of the time) their strain name/number as locus-tags. Directories names are .fna name of the samples.

Prokka output files have same identifier as the locus-tag -> ie strain name/number

##### Genomes :

 Genomes are re-annotated with porkka to have consistency among the annotations
 
### 03_GenesFaa :
 cmd :
 ```{bash}
 sbatch 02_OrthoFinder.sh -> for FILE in $(find ${AnnotationsDir} | grep -v 'Data' | grep -v 'intergenic' | grep -v 'genes' | grep -v 'Ga' | grep 'faa') ; do cp ${FILE} ${FilesLocation} ; done
 ```
 .faa files : annotation files of all the samples

### 04_Aligned_OG :
cmd : 
``` {bash}
sbatch 03_AlignOrthologousGroups.sh
 ```
Each OG sequences are aligned -> OGxx_aligned.fa 

### 05_Whole_Alignments :
The pruned alignments for each orthogroup are available. The concatenation of all the aligned OG (per species) is the Core Gene alignment

 cmd:  
 ```{bash}
 python3 ./scripts/04_FetchAndConcat2.py 04_Aligned_OG 05_Whole_Alignments
 # or 
 
 sbatch 05_execPythonScript.sh 
  ```
 `CoreGeneAlignment.fasta` : concatenated OG per species -> to use for phylogeny

 `OGxx_aligned_prined.fasta` files : single OG aligned and pruned

### 06_Results :

#### OrthoFinder :
#### Results_${Family}

Single_Copy_Orthologue_Sequences : directory of interest

 Other directories with orthofinder results -> orthogroups,

####  phylogeny :
 cmd:  
 ```{bash}
 sbatch 06_execIQTREE.sh 
 ```
WGP_${Familiy}.contree : consensus tree.

## scripts

`03_AlignOrthologousGroups.sh` : to align sequences
	 parameters :
		--amino : use amino-acids
		--inputorder
		--localpair
		--maxiterate 1000
		
`01_doAnnotation.sh`
arrays :
	- array SAMPLE : .fna file names
	- array LocusTag : locus tag associated to .fna files (thy have to be in the same order as .fna file names)

 parameters :
		--compliant
		--evalue 0.01

`06_execIQTREE.sh` :

 array :
	- Genus : Genus names corresponding to the ${Family} directory name
	
 parameters :
		-st AA
		-nt 16
		-bb 16
		-seed 1234
		-m TEST (to find the best model for the data)
		-pre ${Family}_Phylogeny

`05_execPythonScript.sh` :
	
  For this script to work, we assume that the headers have a structure  "${LocusTag}_000xx or ${LocusTag}_000xxstrain_name"
	
parameters :
		- arg1 : script
		- arg2 : input directory -> path to 04_Aligned_OG
		- arg3 : output directory -> path to 05_Whole_Alignments (scripts creates the outdir)
		- arg4 : pipeNames -> set to TRUE if headers contains a pipe.

`02_OrthoFinder.sh` :
	
parameters :
		-f ${FilesLocation} : input files location, path to 03_GenesFaa
		-t 16 : threads
		-n ${Genus} : name for the output diresctory -> ${Genus}_Results

`04_FetchAndConcat2.py `:
python script to prune the OG alignments -> Writes all the pruned OGs and the concatenated alignment

Positions in the alignments with >50% gaps "-" are removed.

