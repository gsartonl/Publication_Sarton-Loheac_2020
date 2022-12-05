#!/usr/bin/env python3
## Format input file for profiler -> gapmind ##
## @gsartonl ##

## Currently doesn't add tax. Might be updated later

### uses path to faa files and metadata table to assign taxonomy to isolates
### the metadatafile needs to have a column called 'Species'

### modules ###
import os

### inputs ###

pathToFaas=snakemake.input[0]
outFile=snakemake.output[0]



### Core code ###

try :
    os.remove(pathToFaas + '/.DS_Store')
except FileNotFoundError :
    pass


files=os.listdir(pathToFaas)
tmpformat=['file:' + pathToFaas + '/' + f + ":" + f for f in files]



with open(outFile,'w') as outf :
    outf.write("\n".join(tmpformat))

print('Writing file')
