#!/bin/bash

timelag=20 #Initially choose timelag so that the first date is 31-10-2017

#set up the "No symbol" string
ns=`./InternetPrice.exe colinsmith 23 | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`

#create the file of nulls for missing symbol
for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
do
	echo $stock
	back=`./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
	echo back is $back
	if [ "$back" != "$ns" ] ; then
	echo Set up NULL.dat
	./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" |sed "/^ $/d"| awk '{for(i=1;i<=NF;++i){printf("%s ",i==1?$i:"null");}printf("\n");}' | sed "s/\r//g" | sed "/^ $/d" >NULL.dat
	break
else
	echo problem stock $stock
fi

#Now we can get the data files sorted out
done

for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
do
	echo $stock
	./InternetPrice.exe $stock $timelag|sed "s/\.0*,/.0,/g" | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d" > $stock.dat
	back=`cat $stock.dat`
	if [ "$back" = "$ns" ] ; then
		echo bad stock $stock
		cp -p NULL.dat $stock.dat
	fi

done

#Append the new data to the old
python grow.py yahoostart names |awk '{for(i=3;i<=NF;++i){	if($i == "null" || $i=="0") 	{		$i=$(i-1);	}}print;}' | awk ' {for(i=3;i<=NF;++i){if($i/$(i-1)<0.02){$i*=100;}else if($i/$(i-1)>50){$i*=1e-2;}};print;} '|sed "s/\r//g"> updated

mv startnew startnew.prev
cp -p updated startnew
