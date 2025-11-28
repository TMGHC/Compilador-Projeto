#ifndef AST_H
#define AST_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

//Tipos de nós.
typedef enum {
    NO_NUM,
    NO_VAR,
    NO_SOM,
    NO_SUB,
    NO_MUL,
    NO_DIV,
    NO_POT,
    NO_FUN,
    NO_DFU,
    NO_DEC,
    NO_ATR
} TipoNo;

//Struct de um nó, pode conter tipo de nó, valor, tipo, nome, filho esquerdo e direito, lista de argumentos e quantidade de argumentos.
typedef struct AST{
    TipoNo TN;
    float valor;
    int tipo;
    char *nome;
    struct AST *esq;
    struct AST *dir;
    struct AST **args;
    int NARGS;
} AST;

AST* no_num(int ,float);
AST* no_var(const char*);
AST* no_op(TipoNo, AST*, AST*);
AST* no_dec(const char*, AST*);
AST* no_atr(const char*, AST*);
AST* no_cfun(const char*, int, AST**);
float avaliar(AST*);
void freeAST(AST*);
int ast_tipo_no(AST*);
void print_ast(AST*);
void print_ast_rec(AST*, int);

#endif