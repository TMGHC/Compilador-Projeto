%debug
%require "3.8.2"

%code requires {
    #include "include/ast.h"
}

%{
//Incluindo headers.
#include "include/ast.h"
#include "include/parser.h"

//Variável global do lexer que controla o número da linha atual.
extern int yylineno;

//Declaração da função gerada pelo Flex.
int yylex();

//Função de erro sintático do Bison.
void yyerror(const char *s);

//Buffer de armazenamento de erros semânticos.
char errosSemanticos[200][200];
int QERROS = 0;

//Tabela de funções
funcao tbf[FUNCS];
int QF = 0;

//Tabela de variáveis.
variavel tbs[VARS];
int QV = 0;

//Lista temporária de nomes de parâmetros de função.
char n_p_f[10][20];
int q_p_f = 0;

//Buffer temporário para nós da AST dos argumentos em chamadas de função.
AST* cfun_ar_no[10];
int cfun_ar_q = 0;
%}

%union {
    float valor;
    char* txt;
    AST* no;
}

%start entrada

%token <valor> NUMEROI
%token <valor> NUMEROF
%token <txt> IDENTIFICADOR
%token <txt> TIPO
%token <txt> ATRIBUICAO
%token <txt> INTT
%token <txt> FLOATT
%token <txt> FUNCTT


%left '+' '-'
%left '*' '/'
%right '^'
%right OPUNI

%type <no> expressao
%type <no> declaracao
%type <no> atribuicao
%type <txt> funcao
%type parametros
%type argumentos

%%

entrada:
    %empty
    | entrada linha
    ;

linha:
    expressao '\n' {
            //Faz a avaliação do nó recebido em expressao.
            float aval = avaliar($1);

            //Caso algum erro tenha ocorrido durante a execução nada será printado.
            if(QERROS == 0){
            if($1!=NULL){
                if(ast_tipo_no($1) == 0 && $1->TN != NO_FUN){
                    printf("%.0f\n",aval);
                    printf("---AST---\n");
                    print_ast($1);
                    printf("---FIM---\n\n");
                }else{
                    printf("%.2f\n",aval);
                    printf("---AST---\n");
                    if($1->TN == NO_FUN){
                        print_ast(tbf[buscarFtabela($1->nome)].funct);
                    }else{
                        print_ast($1);
                    }
                    printf("---FIM---\n\n");
                }
            }
        }
        freeAST($1);
            }
    | declaracao '\n' {
        if($1!=NULL){
            printf("---AST---\n");
            print_ast($1);
            printf("---FIM---\n\n");
        }
        freeAST($1);
    }
    | atribuicao '\n'{
        if($1!=NULL){
            printf("---AST---\n");
            print_ast($1);
            printf("---FIM---\n\n");
        }
        freeAST($1); 
    }
    | funcao '\n'
    | '\n'
    ;

expressao:
    NUMEROI {$$ = no_num(0,$1);}

    | NUMEROF {$$ = no_num(1,$1);}

    | IDENTIFICADOR {$$ = no_var($1);
                     free($1);}

    | '-' expressao %prec OPUNI {$$ = no_num($2->tipo,-$2->valor);}

    | '+' expressao %prec OPUNI {$$ = no_num($2->tipo,$2->valor);}

    | expressao '+' expressao {$$ = no_op(NO_SOM, $1, $3);}

    | expressao '-' expressao {$$ = no_op(NO_SUB, $1, $3);}

    | expressao '*' expressao {$$ = no_op(NO_MUL, $1, $3);}

    | expressao '/' expressao {$$ = no_op(NO_DIV, $1, $3);}

    | expressao '^' expressao {$$ = no_op(NO_POT, $1, $3);}

    | IDENTIFICADOR '(' argumentos ')' {
        AST* no = no_cfun($1, cfun_ar_q, cfun_ar_no);
        cfun_ar_q = 0;
        free($1);
        $$ = no;
    }

    | '(' expressao ')' {$$ = $2;}
    ;

declaracao:
        INTT IDENTIFICADOR ATRIBUICAO expressao {
            int BV = buscarVtabela($2);
            if(BV != -1){
                erroSemantico("variável já declarada");
                free($2); freeAST($4);
                $$ = NULL;
            }else{
                int vtipono = ast_tipo_no($4);
                if(vtipono!=0){
                    erroSemantico("declaração de tipo incoerente");
                    $$ = NULL;
                }else{
                    float av = avaliar($4);
                    inserirVtabela(0,$2,av);
                    $$ = no_dec($2,$4);
                    free($2);
                }   
            }                         
        }

        | FLOATT IDENTIFICADOR ATRIBUICAO expressao {
            int BV = buscarVtabela($2);
            if(BV != -1){
                erroSemantico("variável já declarada");
                free($2); freeAST($4);
                $$ = NULL;
            }else{
                float av = avaliar($4);
                inserirVtabela(1,$2,av);
                $$ = no_dec($2,$4);
                free($2);
                }
            }

        | INTT IDENTIFICADOR {
            int BV = buscarVtabela($2);
            if(BV != -1){
                erroSemantico("variável já declarada");
                $$ = NULL;
            }else{
                inserirVtabela(0,$2,0);
                $$ = no_dec($2,NULL);
                }
            free($2);
            }

        | FLOATT IDENTIFICADOR {
            int BV = buscarVtabela($2);
            if(BV != -1){
                erroSemantico("variável já declarada");
                $$ = NULL;
            }else{
                inserirVtabela(1,$2,0);
                $$ = no_dec($2,NULL);
            }
            free($2);
        }
        ;
    
atribuicao:
        IDENTIFICADOR ATRIBUICAO expressao{
            int BV = buscarVtabela($1);
            if(BV == -1){
                erroSemantico("variável não declarada");
                free($1); freeAST($3);
                $$ = NULL;
            }else{
                int vtipono = ast_tipo_no($3);
                if(tbs[BV].tipo == 0 && vtipono == 1){
                    erroSemantico("atribuição de tipos incoerentes");
                    free($1); 
                    freeAST($3);
                    $$ = NULL;
                }else{
                    tbs[BV].valor = avaliar($3);
                    $$ = no_atr($1,$3);
                    free($1);
                }
            }
        }
        ;

parametros:   
        IDENTIFICADOR {
            strcpy(n_p_f[q_p_f], $1);
            q_p_f++;
            free($1);
        }

        |parametros ',' IDENTIFICADOR{
            strcpy(n_p_f[q_p_f], $3);
            q_p_f++;
            free($3);
        }
        | %empty
        ;

argumentos:
        expressao {
            cfun_ar_no[cfun_ar_q++] = $1;
        }
    |   argumentos ',' expressao {
            cfun_ar_no[cfun_ar_q++] = $3;
        }
    |   %empty
    ;
    
funcao:
        FUNCTT IDENTIFICADOR '(' parametros ')' ATRIBUICAO expressao{
            int r = inserirFtabela($2, $7, q_p_f, n_p_f);
            if (r < 0) {
            erroSemantico("função já declarada ou limite excedido");
            freeAST($7);
        }
            q_p_f=0;
            $$=NULL;
            free($2);
        }
        ;

%%

//Função responsável por buscar se uma variável já existe na tabela de variáveis.
int buscarVtabela(const char *nomeV){
    int i;
    for(i=0;i<QV;i++){
        if(strcmp(tbs[i].nome, nomeV) == 0){
            //Se existir, retorna o índice dela na tabela.
            return i;
        }
    }
    //Se não existir retorna -1.
    return -1;
}

//Faz a inserção de uma variável na tabela de variáveis, incluindo nome, tipo e valor, desde que essa variável não exista ainda na tabela.
int inserirVtabela(int tipo, const char *nome, float valor){
    if(QV < VARS){
        //Verifica se a variável já existe.
        if(buscarVtabela(nome)==-1){
            strncpy(tbs[QV].nome, nome, sizeof(tbs[QV].nome)-1);
            tbs[QV].nome[sizeof(tbs[QV].nome)-1] = '\0';
            tbs[QV].tipo = tipo;
            tbs[QV].valor = valor;
            //Se não existia, retornar contador global de variáveis incrementado.
            return QV++;
        }else{
            //Se existia, retorna -2.
            return -2;
            }
        }
    //Se a lista de variáveis estiver cheia retorna -1.
    return -1;
}

//Faz a busca na tabela de funções se uma função já existe, segue a mesma lógica da busca por variáveis.
int buscarFtabela(const char *nomeV){
    int i;
    for(i=0;i<QF;i++){
        if(strcmp(tbf[i].nome, nomeV) == 0){
            return i;
        }
    }
    return -1;
}

//Faz a inserção de uma função na tabela de funções, segue a mesma lógica da inserção de variáveis, mas aqui também é inserido o nó da AST correspondente à expressão definida na função.
int inserirFtabela(const char *nome, AST* astf, int npm, char fpm[][20]){
    int fi;
    if(QF < FUNCS){
        if(buscarFtabela(nome)==-1){
            strncpy(tbf[QF].nome, nome, sizeof(tbf[QF].nome)-1);
            tbf[QF].nome[sizeof(tbf[QF].nome)-1] = '\0';
            tbf[QF].qp = npm;
            for(int fi=0; fi<npm;fi++){
                strncpy(tbf[QF].parametros[fi], fpm[fi], 19);
            }
            tbf[QF].funct = astf;
            return QF++;
        }else{
            return -2;
            }
        }
    return -1;
}

//Chamada de erros semânticos que são colocados em um buffer e exibidos ao final da saída.
void erroSemantico(const char* msg){
    snprintf(errosSemanticos[QERROS], 200, 
             "Erro: %s | Linha %d\n", msg, yylineno-1);
    QERROS++;
}

//Chamada de erros sintáticos do próprio Bison.
void yyerror(const char *s){
        printf("Error: %s | Linha: %d\n", s, yylineno);
    }

int main(){

    //Chamada do parser gerado pelo Bison iniciando a análise sintática.
    yyparse();

    //Exibir os erros encontrados caso tenham ocorrido.
    for(int i = 0; i < QERROS; i++){
        printf("%s", errosSemanticos[i]);
    }

    return 0;
}
