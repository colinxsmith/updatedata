#!/bin/bash

timelag=18 #Initially choose timelag so that the first date is 31-10-2017

for stock in $(awk '{for(i=1;i<NF;++i)print $i;}' names)
do
	echo $stock
	./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" |sed "/^ $/d"> $stock.dat
done

python grow.py |awk ' {if($NF == "null") {$NF=$(NF-1);print;}else{print;}} ' | awk ' {for(i=3;i<=NF;++i){if($i == "null") {$i=$(i-1);}else if($i/$(i-1)<0.02){$i*=100;}else if($i/$(i-1)>50){$i*=1e-2;}};print;} '> updated


mv update startnew
