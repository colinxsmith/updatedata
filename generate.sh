
if [ $(date +%u) == "1" ]; then timelag=3 ;fi  #Monday
if [ $(date +%u) == "2" ]; then timelag=1 ;fi  #Tuesday
if [ $(date +%u) == "3" ]; then timelag=1 ;fi  #Wednesday
if [ $(date +%u) == "4" ]; then timelag=1 ;fi  #Thursday
if [ $(date +%u) == "5" ]; then timelag=1 ;fi  #Friday


#set up the "No symbol" string
ns=`./InternetPrice.exe colinsmith 23 | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
nullset=0

while [ $nullset = 0 ] 
do
	echo nullset $nullset timelag $timelag
	#create the file of nulls for missing symbol
	for stock in $(awk '{for(i=1;i<=NF;++i)print $i;}' names)
	do
		echo $stock
		back=`./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" | sed "s/\r//g" | sed "/^ $/d"`
		echo back is $back
		if [ "$back" != "$ns" ] ; then
		echo Set up NULL.dat
		./InternetPrice.exe $stock $timelag | awk -F, '{print $1,$5}' |sed "/Close/d" |sed "/^ $/d"| awk '{for(i=1;i<=NF;++i){printf("%s ",i==1?$i:"null");}printf("\n");}' | sed "s/\r//g" | sed "/^ $/d" >NULL.dat
		nullset=1
		break
		else
			echo problem stock $stock
		fi

	#Now we can get the data files sorted out
	done
	if [ $nullset = 0 ] ; then
	timelag=$((timelag+1))
	echo We must increase timelag to $timelag
	fi
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
python grow.py startnew names |awk '{for(i=3;i<=NF;++i){	if($i == "null" || $i=="0") 	{		$i=$(i-1);	}}print;}' | awk ' {for(i=3;i<=NF;++i){if($i/$(i-1)<0.02){$i*=100;}else if($i/$(i-1)>50){$i*=1e-2;}};print;} '|sed "s/\r//g"> updated

mv startnew startnew.prev
cp -p updated startnew

awk '{ns=0;for(i=NF;i>3;i--){if($(i-1)==$i){ns++;}else{break;}}if(ns<NF*0.5)print $0}' startnew > corrected

