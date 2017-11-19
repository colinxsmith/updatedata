#!/bin/bash

timelag=18 #Initially choose timelag so that the first date is 31-10-2017
ns=`./InternetPrice.exe colinsmith 23 | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`

for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
do
	echo $stock
	back=`./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
	echo back is $back
	if   [ "$back" = "$ns" ]; then echo yes; else echo no; fi
	if [ "$back" != "$ns" ] ; then
	echo Set up NULL.dat
	./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" |sed "/^ $/d"| awk '{for(i=1;i<=NF;++i){printf("%s ",i==1?$i:"null");}printf("\n");}' | sed "s/\r//g" | sed "/^ $/d" >NULL.dat
	break
else
	echo problem stock $stock
fi

done

for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
do
	echo $stock
	./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d" > $stock.dat
done

python grow.py |awk ' {if($NF == "null") {$NF=$(NF-1);print;}else{print;}} ' | awk ' {for(i=3;i<=NF;++i){if($i == "null") {$i=$(i-1);}else if($i/$(i-1)<0.02){$i*=100;}else if($i/$(i-1)>50){$i*=1e-2;}};print;} '|sed "s/\r//g"> updated


