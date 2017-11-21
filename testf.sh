function countlines  {
  line=0
  for dd in $(awk '{print $1}' $1)
  do 
      line=$((line+1))
  done
  return $line
}

    countlines NULL.dat
    echo $?
    timelag=21 #Initially choose timelag so that the first date is 31-10-2017
    firstdate=`date --date=@$(echo $(($(date +%s)-$timelag*60*60*24)))`

    echo $firstdate
