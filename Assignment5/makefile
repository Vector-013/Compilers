all:
	bison -d expr.y
	flex expr.l
	g++ -o icgen expr.tab.c lex.yy.c intcodegen.cpp -lm

run: all
	./icgen < sample.txt > intcode.c
	g++ -o ic intcode.c
	./ic > output.txt

clean:
	rm -f expr.tab.c expr.tab.h lex.yy.c expr ic icgen expr.yy.c intcode.c output.txt
