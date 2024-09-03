start: a.out
	./a.out < ass3_22CS30039_22CS30050_test.c

a.out: lex.yy.c
	g++ lex.yy.c ass3_22CS30039_22CS30050.cpp

lex.yy.c:
	lex  ass3_22CS30039_22CS30050.l 

clean:
	rm a.out lex.yy.c