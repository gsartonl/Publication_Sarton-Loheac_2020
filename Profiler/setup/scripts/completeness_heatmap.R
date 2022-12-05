#!/usr/bin/env RScript


all_species <- read.delim(snakemake@input[['all_sp_score']], header = T, sep = "\t")



library(gplots)
library(RColorBrewer)
library(readr)
library(plyr)
library(tidyverse)
#library(devtools)
#library(unix)
#rlimit_as(3e11)

sink(snakemake@log[[1]])
# set working directory
setwd(snakemake@input[['workingDir']])

##----------------------
# Load data and generate matrix for heatmap
##----------------------

all_species <- read.delim(snakemake@input[['all_sp_score']], header = T, sep = "\t")

#all_species <- read.delim('~/Documents/PhD/Collaborations/21_Philipp/Profiler/all_completeness_scores.txt', header = T, sep = "\t" )
#keep all columns except for 'steps'
all_species <- all_species %>% select( -c("steps"))
unique(all_species$functions)

#generate matrix out of 'score with genome' vs 'functions'
all_species_wide <- spread(all_species,genome, percentScore) %>% column_to_rownames(var="pathway") %>% as.matrix()
#all_species_wide <- spread(all_species, genome, percentScore) %>% column_to_rownames(var="pathway") %>% as.matrix()
#Reordering columns
species_order <- as.character(unlist(read.table(snakemake@input[['genome_order']], sep=',', header=F)[1,]))
pathway_order <- as.character(unlist(read.table(snakemake@input[['pathways_order']], sep=',', header=F)[1,]))
#print(colnames(all_species_wide)%in%species_order)



#Reordering rows
all_species_wide <- all_species_wide[order(match(rownames(all_species_wide), pathway_order)), , drop = FALSE]
all_species_wide=t(all_species_wide)
all_species_wide <- all_species_wide[order(match(rownames(all_species_wide), species_order)), , drop = FALSE]

##----------------------
#Generate heatmap
##----------------------

mat_data <- (all_species_wide) # transform column 2-5 into a matrix
my_palette <- colorRampPalette(c("white", "darkred"))( n = 89)
col_breaks = c(seq(1,9,length=30),  # for red
               seq(0.89,0.6,length=30),           # for yellow
               seq(0.59,0,length=30))            # for green

col_breaks = c(seq(0,0.59,length=30),seq(0.6,0.89,length=30),seq(0.9,1,length=30))

#png(file= snakemake@output[['outGraph']], width = 900, height = 2500, units = "px", pointsize = 12 )
pdf(snakemake@output[['outGraph']], width=10, height=10)
heatmap.2(all_species_wide,
        #cellnote = round(all_species_wide, digits = 2),  # same data set for cell labels
        main = "Completeness of functions across genomes", # heat map title
        notecol="black",      # change font color of cell labels to black
        key.xlab = "Proportion complete",
        key.title = "Pathway completeness",
        lhei=c(0.25,1), lwid=c(0.25,1), keysize=0.25,
        density.info="none",
        trace="none",         # turns off trace lines inside the heat map
        margins = c(10, 10),     # widens margins around plot
        col=my_palette,
        breaks=col_breaks,    # enable color transition at specified limits
        sepcolor="white",
        sepwidth=c(0.05,0.05),
        colsep=1:ncol(all_species_wide),
        rowsep=1:nrow(all_species_wide),
        Rowv = FALSE,
        Colv = FALSE,
        dendrogram="none")
warnings()
dev.off()
