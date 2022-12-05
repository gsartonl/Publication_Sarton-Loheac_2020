#!/bin/python3

import re
import os
import pandas as pd
import numpy as np


## script to parse macsyfinder results and output pathway completeness ##


inPath=snakemake.input['inPath']
outFile=snakemake.output['outFile']


ResDirs=os.listdir(inPath)

allSys=[d + '/all_systems.txt' for d in ResDirs]
uncompletesSys=[d + '/uncomplete_systems.txt' for d in ResDirs]




# Complete='/Users/garancesarton-loheac/Documents/PhD/Collaborations/0821_Philipp/macsyfinder/all_systems.txt'
# Uncomplete='/Users/garancesarton-loheac/Documents/PhD/Collaborations/0821_Philipp/macsyfinder/uncomplete_systems.txt'

# systemsList = ['Flagellum', 'pT4SSi', 'pT4SSt', 'T1SS', 'T2SS', 'T3SS', 'T4P',
              # 'T4SS_typeB', 'T4SS_typeC', 'T4SS_typeF', 'T4SS_typeG', 'T4SS_typeI',
              # 'T4SS_typeT', 'T5aSS', 'T5bSS', 'T5cSS', 'T6SSiii', 'T6SSii',
              # 'T6SSi', 'T9SS', 'Tad']


def SysCompleteness(FILE, sysDict) :

    with open(inPath+'/'+FILE, 'r') as macsyRes :
        res=macsyRes.readlines()

    mandatoryCount=False
    for line in res :

        if line.startswith('model =') :

            system=line.rstrip().split('/')[1]
            sysDict[system]={}

        elif line.startswith('accessory') :

            sysDict[system]['steps']= mandatorySteps
            mandatoryCount=False
            #system is true
        elif mandatoryCount==True :
            if line!='\n' :
                mandatorySteps+=1

        elif line.startswith('wholeness') :

            sysDict[system]['percentScore'] = line.rstrip().split(' ')[2]

        elif line.startswith('mandatory') :

            mandatorySteps=0
            mandatoryCount=True

    return(sysDict)



### MAIN ###
master=pd.DataFrame()

for strain in ResDirs :
    if(strain=='orgfile') :
        continue
    tmpSysDict={}
    allSys= strain + '/all_systems.txt'
    uncompletesSys= strain + '/uncomplete_systems.txt'
    try:
        open(inPath + '/' + allSys)
    except NotADirectoryError:
        continue

    print((inPath + '/' + allSys))
    SysDict=SysCompleteness(FILE=allSys, sysDict=tmpSysDict)
    SysDict=SysCompleteness(FILE=uncompletesSys, sysDict=SysDict)

    df =pd.DataFrame.from_dict(SysDict,orient='index')
    df['pathway'] = df.index
    df['genome']=np.repeat(strain,df.shape[0])
    master=pd.concat([master,df])

    master=master[['genome', 'pathway', 'steps', 'percentScore' ]]
    #master = master.iloc[: , 1:]
print('writing result file')
master.to_csv(outFile, sep='\t', index=False)
