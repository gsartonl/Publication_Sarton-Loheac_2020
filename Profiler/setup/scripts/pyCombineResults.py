#!/usr/bin/env python3
####################################################
				# @gsartonl
				# 08.06.2021
####################################################

############# combining outputs #############


gapmind = snakemake.input['gapmind']
KO = snakemake.input['KO']
macsyfinder = snakemake.input['macsyfinder']
pattern = snakemake.input['StrainPattern']


def hasHeaders(line, pattern) :
	if line.startswith(pattern) :
		return(False)
	else :
		return(True)

def readResultFiles(path) :
	with open (path, 'r') as results:
		header = results.readline()
		if hasHeaders(header, pattern)==True :
			main = results.read()
			return {'header' : header, 'main' : main}
		else :
			main = header + results.read()
			return {'main' : main}

def combineData (result1, result2, result3) :
	header = result1['header']
	data = result1['main'] + result2['main'] + result3['main']
	merged = header + data
	return(merged)

ResultsGapmind = readResultFiles(gapmind)
ResultsKO = readResultFiles(KO)
ResultsMacsyfinder = readResultFiles(macsyfinder)



if len(ResultsGapmind) == 2 :
	merged = combineData(ResultsGapmind, ResultsKO, ResultsMacsyfinder)

elif len(ResultsKO) == 2 :
	merged = combineData(ResultsKO, ResultsMacsyfinder, ResultsGapmind)

elif len(ResultsMacsyfinder) == 2 :
	merged = combineData(ResultsMacsyfinder, ResultsGapmind, ResultsKO)

else :
	header = 'genome\tpathway\tsteps\tpercentScore\n'
	main = ResultsGapmind['main'] + ResultsKO['main'] + ResultsMacsyfinder['main']
	merged = header + main

with open(snakemake.output['all_scores'], 'w') as outputFile :
	outputFile.write(merged)
