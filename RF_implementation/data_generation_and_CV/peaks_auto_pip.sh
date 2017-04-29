#!/bin/bash  
#  Author: Xin Wang  flyboyleo@gmail.com

# run this script in a folder named with TF name and included "sample_name".txt as peak file in. 

if [ -z "$2" ] 
then
echo "#Usage : path/peaks_auto_pip.sh <mm10/hg19/mm9/hg18/rn5> <motif file>"
exit
fi
#USAGE="#Usage : path/merge_table_auto.sh 10 /tmp/notbackedup/Xin_tmp_data/tcf7l2_narrowPeak size100bin <motif file> <Homer path>"

InM=$(basename $3)
M=${InM%.*}

for i in `ls *.txt`

do

 name=${i%.*}

 mkdir $name

 cp $i ./$name

 cd ./$name

../../../../find-motifs/ChIP_pip_fromPeakfile.sh $1 $i $2 11 5  &

cd ..

done


