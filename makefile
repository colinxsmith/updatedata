CSC=mcs
InternetPrice.exe:	InternetPrice.cs
	$(CSC) -out:$@ -pkg:dotnet -platform:anycpu InternetPrice.cs
clean:
	$(RM) *.exe
all:
	for i in `sed -n "s/exe:.*/exe/p" makefile |sed -n "/\./p"`; do if [ $$i != .exe ] ; then echo $$i;make -f makefile $$i; fi; done
