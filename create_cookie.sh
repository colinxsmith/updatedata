rm history
wget --save-cookies cookie_file https://uk.finance.yahoo.com/quote/ANTO.L/history

cookie=$(awk '/yahoo/{print $6"="$7}' cookie_file)

crumb=$(awk -F, '/CrumbStore/{for(i=1;i<NF;++i){print $i}}' history|sed -n "/Crumb/p" | awk -F\" '{print $6}')



line=$(echo string crumb=\"$crumb\",cookie=\"$cookie\"\;)
echo $line

sed -i "/string crumb=/c \$$line" InternetPrice.cs
sed -i "s/^\\$/\t\t\t/" InternetPrice.cs

