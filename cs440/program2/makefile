build : hash.o paxi.o test

clean : 
	rm paxi
	rm test
	rm hash.o
	rm lex.yy.c
	rm libhash.a

libhash : hash.o
	gcc -fPIC -ggdb -c  -Wall hash.c
	ar rc libhash.a hash.o

paxi.o : hash.o lex.yy.c tokens.h
	gcc -ggdb -o paxi lex.yy.c -ll

test: libhash
	gcc -I. -L. -g -o test test.c hash.h hash.c -lhash

lex.yy.c : 
	lex paxi.l
