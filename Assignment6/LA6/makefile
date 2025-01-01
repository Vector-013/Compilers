all: y.tab.o lex.yy.o codegen.o
	g++ y.tab.o lex.yy.o codegen.o

y.tab.o: y.tab.c
	g++ -c y.tab.c

y.tab.c: prog.y
	yacc -d prog.y

lex.yy.o: lex.yy.c
	g++ -c lex.yy.c

lex.yy.c: prog.l
	flex prog.l

codegen.o: codegen.cpp
	g++ -c codegen.cpp

run: all
	./a.out < sample.txt
	@echo "\nIntermediate Code is stored in intermediate_code.txt"
	@echo "Target Code is stored in target_code.txt"

clean:
	rm -f a.out y.tab.o y.tab.c y.tab.h lex.yy.o lex.yy.c codegen.o intermediate_code.txt target_code.txt