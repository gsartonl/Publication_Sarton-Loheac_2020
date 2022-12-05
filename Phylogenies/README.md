###################### README ######################
##              whole genome phylogeny            ##
##
## @gsartonl 									  ##
## 10.06.2021									  ##
####################################################



For each phylogeny, the genomes of interest have been re-annotated with PROKKA
to get consistent annotations.
File names are identical to the respective locus-tags.
The strain name/number is used as locus tag.
Then orthologous groups are inferred with OrthoFinder. Single copy orthologous
groups are then aligned and merged into a single sequence per species.

The alignment was used to compute the phylogeny with IQTree http://www.iqtree.org/


+ ${Family} :

│  main directory for each family

├── GenomesFiles :

│	└─ + Genomes :

│		└─ genomes annotations and data from NCBI / IMG downloads

│

├── 01_GenomesFNA :

│	│  cmd ```for FILE in $(find . )|grep -v 'interge' |grep -v 'genomic'|grep -v 'genes'| grep 'fna') ; do cp  ${FILE} ../GenomesFNA ; done ```

│	│

│	└── .fna files from all genomes that will be included in to the phylogeny

│
├── 02_PROKKA :
│	│  cmd ```sbatch 01_doAnnotation.sh```
│	│  Genomes are annotated with (most of the time) their strain name/number as locus-tags.
│	│  Directories names are .fna name of the samples.
│	│  Prokka output files have same identifier as the locus-tag -> ie strain name/number
│	└─ + Genomes :
│		└─ genomes are re-annotated with porkka to have consistency among the annotations
│
├── 03_GenesFaa :
│	│  cmd ```sbatch 02_OrthoFinder.sh -> for FILE in $(find ${AnnotationsDir} | grep -v 'Data' | grep -v 'intergenic' | grep -v 'genes' | grep -v 'Ga' | grep 'faa') ; do cp ${FILE} ${FilesLocation} ; done```
│	│
│	└─ .faa files : annotation files of all the samples
│
├── 04_Aligned_OG :
│	│  cmd ``` sbatch 03_AlignOrthologousGroups.sh ```
│	│  Each OG sequences are aligned
│	│
│	└─ OGxx_aligned.fa files :
│
├── 05_Whole_Alignments :
│	│  The pruned alignments for each orthogroup are available.
│	│  The concatenation of all the aligned OG (per species) is the Core Gene alignment
│	│
│	│  cmd ```python3 ./scripts/04_FetchAndConcat2.py 04_Aligned_OG 05_Whole_Alignments ```
│	│ or  cmd ```sbatch 05_execPythonScript.sh ```
│	│
│	├─ CoreGeneAlignment.fasta : concatenated OG per species -> to use for phylogeny
│	└─ OGxx_aligned_prined.fasta files : single OG aligned and pruned
│
└──	 06_Results :
	│
	├─ OrthoFinder :
	│	└─ Results_${Family}
	│		├─ Single_Copy_Orthologue_Sequences : directory of interest
	│		└─ Other directories with orthofinder results -> orthogroups,
	│
	└─ phylogeny :
		│  cmd ```sbatch 06_execIQTREE.sh ```
		│
		├─ WGP_${Familiy}.contree : consensus tree with renamed samples.
		│  not only locus but complete species name + strain
		│
		└─ .contree ; .treefile .log ...

+ scripts
│
├── 03_AlignOrthologousGroups.sh : to align sequences
│	│
│	└─ parameters :
│		--amino : use amino-acids
│		--inputorder
│		--localpair
│		--maxiterate 1000
│
├── 01_doAnnotation.sh
│	│
│	├─ arrays :
│	│	- array SAMPLE : .fna file names
│	│	- array LocusTag : locus tag associated to .fna files (thy have to be in the same order as .fna file names)
│	│
│	└─ parameters :
│
│		--compliant
│		--evalue 0.01
│
├── 06_execIQTREE.sh :
│	│
│	├─ array :
│	│	- Genus : Genus names corresponding to the ${Family} directory name
│	│
│	└─ parameters :
│		-st AA
│		-nt 16
│		-bb 16
│		-seed 1234
│		-m TEST (to find the best model for the data)
│		-pre ${Family}_Phylogeny
│
├── 05_execPythonScript.sh :
│	│
│	│  For this script to work, we assume that the headers have a structure :
│	│  ${LocusTag}_000xx or ${LocusTag}_000xx|strain_name
│	│
│	└── parameters :
│		- arg1 : script
│		- arg2 : input directory -> path to 04_Aligned_OG
│		- arg3 : output directory -> path to 05_Whole_Alignments (scripts creates the outdir)
│		- arg4 : pipeNames -> set to TRUE if headers contains a pipe.
│
├── 02_OrthoFinder.sh :
│	│
│	└─ parameters :
│		-f ${FilesLocation} : input files location, path to 03_GenesFaa
│		-t 16 : threads
│		-n ${Genus} : name for the output diresctory -> ${Genus}_Results
│
└── 04_FetchAndConcat2.py :
	│  python script to prune the OG alignments.
	│  Positions in the alignments with >50% gaps "-" are removed.
	│  Writes all the pruned OGs
	└  Writes the concatenated alignment
