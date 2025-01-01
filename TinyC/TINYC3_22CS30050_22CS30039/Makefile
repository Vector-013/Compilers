parser.out: lex.yy.o y.tab.o TinyC3_22CS30050_22CS30039_translator.o
	g++ -g lex.yy.o y.tab.o TinyC3_22CS30050_22CS30039_translator.o -o parser.out

TinyC3_22CS30050_22CS30039_translator.o: TinyC3_22CS30050_22CS30039_translator.cxx TinyC3_22CS30050_22CS30039_translator.h
	g++ -g -c TinyC3_22CS30050_22CS30039_translator.cxx

lex.yy.o: lex.yy.c
	g++ -g -c lex.yy.c

y.tab.o: y.tab.c
	g++ -g -c y.tab.c

lex.yy.c: TinyC3_22CS30050_22CS30039.l y.tab.h TinyC3_22CS30050_22CS30039_translator.h
	flex TinyC3_22CS30050_22CS30039.l

y.tab.c y.tab.h: TinyC3_22CS30050_22CS30039.y
	bison -dty --report=all TinyC3_22CS30050_22CS30039.y

clean:
	rm parser.out TinyC3_22CS30050_22CS30039_translator.o lex.yy.* y.tab.* y.output TinyC3_22CS30050_22CS30039_quads*.out

test: parser.out
	@echo "Running Test 1:"
	./parser.out < TinyC3_22CS30050_22CS30039_test1.c > TinyC3_22CS30050_22CS30039_quads1.out
	@echo "Test output is in TinyC3_22CS30050_22CS30039_quads1.out"

	@echo "Running Test 2:"
	./parser.out < TinyC3_22CS30050_22CS30039_test2.c > TinyC3_22CS30050_22CS30039_quads2.out
	@echo "Test output is in TinyC3_22CS30050_22CS30039_quads2.out"

	@echo "Running Test 3:"
	./parser.out < TinyC3_22CS30050_22CS30039_test3.c > TinyC3_22CS30050_22CS30039_quads3.out
	@echo "Test output is in TinyC3_22CS30050_22CS30039_quads3.out"

	@echo "Running Test 4:"
	./parser.out < TinyC3_22CS30050_22CS30039_test4.c > TinyC3_22CS30050_22CS30039_quads4.out
	@echo "Test output is in TinyC3_22CS30050_22CS30039_quads4.out"

	@echo "Running Test 5:"
	./parser.out < TinyC3_22CS30050_22CS30039_test5.c > TinyC3_22CS30050_22CS30039_quads5.out
	@echo "Test output is in TinyC3_22CS30050_22CS30039_quads5.out"
