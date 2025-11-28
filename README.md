# Compilador-Projeto
### Projeto de um compilador básico que aceita expressões matemáticas, criação de variáveis e criação de funções.
Mais detalhes na documentação do projeto: [PCG - Compiladores.pdf](https://github.com/user-attachments/files/23815229/PCG.-.Compiladores.pdf)

---

### Uso do Compilador e Detalhes da Linguagem
O projeto já contém o “objetoparser-p.exe” presente na pasta não sendo necessário recompilar tudo para testar, ainda assim segue um passo a passo.

### Compilar e executar o compilador
Para gerar o compilador, é necessário ter o Flex, Bison e um compilador C (como GCC) instalados no ambiente.
Na pasta existe um arquivo Makefile que automatiza o processo executando os seguintes comandos:

•	“bison -d parser.y”: chama o Bison para ler o arquivo “parser.y” e gerar os arquivos “parser.tab.c” e o “parser.tab.h”;

•	“flex scanner.l”: chama o Flex para ler o arquivo “scanner.l” e gerar o arquivo “lex.yy.c”;

•	“gcc lex.yy.c parser.tab.c ast.c -o objetoparser-p -lfl”: compila tudo com o GCC e monta o executável final “objetoparser-p”. Pode ser que seja necessário fornecer caminhos utilizando -ID e -LD para bibliotecas e headers.

Para utilizar o compilador é necessário que o compilador receba um arquivo .txt como fonte e depois execute objetoparser-p.exe < entrada.txt > saida.txt no terminal, isso irá gerar outro .txt chamado saída.txt contendo o resultado do processamento, o nome entrada.txt pode ser alterado desde que seja o mesmo do arquivo .txt fonte, ou apenas objetoparser-p.exe < entrada.txt dessa forma a saída será printada no próprio CLI.
 


### Detalhes da Linguagem e Testes
Na pasta do projeto já existe o “objetoparser-p.exe” compilado e pronto para ser utilizado e o arquivo “entrada.txt” com uma linguagem aceita para demonstração.
A linguagem do projeto aceita:

•	Declaração de variáveis;

•	Atribuição de variáveis;

•	Dois tipos de variáveis sendo eles o intt (com dois t’s no fim) e o floatt (também com dois t’s);

•	Expressões matemáticas com +, -, *, /, ^, ( ), e operadores unários;

•	Precedência e associatividade que seguem o padrão matemático;

•	Declaração de funções utilizando a palavra-chave functt (com dois t’s). As chamadas de função sempre retornam um floatt;

•	Print de valores feitos com expressões matemáticas isoladas em uma linha, variáveis isoladas em uma linha e chamadas de função isoladas em uma linha. O print traz o valor obtido com a expressão seguido por sua AST;

•	Análise de erros léxicos, sintáticos e semânticos;

•	Não precisa de delimitador de instrução como o “ ; ”, a quebra de linha já tem esse papel.

Exemplos de entradas aceitas:
```
intt a = 5

intt b

b = 7

a+b
```
```
floatt c = -5.7

floatt d = 7.7

5*c+(d-6.2)^2
```

```
intt a = 1+1

5*7/5+6*(2+2)

a
```
```
floatt var1 = 4.47

intt var2 = 357

functt foo1(w,x,y,z)=w*x+y-z

foo1(var1, var2 , -50, 200)
```

Exemplo com erros:
```
intt a = 3

intt b = 1

floatt c

floatt d = 2

a = 3

b

c = 4.1

d

a

c

intt c

floatt a

intt e = 0.1

a = 3.2



e

a

-10+5



functt f(x,y,z) = x*y/z

functt g(a,b) = a+b



f(1,2,3,4)

f(1,2)



-1+5*7+(2^3)/4

1+2*3+(4^5)/10


f(1,2,3)

1/2

g(1,2)
```
