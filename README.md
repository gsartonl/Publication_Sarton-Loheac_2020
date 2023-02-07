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
