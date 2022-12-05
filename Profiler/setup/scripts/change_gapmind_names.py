#!/usr/bin/env python3
## change local hash to file names ##
## @gsartonl ##

## modules ##
import pandas as pd

## inputs ##
inputFile = snakemake.input[0]
pathOrgDB = snakemake.input[1]

summary = snakemake.output[0]

## core ##

orgDB = (pd.read_table(pathOrgDB, sep="\t"))

tmporgDB = (orgDB[['orgId', 'genomeName']])

OrgDict = dict(zip(orgDB.orgId, orgDB.genomeName))
print(OrgDict)
tmpgapmindAA = pd.read_table(inputFile, sep="\t")
gapmindAA = tmpgapmindAA.replace(OrgDict)
gapmindAA['genome'] = gapmindAA['genome'].str.replace('.faa', '')


gapmindAA.to_csv(summary, sep='\t',index=False)
