#!/usr/bin/env python3
####################################################
				# @gsartonl
				# 08.06.2021
####################################################

############# python sed function #############
# input :
## argv[1] : If 'True' : change strings in file using correspondance file. If 'False' change a single
###			 string/pattern in file. Default is False
## argv[2] : file where names should be changed (include path ! )
## argv[3] : output name (only file name)
## argv[4] : table with names correspondance OR new string
## argv[5] : old pattern if False

import sys
import os
from os import path
import pandas as pd
import numpy as np

FileToWrite=""
def isFormated(file, oldString) :
    with open(file, 'r') as hasDash :
        DashCount = hasDash.read().count(oldString)
        if DashCount==0 :
            return(True)
        else :
            return(False)

with open(snakemake.log[0], "w") as f:
    sys.stderr = sys.stdout = f
    print('log')

    FP = snakemake.input["gostkoala_in"]

    ChangeIn = snakemake.params["fromFile"]
    print(ChangeIn)


    FilePath = os.path.dirname(FP)

    OutName = snakemake.output["gostkoala_out"]

    oldStrings = snakemake.params["oldStrings"]
    newStrings = snakemake.params['newStrings']


    print('isFormated %s' % isFormated(FP, oldStrings))

    if isFormated(FP, oldStrings) == True :
        print('--- If loop')
        with open(OutName, 'w') as FW :
            FW.write(FP)

    else :
        print('--- Else loop')
        if ChangeIn == 'False' :
            print('---- changeIn==false')
            with open (FP, 'r') as fileToModify :
                LINES = fileToModify.readlines()
                for line in LINES :
                    print(line.count('_') >=2)

                    if (line.count('_') >= 2) :
                        print('TRRRUE')

                        print('_'.join(line.split(oldStrings)[0:2]))
                        newLine='_'.join(line.split(oldStrings)[0:2]) + '\t' + ''.join(line.split(oldStrings)[2:])



                    else :
                            newLine=line.replace(oldStrings, newStrings)

                    FileToWrite+=newLine

                print(FileToWrite)
                # with open(OutName, 'w') as FW :
                #     FW.write(FileToWrite)


        elif ChangeIn == 'True' :

            i=0
            data = pd.read_excel(snakemake.params["oldStrings"], dtype=str)
        #data = pd.read_excel('/Users/garancesarton-loheac/Documents/PhD/Phylogenies/ForPublication/Gilliamella/GilliamellaGenomesDB.xlsx' ,dtype=str)
            data['CompleteName'] = data['Species'] + ' ' + data['Strain_name']
            locusTags = data['Locus_tag']
       # with open (sys.argv[2], 'r') as FM :
            with open (FP, 'r') as FM :
                fileToModify = FM.read()
                first='True'
                for tag in locusTags :
                    if first=='True' :
                        FileToWrite = fileToModify.replace(tag,  data[data['Locus_tag']==tag] ['CompleteName'].to_string().split('    ')[1])
                        first='False'
                    else :

                        FileToWrite = FileToWrite.replace(tag, data[data['Locus_tag']==tag] ['CompleteName'].to_string().split('    ')[1])





        else :
            print('Incorrect argument. Argument is False for single pattern replacement is True for multiple pattern replacement')

        with open(OutName, 'w') as FW :
            FW.write(FileToWrite)
