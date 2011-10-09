CC     = gcc
DEBUG  = -g
CFLAGS = -Wall -c $(DEBUG)
LFLAGS = -Wall $(DEBUG)
OBJS   = list.o list_tests.o
srcdir = src

.PHONY: clean tags

all: test

assembler: list0.s list3.s

test: $(OBJS)
	$(CC) $(LFLAGS) $(OBJS) -o test

list.o:  $(srcdir)/list.h $(srcdir)/list.c
	$(CC)  -I$(srcdir)  $(CFLAGS)  $(srcdir)/list.c

list_tests.o:  src/list.h  src/list.o  src/list_tests.c
	$(CC)  -I$(srcdir)  $(CFLAGS)  $(srcdir)/list_tests.c

list0.o:
	gcc -ggdb -O0 -o list0.o -c list.c

list3.o:
	gcc -ggdb -O3 -o list3.o -c list.c

list0.s: list0.o
	otool -tv list0.o > list0.s

list3.s: list3.o
	otool -tv list3.o > list3.s

clean:
	\rm -f $(only_targets *) test *.o *.s

tags:	*.c
	etags *.c

