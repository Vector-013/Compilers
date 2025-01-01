start:
	clear
	rm -f poly.tab.c poly.tab.h lex.yy.c poly output.txt
	bison -d poly.y -Wcounterexamples
	flex poly.l
	g++ -o poly poly.tab.c lex.yy.c polyutils.cpp -lm
	./poly < sample.txt
	rm -f poly.tab.c poly.tab.h lex.yy.c poly