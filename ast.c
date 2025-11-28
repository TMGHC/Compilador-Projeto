#include "include/ast.h"
#include "include/parser.h"

int pin=0;

//Função que cria nó genérico com valores defaut.
AST* no_ger(){
    AST *no = malloc(sizeof(AST));
    no->esq = NULL;
    no->dir = NULL;
    no->args = NULL;
    no->nome = NULL;
    no->TN = -1;
    no->tipo = 0;
    no->valor = 0;
    no->args = NULL;
    no->NARGS = 0;
    return no;
}

//Função que cria nó de número, dentro dela é definido o tipo de nó, o tipo do número (intt ou floatt), o valor e retornado o nó criado.
AST* no_num(int t, float v){
    AST* no = no_ger();
    no->TN = NO_NUM;
    no->tipo = t;
    no->valor = v;
    return no;
}

//Função que cria nó de variável, dentro dela é definido o tipo de nó, o nome e retornado o nó criado.
AST* no_var(const char* nome){
    AST* no = no_ger();
    no->TN = NO_VAR;
    no->nome = strdup(nome);
    return no;
}

//Função que cria nó de operação, dentro dela é definido o tipo de nó, os dois nós filhos da esquerda e direita e o tipo que é definido com base nos tipos dos filhos, se um deles tiver o tipo como 1 (float) o nó se torna floatt.
AST* no_op(TipoNo tn, AST* e, AST* d){
    AST* no = no_ger();
    no->TN = tn;
    no->esq = e;
    no->dir = d;
    no->tipo = ( (e && e->tipo) || (d && d->tipo));
    return no;
}

//Função que cria nó de declaração, apenas para fins demonstrativos.
AST* no_dec(const char* nome, AST* exp){
    AST* no = no_ger();
    no->TN = NO_DEC;
    no->nome = strdup(nome);
    no->esq = exp;
    return no;
}

//Função que cria nó de atribuição, apenas para fins demonstrativos.
AST* no_atr(const char* nome, AST* exp){
    AST* no = no_ger();
    no->TN = NO_ATR;
    no->nome = strdup(nome);
    no->esq = exp;
    return no;
}

//Função que cria um nó do tipo de chamada de função, esse nó é formado quando uma função é chamada com seus respectivos parâmetros definidos em sua declaração.
AST* no_cfun(const char* fnome, int qt_a, AST** argr){
    int fi;
    AST* no = no_ger();
    no->TN = NO_FUN;
    no->nome = strdup(fnome);
    no->NARGS = qt_a;
    //Se a função possuir argumentos, é alocado espaço em memória o suficiente para receber os nós de cada argumento, cada argumento sendo uma expressão.
    if(qt_a>0){
        no->args = malloc(sizeof(AST*) * qt_a);
        for(fi=0; fi < qt_a; fi++){
            no->args[fi] = argr[fi];
        }
        fi=0;
        //Percorre os argumentos em busca de algum que seja do tipo floatt, se houver, o tipo do nó se torna floatt caso contrário intt.
        while(no->tipo==0 && fi < qt_a){
            if(ast_tipo_no(no->args[fi])==1){
                no->tipo=1;
            }
            fi++;
        }
    }else{
        no->args = NULL;
    }
    return no;
    }

//Função responsável por definir o tipo do nó.
int ast_tipo_no(AST* tno){
    if(!tno) return 0;
    //Se for um nó de função ou número, retorna o tipo dele.
    if(tno->TN==NO_FUN){return tno->tipo;}
    if(tno->TN==NO_NUM){return tno->tipo;}

    //Se for um nó de variável, faz a busca na tabela de variáveis para buscar o tipo.
    if(tno->TN==NO_VAR){
        int TV = buscarVtabela(tno->nome);
        if(TV != -1){
            return tbs[TV].tipo;
        }else{
            return 0;
        }
    }
    //Recursivamente visita os filhos do nó, chamando essa mesma função para verificar o tipo até chegar nas folhas.
    return (ast_tipo_no(tno->esq) || ast_tipo_no(tno->dir));
}

//Função responsável por realizar os cálculos das operações, tratando os números e as variáveis. Também é responsável por tratar as chamadas de função criadas pelo usuário.
float avaliar(AST* nr){
    
    //Verifica o tipo do nó atual
    switch(nr->TN){

        //Se for número (folha), retorna o valor
        case NO_NUM: return nr->valor;

        //Se for variável (folha), busca na tabela de variáveis e retorna o valor, se não for encontrada, dispara erro semântico.
        case NO_VAR: {
            int p = buscarVtabela(nr->nome);
        if(p == -1){
            erroSemantico("variável não declarada");
        }
        return tbs[p].valor;
        }

        //Se for um tipo de operação, acessa recursivamente os filhos até que valores sejam retornados e a operação seja realizada.
        case NO_SOM: return avaliar(nr->esq) + avaliar(nr->dir);
        case NO_SUB: return avaliar(nr->esq) -  avaliar(nr->dir);
        case NO_DIV: return avaliar(nr->esq) / avaliar(nr->dir);
        case NO_MUL: return avaliar(nr->esq) * avaliar(nr->dir);
        case NO_POT: return pow(avaliar(nr->esq),avaliar(nr->dir));

        //Se for uma função, o processo se estende um pouco mais.
        case NO_FUN: {
            int fi;
            //Primeiro se busca a função, pelo nome, na tabela de funções. Se não for encontrada, dispara erro semântico.
            int fb = buscarFtabela(nr->nome);
            if(fb==-1){
                erroSemantico("função não declarada");
                return 0;
            }

            //Cria um ponteiro do tipo funcao (struct) apontando para a função encontrada na tabela.
            funcao* f = &tbf[fb];

            //Se o número de argumentos não estiver de acordo com o que foi definido e guardado na tabela de funções, dispara erro semântico.
            if (nr->NARGS != f->qp) {
                erroSemantico("número incorreto de argumentos");
                return 0;
            }

            //Vetores auxiliares que guardam, respectivamente: o valor da avaliação dos argumentos passados, portanto, se uma variável for passada, ela será avaliada e o valor contido nela será usado, se for uma expressão, ela será avaliada e o resultado será utilizado, e seus tipos.
            float avalv[10];
            int tp[10];

            //Percorre os argumentos, avaliando cada um e analisando seu tipo. Essa análise é feita na tabela de variáveis no escopo original do compilador.
            for (fi = 0; fi < nr->NARGS; fi++) {
                avalv[fi] = avaliar(nr->args[fi]);
                tp[fi]   = ast_tipo_no(nr->args[fi]);
            }

            //Aqui acontece o isolamento do escopo da função, simulando um escopo local.
            //Cria um vetor de variáveis com a mesma quantidade do escopo original.
            variavel stbs[VARS];
            
            //Guarda a quantidade de variáveis do escopo original.
            int sqv = QV;

            //Faz uma cópia do escopo de variáveis de fora da função.
            memcpy(stbs, tbs, sizeof(tbs));

            //Zera a tabela de variáveis atual, criando um ambiente novo onde só existirão as variáveis locais da função.
            QV=0;

            //Para cada parâmetro definido na declaração da função, é inserido no novo escopo o nome do parâmetro, o tipo obtido através do argumento passado e o  valor trazido pelo argumento avaliado anteriormente. Preenchendo assim, a nova tabela de variáveis do escopo da função.
            for (fi = 0; fi < nr->NARGS; fi++) {
                inserirVtabela(tp[fi], f->parametros[fi], avalv[fi]);
            }

            //A função é avaliada.
            float resultadof = avaliar(f->funct);

            //A tabela de variáveis e o contador de variáveis são restaurados aos seus estados originais anteriores.
            memcpy(tbs, stbs, sizeof(tbs));
            QV = sqv;

            //Resultado retornado.
            return resultadof;
        }
    }
}

//Função responsável por recursivamente liberar a memória dos nós que alocaram espaço.
void freeAST(AST* no){
    int fi;
    if(!no) return;
    if(no->esq){freeAST(no->esq);}
    if(no->dir){freeAST(no->dir);}
    if(no->nome){free(no->nome);}
    if(no->TN == NO_FUN && no->NARGS){
        for(fi=0;fi<no->NARGS;fi++){
            freeAST(no->args[fi]);
        }
        free(no->args);
    }
}

//Função responsável por printar a árvore sintática abstrata para o usuário final.
void print_ast_rec(AST* no, int nivel) {
    if (!no) return;

    for(int i=0; i<nivel; i++) printf("   ");

    switch(no->TN) {
        case NO_NUM:
            printf("NUM(%.2f)\n", no->valor);
            return;

        case NO_VAR:
            printf("VAR(%s)\n", no->nome);
            return;

        case NO_SOM: printf("OP(+)\n"); break;
        case NO_SUB: printf("OP(-)\n"); break;
        case NO_MUL: printf("OP(*)\n"); break;
        case NO_DIV: printf("OP(/)\n"); break;
        case NO_POT: printf("OP(^)\n"); break;
        case NO_DEC: printf("DEC(%s)\n",no->nome); break;
        case NO_ATR: printf("ATR(%s)\n",no->nome); break;

        default:
            printf("?\n");
            return;
    }
    print_ast_rec(no->esq, nivel + 1);
    print_ast_rec(no->dir, nivel + 1);
}

void print_ast(AST* no) {
    print_ast_rec(no, 0);
}