flex-bison:
	bison -d parser.y
	flex scanner.l
	gcc lex.yy.c parser.tab.c ast.c -o objetoparser-p -lfl

compile:
	./objetoparser-p.exe < entrada.txt > saida.txt
	

