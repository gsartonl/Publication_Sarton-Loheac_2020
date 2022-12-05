### run macsyfinder on .faa files ##
## @gsartonl ##
## 220518 ##

inputFaa=$1
outDir=$2
modelDir=$3
model=$4
db_type=$5
cores=$6

echo $model
echo $db_type

cp -r ${inputFaa} ../../tmp_faa

for FILE in $(ls ../../tmp_faa) ; do

  macsyfinder -m ${model} all\
    --models-dir ${modelDir}\
    --db-type ${db_type}\
    --sequence-db ../../tmp_faa/${FILE}\
    -w ${cores}\
    -o ${outDir}/${FILE%.*} ;

done

rm -r ../../tmp_faa
