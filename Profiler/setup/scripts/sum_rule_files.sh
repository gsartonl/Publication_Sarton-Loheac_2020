#!/bin/bash
echo -e "genome\tpathway\tsteps\tpercentScore"

pathGapmind=$1

	awk -F "\t"  '{OFS="\t"}{if($5=="all") print $1, $4,$6+$7+$8,(($6*1)+($7*1)+($8*0))/($6+$7+$8)}' ${pathGapmind}
