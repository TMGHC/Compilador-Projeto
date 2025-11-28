flex-bison:
	bison -d parser.y
	flex scanner.l
	gcc lex.yy.c parser.tab.c ast.c -o objetoparser-p -ID:\Arquivos_Com_Ex\msys64\usr\include -LD:\Arquivos_Com_Ex\msys64\usr\lib -lfl

compile:
	./objetoparser-p.exe < entrada.txt > saida.txt
	
