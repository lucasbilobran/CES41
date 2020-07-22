%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* === Declaracoes de tipos === */

enum tipos {
    SOMA=1, SUB, MULT, DIV, MOD, EQ, NEQ, LT, LEQ, GT, GEQ, FINAL
};

enum identificadores {
    IDGLOB=1, IDVAR, IDFUNC, IDPROC, IDPROG
};

enum variaveis {
    NOTVAR=1, INTEGER, LOGICAL, FLOAT, CHAR
};

/* === Constantes === */

#define NCLASSHASH  23
#define TRUE         1
#define FALSE        0
#define MAXDIMS     10

/*  === Nomes ===  */

char *nometipid[3] = {" ", "IDPROG", "IDVAR"};
char *nometipvar[5] = {"NOTVAR", "INTEGER", "LOGICAL", "FLOAT", "CHAR"};

/* === Definições de Tipos === */
typedef int bool;
typedef struct elemlisttipo elemlisttipo;
typedef elemlisttipo *pontexprtipo;
typedef elemlisttipo *listtipo;
typedef struct infolistexpr infolistexpr;
typedef struct celsimb celsimb;
typedef celsimb *simbolo;
typedef struct elemlistsimb elemlistsimb;
typedef elemlistsimb *pontelemlistsimb;
typedef elemlistsimb *listsimb;


/* === Estruturas === */
struct celsimb {
    char *cadeia;
    int  tid, tvar, ndims, nparam, dims[MAXDIMS+1];
    char inic, ref, array, param;
    listsimb listvar, listparam, listfunc;
    simbolo escopo, prox; 
};

struct elemlistsimb {
    simbolo simb; 
    pontelemlistsimb prox;
};

struct infolistexpr { 
    pontexprtipo listtipo;
    int nargs;
};

struct elemlisttipo {
    int tipo;
    pontexprtipo prox;
};

/* ===  Variaveis globais === */
simbolo tabsimb[NCLASSHASH];
simbolo simb;
int tipocorrente;
int tab = 0;
simbolo escopo, escaux;
bool declparam = FALSE;
listsimb pontvar;
listsimb pontparam;
listsimb pontfunc;

/* === Prototipos === */
void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int, simbolo);
int hash (char *);
simbolo ProcuraSimb (char *, simbolo);
void VerificaInicRef (void);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);
void Incompatibilidade (char *);
void tabular (void);
void Esperado(char *);
void NaoEsperado(char *);
void InsereListSimb(simbolo, listsimb);
listtipo ConcatListTipo(listtipo, listtipo);
listtipo InicListTipo(int);
void ChecArgumentos(pontexprtipo, listsimb);
void MsgErro (char *);
%}

%union {
    char string[50];
    int atr, valint;
    int valor;
    float valreal;
    char carac;
    simbolo simb;
    int tipoexpr, nsubscr;
    infolistexpr infolexpr;
}        

/* === Atributos e Tokens === */
%type     <simb>        Variavel ChamadaFunc
%type     <tipoexpr>    Expressao  ExprAux1  ExprAux2 ExprAux3   ExprAux4   Termo   Fator
%type     <infolexpr>   ListExpr Argumentos
%type     <nsubscr>     Subscritos ListSubscr

%token    <string>      ID
%token    <valor>       CTINT
%token    <string>      CTCARAC
%token    <valreal>     CTREAL
%token    <string>      CADEIA

%token    <atr>         OPAD
%token    <atr>         OPMULT
%token    <atr>         OPREL
%token                  OR
%token                  AND
%token                  NOT
%token                  NEG
%token                  ATRIB
%token                  ABPAR
%token                  FPAR
%token                  ABCOL
%token                  FCOL
%token                  ABCHAV
%token                  FCHAV
%token                  ABTRIP
%token                  FTRIP
%token                  PVIG
%token                  VIRG

%token                  CARAC
%token                  CHAMAR
%token                  COMANDOS
%token                  ENQUANTO 
%token                  ESCREVER
%token                  FALSO
%token                  FUNCAO
%token                  INT
%token                  LER
%token                  LOGIC
%token                  PARA
%token                  PRINCIPAL 
%token                  PROCEDIMENTO
%token                  PROGRAMA
%token                  REAL
%token                  REPETIR
%token                  RETORNAR
%token                  SE
%token                  SENAO
%token                  VAR
%token                  VERDADE
%token                  INVAL
%%

Prog        :   {
                    InicTabSimb (); 
                    declparam = FALSE; 
                    simb = escopo = InsereSimb("##global", IDGLOB, NOTVAR, NULL);
                    pontvar = simb->listvar;
                    pontparam = simb->listparam;
                    pontfunc = simb->listfunc;
                } 
                PROGRAMA ID ABTRIP {tabular(); printf("programa %s {{{", $3); InsereSimb ($3, IDPROG, NOTVAR, escopo); tab++; printf("\n");}  Decls ListMod ModPrincipal FTRIP {printf("\n"); printf("}}}\n"); printf("\n\nPrograma Compilado com Sucesso!\n\n"); VerificaInicRef (); ImprimeTabSimb ();return;}
            ;
Decls       :
            |   VAR  ABCHAV {printf("\n"); tabular(); printf("var {\n"); tab++;} ListDecl FCHAV {tab--; tabular(); printf("}\n");}
            ;
ListDecl    :   Declaracao
            |   ListDecl Declaracao
            ;
Declaracao  :   {tabular();} Tipo ABPAR {printf("(");} ListElem FPAR {printf(")\n");}
            ;
Tipo        :   INT  {printf ("int "); tipocorrente = INTEGER;}
            |   REAL  {printf ("real "); tipocorrente = FLOAT;}
            |   CARAC  {printf ("carac "); tipocorrente = CHAR;}
            |   LOGIC  {printf ("logic "); tipocorrente = LOGICAL;}
            ;
ListElem    :   Elem
            |   ListElem VIRG {printf(", ");} Elem
            ;
Elem        :   ID {
                        printf ("%s ", $1);
                        if  (ProcuraSimb ($1, escopo)  !=  NULL)
                            DeclaracaoRepetida ($1);
                        else {
                            simb = InsereSimb ($1,  IDVAR,  tipocorrente, escopo);
                            simb->array = FALSE;
                            simb->ndims = 0;
                        }
                    } Dims
            ;
Dims        :   
            |   ABCOL {printf("[");} ListDim FCOL {printf("]"); simb->array = TRUE;}
            ;
ListDim     :   CTINT {printf("%d", $1);
                        if($1 <= 0) Esperado("Valor inteiro positivo");
                        simb->ndims++; simb->dims[simb->ndims] = $1;  
                      }
            |   ListDim VIRG CTINT {printf(", %d", $3);
                                        if($3 <= 0) Esperado("Valor inteiro positivo");
                                        simb->ndims++; simb->dims[simb->ndims] = $3; 
                                   }
            ;
ListMod     :
            |   ListMod Modulo
            ;
Modulo      :   Cabecalho {printf("\n"); tab++;} Corpo {printf("\n"); tab--;}
            ;
Cabecalho   :   {printf("\n"); tabular(); printf("funcao ");} CabFunc
            |   CabProc
            ;
CabFunc     :   FUNCAO Tipo ID ABPAR FPAR {
                                            simb = ProcuraSimb($3, escopo); 
                                            if (simb == NULL)
                                                simb = escopo = InsereSimb($3, IDFUNC, NOTVAR, escopo);
                                            else {
                                                DeclaracaoRepetida($3);
                                                MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                            }
                                            pontvar = simb->listvar;
                                            printf("%s ()", $3);
                                        }
            |   FUNCAO Tipo ID ABPAR {
                                        simb = ProcuraSimb($3, escopo); 
                                        if (simb == NULL)
                                            simb = escopo = InsereSimb($3, IDFUNC, NOTVAR, escopo);
                                        else {
                                            DeclaracaoRepetida($3);
                                            MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                        }
                                        pontvar = simb->listvar;
                                        pontparam = simb->listparam;
                                        declparam = TRUE;
                                        printf(" %s (", $3);
                                    } ListParam FPAR {declparam = FALSE; printf(")");} 
            ;
CabProc     :   PROCEDIMENTO ID ABPAR  FPAR  {
                                                simb = ProcuraSimb($2, escopo);
                                                if (simb == NULL)
                                                    simb = escopo = InsereSimb($2, IDPROC, NOTVAR, escopo);
                                                else {
                                                    DeclaracaoRepetida($2);
                                                    MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                                }
                                                pontvar = simb->listvar;
                                                printf("\n");
                                                tabular();
                                                printf("procedimento %s ()", $2);
                                            }
            |   PROCEDIMENTO ID ABPAR {
                                        simb = ProcuraSimb($2, escopo);
                                        if (simb == NULL)
                                            simb = escopo = InsereSimb($2, IDPROC, NOTVAR, escopo);
                                        else {
                                            DeclaracaoRepetida($2);
                                            MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                        }
                                        pontvar = simb->listvar;
                                        pontparam = simb->listparam;
                                        declparam = TRUE;
                                        printf("\n");
                                        tabular(); 
                                        printf("procedimento %s (", $2);
                                    } ListParam  FPAR {declparam = FALSE; printf(")");}
            ;
ListParam   :   Parametro
            |   ListParam VIRG {printf(", ");} Parametro
            ;
Parametro   :   Tipo ID {
                            if  (ProcuraSimb ($2, escopo)  !=  NULL)
                                DeclaracaoRepetida ($2);
                            else {
                                simb = InsereSimb ($2,  IDVAR,  tipocorrente, escopo);
                                simb->array = FALSE;
                                simb->ndims = 0;
                            }
                            printf("%s", $2);
                        }
            ;
Corpo       :   Decls Comandos {escopo = escopo->escopo;}
            ;
ModPrincipal:   {printf("\n"); tabular();} PRINCIPAL {escopo = InsereSimb("##principal", IDPROG, NOTVAR, escopo); printf("principal \n"); tab++;}  Corpo {printf("\n"); tab--;}
            ;
Comandos    :   COMANDOS {printf("\n"); tabular(); printf("comandos "); tab++;}  CmdComp {tab--;}
            ;
CmdComp     :   ABCHAV {printf("{");} ListCmd FCHAV {printf("\n"); tab--; tabular(); printf("}"); tab++;}
            ;
ListCmd     :   
            |   ListCmd Comando
            ;
Comando     :   CmdComp
            |   {printf("\n"); tabular();} CmdSe
            |   {printf("\n"); tabular();} CmdEnquanto
            |   {printf("\n"); tabular();} CmdRepetir
            |   {printf("\n"); tabular();} CmdPara
            |   {printf("\n"); tabular();} CmdLer
            |   {printf("\n"); tabular();} CmdEscrever
            |   {printf("\n"); tabular();} CmdAtrib
            |   {printf("\n"); tabular();} ChamadaProc
            |   {printf("\n"); tabular();} CmdRetornar
            |   PVIG {printf("aaaa;");} 
            ;
CmdSe       :   SE   ABPAR {printf("se (");}  Expressao {if ($4 != LOGICAL) Incompatibilidade("Expressao nao logica");} FPAR {printf(") "); tab++;} Comando  CmdSenao {tab--;} 
            ;   
CmdSenao    :  
            |  SENAO   {tab--; printf("\n"); tabular(); printf("senao "); tab++;} Comando
            ;
CmdEnquanto :  ENQUANTO   ABPAR  {printf("enquanto (");} Expressao {if ($4 != LOGICAL) Incompatibilidade("Expressao nao logica");} FPAR {printf(") "); tab++;} Comando {tab--;} 
            ;
CmdRepetir  :  REPETIR {printf("repetir \n"); tab++;} Comando  ENQUANTO ABPAR {printf("enquanto (");} Expressao {if ($7 != LOGICAL) Incompatibilidade("Expressao nao logica");} FPAR  PVIG {printf(");");} 
            ;
CmdPara     :  PARA {printf("para ");} Variavel {if ($3 != INTEGER) Incompatibilidade("Expressao nao inteiro ou caractere");} 
               ABPAR {printf(" (");}  ExprAux4 {if ($7 != INTEGER) Incompatibilidade("Expressao nao inteiro ou caractere");} 
               PVIG {printf("; ");}  Expressao {if ($11 != LOGICAL) Incompatibilidade("Expressao nao logica");} PVIG {printf("; ");} 
               ExprAux4 {if ($15 != LOGICAL) Incompatibilidade("Expressao nao inteiro ou caractere");} FPAR {printf(") "); tab++;} Comando {tab--;}
            ;
CmdLer      :  LER   ABPAR  {printf("ler (");} ListLeit  FPAR  PVIG {printf(");");} 
            ;        
ListLeit    :  Variavel  
            |  ListLeit  VIRG {printf(", ");} Variavel 
            ;  
CmdEscrever :  ESCREVER   ABPAR {printf("escrever (");} ListEscr  FPAR  PVIG {printf(");");}  
            ;    
ListEscr    :  ElemEscr  
            |  ListEscr  VIRG {printf(", ");} ElemEscr 
            ;    
ElemEscr    :  CADEIA {printf("%s", $1);}
            |  Expressao 
            ;    
ChamadaProc :  CHAMAR   ID  ABPAR {printf("chamar %s (", $2);} Argumentos  FPAR  PVIG  {printf(");");}
            ;    
Argumentos  :  {$$.nargs = 0; $$.listtipo = NULL;}
            |  ListExpr 
            ;
CmdRetornar :  RETORNAR   PVIG  {printf("retornar ;");} 
            |  RETORNAR {printf("retornar ");} Expressao  PVIG {printf(";");}  
            ;        
CmdAtrib    :  Variavel {if  ($1 != NULL) $1->inic = $1->ref = TRUE;}  
               ATRIB {printf(" = ");}  Expressao  PVIG 
               {
                   printf(";");
                   if ($1 != NULL)
                        if ((($1->tvar == INTEGER || $1->tvar == CHAR) &&
                            ($5 == FLOAT || $5 == LOGICAL)) ||
                            ($1->tvar == FLOAT && $5 == LOGICAL) ||
                            ($1->tvar == LOGICAL && $5 != LOGICAL))
                                Incompatibilidade ("Lado direito de comando de atribuicao improprio"); 
                } 
            ;
ListExpr    :  Expressao {
                            $$.nargs = 1;
                            $$.listtipo = InicListTipo($1);
                         }
            |  ListExpr  VIRG {printf(", ");} Expressao {
                                                            $$.nargs = $1.nargs + 1;
                                                            $$.listtipo = ConcatListTipo($1.listtipo, InicListTipo($4));
                                                        }
            ;    
Expressao   :  ExprAux1 
            |  Expressao  OR {printf(" || ");} ExprAux1 {
                        if ($1 != LOGICAL || $4 != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador or");
                        $$ = LOGICAL;
                    }
            ;    
ExprAux1    :  ExprAux2 
            |  ExprAux1  AND {printf(" && ");} ExprAux2 {
                        if ($1 != LOGICAL || $4 != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador and");
                        $$ = LOGICAL;
                    }
            ;    
ExprAux2    :  ExprAux3 
            |  NOT {printf("!");} ExprAux3 {
                        if ($3 != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador not");
                        $$ = LOGICAL;
                    }
            ;    
ExprAux3    :  ExprAux4 
            |  ExprAux4  OPREL {
                switch($2) {
                    case LT:
                        printf(" < ");
                    break;
                    case LEQ:
                        printf(" <= ");
                    break;
                    case GT:
                        printf(" > ");
                    break;
                    case GEQ:
                        printf(" >= ");
                    break;
                    case EQ:
                        printf(" == ");
                    break;
                    case NEQ:
                        printf(" != ");
                    break;
                }
            } ExprAux4 {
                        switch ($2) {
                            case LT: case LEQ: case GT: case GEQ:
                                if ($1 != INTEGER && $1 != FLOAT && $1 != CHAR || $4 != INTEGER && $4 != FLOAT && $4 != CHAR)
                                    Incompatibilidade    ("Operando improprio para operador relacional");
                                break;
                            case EQ: case NEQ:
                                if (($1 == LOGICAL || $4 == LOGICAL) && $1 != $4)
                                    Incompatibilidade ("Operando improprio para operador relacional");
                                break;
                        }
                        $$ = LOGICAL;
                    }
            ;    
ExprAux4    :  Termo 
            |  ExprAux4  OPAD {
                switch($2) {
                    case SOMA:
                        printf(" + ");
                    break;
                    case SUB:
                        printf(" - ");
                    break;
                }
            } Termo {
                        if ($1 != INTEGER && $1 != FLOAT && $1 != CHAR || $4 != INTEGER && $4!=FLOAT && $4!=CHAR)
                            Incompatibilidade ("Operando improprio para operador aritmetico");
                        if ($1 == FLOAT || $4 == FLOAT) $$ = FLOAT;
                        else $$ = INTEGER;
                    }
            ;    
Termo       :  Fator 
            |  Termo  OPMULT {
                switch($2) {
                    case MULT:
                        printf(" * ");
                    break;
                    case DIV:
                        printf(" / ");
                    break;
                    case MOD:
                        printf(" %% ");
                    break;
                }
            } Fator {
                        switch ($2) {
                            case MULT: case DIV:
                                if ($1 != INTEGER && $1 != FLOAT && $1 != CHAR
                                    || $4 != INTEGER && $4!=FLOAT && $4!=CHAR)
                                    Incompatibilidade ("Operando improprio para operador aritmetico");
                                if ($1 == FLOAT || $4 == FLOAT) $$ = FLOAT;
                                else $$ = INTEGER;
                                break;
                            case MOD:
                                if ($1 != INTEGER && $1 != CHAR
                                    ||  $4 != INTEGER && $4 != CHAR)
                                    Incompatibilidade ("Operando improprio para operador resto");
                                $$ = INTEGER;
                                break;
                        }
                    }
            ;    
Fator       :  Variavel {
                        if  ($1 != NULL) {
                            $1->ref  =  TRUE;
                            $$ = $1->tvar;
                        }
                    }
            |  CTINT {printf ("%d", $1); $$ = INTEGER;}
            |  CTREAL {printf ("%g", $1); $$ = FLOAT;}
            |  CTCARAC {printf("%s", $1); $$ = CHAR;}
            |  VERDADE  {printf("verdade"); $$ = LOGICAL;}
            |  FALSO  {printf("falso"); $$ = LOGICAL;}
            |  NEG {printf("~");} Fator {
                        if ($3 != INTEGER &&
                            $3 != FLOAT && $3 != CHAR)
                            Incompatibilidade  ("Operando improprio para menos unario");
                            if ($3 == FLOAT) $$ = FLOAT;
                            else $$ = INTEGER;
                    }
            |  ABPAR  Expressao  FPAR {$$ = $2;}
            |  ChamadaFunc 
            ;
Variavel    :  ID  {
                        printf ("%s", $1);
                        escaux = escopo;
                        simb = ProcuraSimb ($1, escaux);
                        while (escaux && !simb) {
                            escaux = escaux->escopo;
                            if (escaux)
                                simb = ProcuraSimb ($1, escaux);
                        }
                        if (simb == NULL)   NaoDeclarado ($1);
                        else if (simb->tid != IDVAR)   TipoInadequado ($1);
                        $<simb>$ = simb;
                    }  Subscritos  {
                                    $$ = $<simb>2;
                                    if($$ != NULL){
                                        if($$->array == FALSE && $3 > 0)
                                            NaoEsperado("Subscrito\(s)");
                                        else if($$->array == TRUE && $3 == 0){
                                            Esperado("Subscrito\(s)");
                                        }
                                        else if($$->ndims!= $3)
                                            Incompatibilidade("Numero de subscritos incompativel com declaracao");
                                    }
                                    }
            ;    
Subscritos  :  {$$ = 0;}
            |  ABCOL {printf("[");}  ListSubscr  FCOL  {printf("]"); $$ = $3;}
            ;    
ListSubscr  :  ExprAux4 {
                            if($1 != INTEGER && $1 != CHAR) Incompatibilidade("Tipo inadequado para subscrito");
                            $$ = 1;
                        }
            |  ListSubscr  VIRG {printf(", ");}  ExprAux4 {
                            if($4 != INTEGER && $4 != CHAR) Incompatibilidade("Tipo inadequado para subscrito");
                            $$ = $1 + 1;
                        }
            ;    
ChamadaFunc :   ID  ABPAR  {
                                printf("%s (", $1);
                                simb = ProcuraSimb ($1, escopo->escopo);
                                if (!simb)
                                    NaoDeclarado($1);
                                else if (simb->tid != IDFUNC)
                                    TipoInadequado($1);
                                $<simb>$ = simb;
                           } 
                           Argumentos  FPAR {
                                                printf(")");
                                                $$ = $<simb>3;
                                                if ($$ && $$->tid == IDFUNC) {
                                                    if ($$->nparam != $4.nargs)
                                                        Incompatibilidade("Numero de argumentos diferente do numero de parametros");
                                                    printf("\n\n===== START CHECK =====\n\n");
                                                    ChecArgumentos($4.listtipo, $$->listparam);
                                                }
                                            } 
            ;

%%

/* Inclusao do analisador lexico  */

#include "lex.yy.c"

void tabular() {
    int i;
    for (i = 1; i <= tab; i++) {
        printf("   ");
    }
}

/*  InicTabSimb: Inicializa a tabela de simbolos   */

void InicTabSimb () {
    int i;
    for (i = 0; i < NCLASSHASH; i++)
        tabsimb[i] = NULL;
}

/*
    ProcuraSimb (cadeia): Procura cadeia na tabela de simbolos;
    Caso ela ali esteja, retorna um ponteiro para sua celula;
    Caso contrario, retorna NULL.
 */

simbolo ProcuraSimb (char *cadeia, simbolo escaux) {
    simbolo s; int i;
    i = hash (cadeia);
    for (s = tabsimb[i]; (s != NULL) && (strcmp(cadeia, s->cadeia) || s->escopo != escaux);
        s = s->prox);
    return s;
}

/*
    InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
    simbolos, com tid como tipo de identificador e com tvar como
    tipo de variavel; Retorna um ponteiro para a celula inserida
 */

simbolo InsereSimb (char *cadeia, int tid, int tvar, simbolo escopo) {
    /* Código comum a todos os identificadores */
    int i; simbolo aux, s;
    i = hash (cadeia); aux = tabsimb[i];
    s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
    s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
    strcpy (s->cadeia, cadeia);
    s->tid = tid;
    s->tvar = tvar;
    s->inic = FALSE;
    s->ref = FALSE;
    s->prox = aux;
    s->escopo = escopo;
    s->listvar = NULL;
    s->listparam = NULL;
    s->listfunc = NULL;

    /* Código para parâmetros e variáveis globais e locais */ 
    if (declparam) {
        s->inic = s->ref = s->param = TRUE;
        if (s->tid == IDVAR)
            InsereListSimb(s, &pontparam);
        s->escopo->nparam++;
    }
    else {
        s->inic = s->ref = s->param = TRUE;
        if (s->tid == IDVAR)
            InsereListSimb(s, &pontvar);
    }

    /* Código para identificados global ou nome de função */

    /* 

    O Código a seguir foi substituido e inserido dentro da função InsereListSimb
    Isto deve-se aos autores não estarem utilizando nó-cabeça; */

    if (tid == IDGLOB || tid == IDFUNC || tid == IDPROC) {
        s->listvar = (elemlistsimb *) malloc(sizeof(elemlistsimb));
        s->listvar->prox = NULL;
    }

    /* Código para nome de função e retorno de Inserir */
    if (tid == IDFUNC || tid == IDPROC) {
        s->listparam = (elemlistsimb *) malloc(sizeof(elemlistsimb));
        s->listparam->prox = NULL;
        s->nparam = 0;
    }

    return s;
}

/*
    hash (cadeia): funcao que determina e retorna a classe
    de cadeia na tabela de simbolos implementada por hashing
 */

int hash (char *cadeia) {
    int i, h;
    for (h = i = 0; cadeia[i]; i++) {h += cadeia[i];}
    h = h % NCLASSHASH;
    return h;
}

/* ImprimeTabSimb: Imprime todo o conteudo da tabela de simbolos  */

void ImprimeTabSimb () {
    int i; simbolo s;
    printf ("\n\n   TABELA  DE  SIMBOLOS:\n\n");
    for (i = 0; i < NCLASSHASH; i++)
        if (tabsimb[i]) {
            printf ("Classe %d:\n", i);
            for (s = tabsimb[i]; s!=NULL; s = s->prox){
                printf ("  (%s, %s", s->cadeia,  nometipid[s->tid]);
                if (s->tid == IDVAR){
                    printf (", %s, %d, %d", nometipvar[s->tvar], s->inic, s->ref);
                    if(s->array == TRUE){
                        int j;
                        printf("EH ARRAY\n \tdims = %d, dimensoes:", s->ndims);
                            for(j = 1; j <= s->ndims; j++)
                                printf(" %d", s->dims[j]);
                    }
                }
                if (s->escopo != NULL)
                    printf(" | Escopo: %s", s->escopo->cadeia);
                printf(")\n");
            }
        }
}

void VerificaInicRef () {
    int i; simbolo s;

    printf ("\n");
    for (i = 0; i < NCLASSHASH; i++)
        if (tabsimb[i])
            for (s = tabsimb[i]; s!=NULL; s = s->prox)
                if (s->tid == IDVAR) {
                    if (s->inic == FALSE)
                        printf ("%s: Nao Inicializada\n", s->cadeia);
                    if (s->ref == FALSE)
                        printf ("%s: Nao Referenciada\n", s->cadeia);
                }
}

void InsereListSimb(simbolo s, listsimb lista) {
    // Percorrer até o final
    elemlistsimb *p;
    for (p = lista; p->prox != NULL; p = p->prox);

    // Inserir o simbolo
    p->prox = (elemlistsimb *) malloc (sizeof(elemlistsimb));
    p->prox->prox = NULL;
    p->prox->simb = s;

    printf("\n\n ==== ADICIONANDO Outros %s ====\n\n", s->escopo->cadeia);
}

void Esperado(char *s) {
    printf("\n\n*****Esperado: %s *****\n\n", s);
}

void NaoEsperado(char *s) {
    printf("\n\n*****Nao Esperado: %s *****\n\n", s);
}


/*  Mensagens de erros semanticos  */

void DeclaracaoRepetida (char *s) {
    printf ("\n\n***** Declaracao Repetida: %s *****\n", s);
}

void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}

void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}

void Incompatibilidade (char *s) {
    printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
}

listtipo InicListTipo(int tipo) {
    pontexprtipo p = (elemlisttipo *) malloc (sizeof(elemlisttipo));
    p->prox = (elemlisttipo *) malloc (sizeof(elemlisttipo));
    p->prox->tipo = tipo;
    p->prox->prox = NULL;
    return p;
}

listtipo ConcatListTipo(listtipo lista1, listtipo lista2) {
    pontexprtipo p;

    // Percorre a lista até o final
    for (p = lista1; p->prox != NULL; p = p->prox);

    // Adiciona a segunda lista ao final da primeira
    p->prox = lista2->prox;

    return lista1;
}

void ChecArgumentos(pontexprtipo Ltiparg, listsimb Lparam) {
    pontexprtipo p;
    pontelemlistsimb q;

    p = Ltiparg->prox;
    q = Lparam->prox;

    while (p != NULL && q != NULL) {
        switch (q->simb->tvar) {
            case INTEGER: case CHAR:
                if (p->tipo != INTEGER && p->tipo != CHAR)
                    Incompatibilidade("....");
                break;
            case FLOAT:
                if (p->tipo != INTEGER &&  p->tipo != CHAR && p->tipo != FLOAT)
                    Incompatibilidade("....");
                break;
            case LOGICAL:
                if (p->tipo != LOGICAL)
                    Incompatibilidade("....");
                break;
            default:
                if (q->simb->tvar != p->tipo)
                    Incompatibilidade("....");
                break;
        }
        p = p->prox; 
        q = q->prox;
    }
}

void MsgErro (char *s) {
    printf ("\n***** Erro: %s *****\n", s);
}