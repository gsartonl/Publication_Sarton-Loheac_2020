#!/bin/bash

#copy .rule files in the main directory

pathGapmind=$1
echo ${pathGapmind}

#cp ${pathGapmind}/**/*.rules ${pathGapmind}/

for FILE in $(ls ${pathGapmind}/**/*.rules); do 
	cp ${FILE} ${pathGapmind}/$(basename ${FILE}) ; 
done

