# This script only works in Linux shells, mac OSX may not completely compatible.


for j in {5,10,20,40,60,80,100,120,140,160,180,200,220,240,260,280,300}; do 

cd $j

cat *.500.txt|cut -f 1|sort|uniq >tmp0.out
n=0
k=1

`rm test1`

 for i in `ls *.500.txt`

 do

 
 echo "awk -F \"\\t\" 'NR==FNR{b=NF-1;first = \$1;\$1 = \"\"; a[first]=\$0;}NR>FNR{if(\$1 in a){print \$0 \"\t\" a[\$1]}else{printf \$0\"\t\";{for(c=0;c<b;c++){printf \"0\t\"};printf \"\n\"} }}'  $i  tmp$((n++)).out >tmp$((k++)).out" >>test1
 
 sh test1

 done
cd ..

done
