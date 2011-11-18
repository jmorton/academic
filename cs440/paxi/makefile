parser : lex.yy.c paxi.tab.c
	gcc  hash.c  paxi.tab.c  lex.yy.c  -o parser

clean : 
	rm lex.yy.c paxi.tab.h paxi.tab.c parser *.paxi

lex.yy.c : 
	lex paxi.l

paxi.tab.c :
	bison -t -d paxi.y

boolean.paxi : parser
	./parser <  examples/boolean.pax >  examples/boolean.paxi

loop.paxi : parser
	./parser <  examples/loop.pax >  examples/loop.paxi

string.paxi : parser
	./parser < examples/string.pax > examples/string.paxi

sample3.paxi : parser
	./parser < sample3.pax > sample3.paxi

sample4.paxi : parser
	./parser < examples/sample4.pax > examples/sample4.paxi

boolean : boolean.paxi
	ruby machine.rb  examples/boolean.paxi

loop : loop.paxi
	ruby machine.rb  examples/loop.paxi

string : string.paxi
	ruby machine.rb  examples/string.paxi

sample4 : sample4.paxi
	ruby machine.rb  examples/sample4.paxi

