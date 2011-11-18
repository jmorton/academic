parser : lex.yy.c paxi.tab.c
	gcc  hash.c  paxi.tab.c  lex.yy.c  -o parser

clean : 
	rm lex.yy.c paxi.tab.h paxi.tab.c parser *.paxi

lex.yy.c : 
	lex paxi.l

paxi.tab.c :
	bison -t -d paxi.y

boolean.paxi : parser
	./parser < boolean.pax > boolean.paxi

loop.paxi : parser
	./parser < loop.pax > loop.paxi

string.paxi : parser
	./parser < string.pax > string.paxi

sample3.paxi : parser
	./parser < sample3.pax > sample3.paxi

sample4.paxi : parser
	./parser < sample4.pax > sample4.paxi

boolean : boolean.paxi
	ruby machine.rb boolean.paxi

loop : loop.paxi
	ruby machine.rb loop.paxi

string : string.paxi
	ruby machine.rb string.paxi

sample4 : sample4.paxi
	ruby machine.rb sample4.paxi

