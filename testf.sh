function countlines  {
    echo $1
    line=0
    for dd in $(awk '{print $1}' $1);do line=$((line+1));done
    return $line
    }
    countlines NULL.dat
    echo $?
