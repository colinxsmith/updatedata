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
countlines NULL.dat
echo $? lines in file
timelag=21 #Initially choose timelag so that the first date is 31-10-2017
firstdate=`date --date=@$(echo $(($(date +%s)-$timelag*60*60*24)))`

echo $firstdate

edf=$(date +%u)
eds=$(date +%s)
echo $edf $eds
sdf=$(date +%u --date=@$(echo $(($(date +%s)-$timelag*60*60*24))))
sds=$(date +%s --date=@$(echo $(($(date +%s)-$timelag*60*60*24))))
echo $sdf $sds

datadiff $timelag $(date +%s)
echo Day difference should be $?

