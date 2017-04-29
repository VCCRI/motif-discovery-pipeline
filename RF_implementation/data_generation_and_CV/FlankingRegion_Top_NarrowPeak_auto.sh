for i in `ls *.bed`;do head -n 500 $i >$i.500.txt ;done

for j in {5,10,20,40,60,80,100,120,140,160,180,200,220,240,260,280,300}; do 

mkdir $j

for i in `ls *.bed.500.txt`;do awk '{print $1"\t"$2+$10-"'$j'""\t"$2+$10+"'$j'"}' $i >./$j/$i.txt ;done

done

rm *.txt


