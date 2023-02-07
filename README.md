# Publication_Sarton-Loheac_2022
Scripts associated with Sarton-Loheac et al. 2022

####################################################
Summary of scripts and usage


####################################################
#  DADA2


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

####################################################
# Whole genome phylogeny								 

For each phylogeny, the genomes of interest have been re-annotated with PROKKA to get consistent annotations.
File names are identical to the respective locus-tags.
The strain name/number is used as locus tag.
Then orthologous groups are inferred with OrthoFinder. Single copy orthologous groups were then aligned and merged into a single sequence per species.
The alignment was trimmed to remove bases with <50% coverage across samples.
The final alignment was used to compute the phylogeny with IQTree http://www.iqtree.org/


#######################
# Metabolic profiler

This is a snakemake pipeline combining several tools to assess the completeness of selected metabolic pathways.

For this pipeline to work, amino-acid fasta files of the genomes of interest are required.
amino-acid biosythesis pathway completeness require the installation of [PaperBLAST](https://github.com/morgannprice/PaperBLAST) and for the secretion systems [macsyfinder](https://github.com/gem-pasteur/macsyfinder) are necessary.

For the other pathways/modules a rule file was created, describing the pathway steps and the associated KO numbers. To get kegg annotations, we merged the amino-acid fasta files and uploaded them on https://www.kegg.jp/ghostkoala/ (! several merge-files may be necessary as there is a file size of up to 300 MB with the limit of 500,000 sequences).
This step can also be done locally if you have access to the kegg database

Ideally the locus-tags follow the format TAG_GeneNumber.


