CFLAGS = -g -Wall -ansi -pedantic

minil: mini_1.lex
	flex mini_1.lex
	bison -d -v mini_1.y
	gcc main.c mini_1.tab.c lex.yy.c -lfl -o minil
	rm -f lex.yy.c

clean:

	rm -f minil *~
