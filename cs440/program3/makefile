parser : lex.yy.c paxi.tab.c
	gcc  paxi.tab.c  lex.yy.c  -o parser

clean : 
	rm lex.yy.c paxi.tab.h paxi.tab.c parser

lex.yy.c : 
	lex paxi.l

paxi.tab.c :
	bison -d paxi.y