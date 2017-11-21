from sys import argv

basef=open('NULL.dat')
testf=open(argv[1])
here=open('scratch','w')
line=testf.readline()
while(1):
	lineb=basef.readline()
	if len(lineb)==0:break
	date= lineb.split()[0]
	if date in line.split():
		here.write(line)
		line=testf.readline()
		continue
	else:
		here.write(lineb)
