#!/bin/bash

function countlines  { #Number of lines in a file
    line=0
    for dd in $(awk '{print $1}' $1)
    do 
		line=$((line+1))
	done
    return $line
}
function datadiff { #The number of data items in a time interval
	tlag=$1
	endp=$2
	startp=`date +%s --date=@$(echo $(($endp-60*60*24*$tlag)))`
	endpd=$(date +%u --date=@$(echo $endp))
	endps=$(date +%Y-%m-%d --date=@$(echo $endp))
	echo $endps $endpd

	startpd=$(date +%u --date=@$(echo $startp))
	startps=$(date +%Y-%m-%d --date=@$(echo $startp))
	echo $startps $startpd
	if [ $startpd -gt 5 ];then
		startpd=5
	fi
	daydiff=$(($endpd-$startpd))
	if [ $daydiff -lt 0 ] ; then
		daydiff=$(($daydiff+5))
	fi
	return $(($tlag/7*5+$daydiff))
}


timelag=$((($(date +%s)-$(date +%s --date='2017-10-31'))/60/60/24))

#timelag=22 #Initially choose timelag so that the first date is 31-10-2017

#if [ $(date +%u) == "1" ]; then timelag=3 ;fi  #Monday
#if [ $(date +%u) == "2" ]; then timelag=1 ;fi  #Tuesday
#if [ $(date +%u) == "3" ]; then timelag=1 ;fi  #Wednesday
#if [ $(date +%u) == "4" ]; then timelag=1 ;fi  #Thursday
#if [ $(date +%u) == "5" ]; then timelag=1 ;fi  #Friday

firstdate=`date +%Y-%m-%d --date=@$(echo $(($(date +%s)-$timelag*60*60*24)))`
echo $firstdate
fd=`date +%s --date=$firstdate`

#set up the "No symbol" string
ns=`./InternetPrice.exe colinsmith 23 | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
nullset=0
expectedline=0
publicholidaysininterval=0

while [ $nullset = 0 ] 
do
	datadiff $timelag $(date +%s)
	expectedline=$?
	echo nullset $nullset timelag $timelag expect $expectedline lines in data file
	#create the file of nulls for missing symbol
	for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
	do
		echo $stock
		back=`./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
		echo back is $back
		if [ "$back" != "$ns" ] ; then
		echo Set up NULL.dat
		./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" |sed "/^ $/d"| awk '{for(i=1;i<=NF;++i){printf("%s ",i==1?$i:"null");}printf("\n");}' | sed "s/\r//g" | sed "/^ $/d"| awk 'BEGIN{keep=0;}{if(keep!=$1){keep=$1;print;}}' >NULL.dat
		countlines NULL.dat
		nline=$?
		nline=$((nline+$((publicholidaysininterval))))
		if [ "$nline" -ge "$expectedline" ] ; then
		echo Accept NULL data file
		nullset=1
		break
		else
			echo problem amount of data $stock
		fi
		else
			echo problem stock $stock
		fi

	#Now we can get the data files sorted out
	done
	if [ $nullset = 0 ] ; then
	publicholidaysininterval=$((publicholidaysininterval+1))
	echo We must increase publicholidaysininterval to $publicholidaysininterval
	fi
done


for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
do
	echo $stock
	echo $ns > $stock.dat
	./InternetPrice.exe $stock $timelag|sed "s/\.0*,/.0,/g" | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d" |awk 'BEGIN{keep=0;}{if(keep!=$1){keep=$1;print;}}' > $stock.dat
	
	back=`cat $stock.dat`
	if [ "$back" = "$ns" ] ; then
		echo bad stock $stock
		cp -p NULL.dat $stock.dat
	else
		countlines $stock.dat
		nline=$?
		nline=$((nline+$((publicholidaysininterval))))
		if [ $nline != $expectedline ];then #need to put more lines in the file
			echo pad $stock.dat with nulls $nline
			python padf.py $stock.dat
			cp -p scratch $stock.dat
		fi
	fi
	#Get rid of data items younger than firstdate if there are any
	for dd in $(awk  '{print $1}' $stock.dat)
	do 
		ddp=`date +%s --date=$dd`
		if [ $ddp -lt $fd ]; then 
			echo $dd $stock.dat
			sed -i "/$dd/d" $stock.dat
		fi
	done
done

#Append the new data to the old
python grow.py startnew names |awk '{for(i=3;i<=NF;++i){	if($i == "null" || $i=="0") 	{		$i=$(i-1);	}}print;}' | awk ' {for(i=3;i<=NF;++i){if($i/$(i-1)<0.02){$i*=100;}else if($i/$(i-1)>50){$i*=1e-2;}};print;} '|sed "s/\r//g"> updated

mv startnew startnew.prev
cp -p updated startnew

awk '{ns=0;for(i=NF;i>3;i--){if($(i-1)==$i){ns++;}else{break;}}if(ns<NF*0.5)print $0}' updated > corrected

NF=$(awk 'END{print NF}' startnew)
awk -vFF=$NF 'BEGIN{check=FF}{if(NF!=check)print "Bad",$1}' startnew
