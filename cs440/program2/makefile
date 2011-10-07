paxi : hash.o
	lex paxi.l
	gcc -o paxi.o lex.yy.c -ll
	gcc -I. -L. -o test.o test.c hash.h hash.c

clean : 
	rm *.o
	rm *.a
	rm lex.yy.c

libhash : hash.o
	gcc -fPIC -c  -Wall hash.c
	ar rc libhash.a hash.o

lex.yy.c : 
	lex paxi.l
