CFLAGS = -g -Wall -ansi -pedantic

minil: mini_1.lex mini_1.y
	bison -d -v mini_1.y
	flex mini_1.lex	
	gcc mini_1.tab.c lex.yy.c -lfl -o minil
	rm -f lex.yy.c

clean:
	rm -f minil mini_1.tab.* mini_1.output *~ 
