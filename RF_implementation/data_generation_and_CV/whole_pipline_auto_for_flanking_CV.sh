for j in {5,10,20,40,60,80,100,120,140,160,180,200,220,240,260,280,300}; do 

cd $j

sh ../../data_generation_and_CV/peaks_auto_pip.sh hg19 ../../../motifDB/ENCODE_ChIPmotifsHUMAN_tcf.motif

cd ..

done

