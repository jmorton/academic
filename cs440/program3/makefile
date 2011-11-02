parser : lex.yy.c paxi.tab.c
	gcc  hash.c  paxi.tab.c  lex.yy.c  -o parser

clean : 
	rm lex.yy.c paxi.tab.h paxi.tab.c parser boolean.paxi

lex.yy.c : 
	lex paxi.l

paxi.tab.c :
	bison -t -d paxi.y

boolean.paxi : parser
	./parser < boolean.pax > boolean.paxi

sample3.paxi : parser
	./parser < sample3.pax > sample3.paxi

make boolean : boolean.paxi
	ruby machine.rb boolean.paxi
