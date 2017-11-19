olddata=open('startnew')
namesf=open('names')
names=namesf.readline().split()

while(1):
	line=olddata.readline()
	if len(line)==0:break
	prices=line.split()
	stock=prices[0]
	if stock in names:
		newdat=open(stock+'.dat')
		linenew=''
		while(1):
			newdatl=newdat.readline()
			if len(newdatl)<=2:break
                        try:
                            pr=newdatl.split()
			    linenew+=pr[1]+' '
                        except:pass
		print line.strip()+' '+linenew.strip()
		newdat.close()
olddata.close()
