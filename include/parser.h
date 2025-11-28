#ifndef PARSER_H
#define PARSER_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "ast.h"

#define VARS 20
#define FUNCS 20

//Struct de uma variável que contém o identificador, valor e o tipo.
typedef struct{
    char nome[20];
    float valor;
    int tipo;
} variavel;

//Struct de uma função que contém o nome, lista de parâmetros, quantidade de parâmetros e nó da AST.
typedef struct{
    char nome[20];
    char parametros[10][20];
    int qp;
    AST* funct;
} funcao;

extern funcao tbf[FUNCS];
extern int QF;
extern variavel tbs[VARS];
extern int QV;

void erroSemantico(const char*);
int inserirVtabela(int, const char *, float);
int buscarVtabela(const char *);
int inserirFtabela(const char *, AST*, int, char[][20]);
int buscarFtabela(const char *);

#endif