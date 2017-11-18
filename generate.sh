#!/bin/bash

for stock in $(awk '{for(i=1;i<NF;++i)print $i;}' names)
do
	echo $stock
	./InternetPrice.exe $stock 18 | awk -F, '{print $1,$5}' |sed "/Close/d" > $stock.dat
done

