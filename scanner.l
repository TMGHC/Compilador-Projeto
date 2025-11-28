
%option yylineno
%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"

    int identificadores = 0;
    int numi = 0;
    int numf = 0;
    int operadores = 0;
    int tipos = 0;
    int atribuicao = 0;
    int tokens = 0;
    int linhas = 0;

%}

NUMERO [0-9]
IDENT [a-zA-Z][a-zA-Z0-9]*

%%

{NUMERO}+ {
    numi++;
    tokens++;
    yylval.valor = atoi(yytext);
    return NUMEROI;
    }

{NUMERO}+"."{NUMERO}* {
    numf++;
    tokens++;
    yylval.valor = atof(yytext);
    return NUMEROF;
    }

    "intt" {
    tipos++;
    tokens++;
    yylval.txt = strdup(yytext);
    return INTT;
    }

    "floatt" {
    tipos++;
    tokens++;
    yylval.txt = strdup(yytext);
    return FLOATT;
    }

    "functt" {
        return FUNCTT;
    }

{IDENT} {
    identificadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return IDENTIFICADOR;
    }

"+" {
    operadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return '+';
    }

"-" {
    operadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return '-';
    }

"*" {
    operadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return '*';
    }

"/" {
    operadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return '/';
    }

"^" {
    operadores++;
    tokens++;
    yylval.txt = strdup(yytext);
    return '^';
    }

"=" {
    atribuicao++;
    tokens++;
    yylval.txt = strdup(yytext);
    return ATRIBUICAO;
    }

"(" { return '('; }

")" { return ')'; }

"," { return ',';}

\n {
    linhas++;
    return '\n';
}

[ \t]+

<<EOF>> {
    static int enviou_enter_final = 0;
    if (enviou_enter_final == 0) {
        enviou_enter_final = 1;
        return '\n';
    }
    return 0; 
}

. {printf("(S)Erro, caractere nao reconhecido: %s\n",yytext);
}

%%
