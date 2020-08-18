%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* === Declaracoes de tipos === */

enum tipos {
    SOMA=1, SUB, MULT, DIV, MOD, EQ, NEQ, LT, LEQ, GT, GEQ, FINAL
};

enum identificadores {
    IDGLOB=0, IDPROG, IDVAR, IDFUNC, IDPROC
};

enum tiposvar {
    NOTVAR=0, INTEGER, LOGICAL, FLOAT, CHAR, END
};

enum operandos {
    OPOR=1, OPAND, OPLT, OPLE, OPGT, OPGE, OPEQ, OPNE, OPMAIS, OPMENOS, OPMULTIP, OPDIV, OPRESTO, OPMENUN, OPNOT, OPATRIB, OPENMOD, NOP, OPJUMP, OPJF, PARAM, OPREAD, OPWRITE, OPJT, OPIND, OPINDEX, OPATRIBPONT, OPCONTAPONT, OPCALL, OPRETURN, OPEXIT
};

enum tiposoperandos {
    IDLEOPND=0, VAROPND, INTOPND, REALOPND, CHAROPND, LOGICOPND, CADOPND, ROTOPND, MODOPND, PONTOPND 
};

/* === Constantes === */

#define NCLASSHASH  23
#define TRUE         1
#define FALSE        0
#define MAXDIMS     10

/*  === Nomes ===  */

char *nometipid[5] = {"GLOBAL", "IDPROG", "IDVAR", "IDFUNC","IDPROC"};
char *nometipvar[6] = {"NOTVAR", "INTEGER", "LOGICAL", "FLOAT", "CHAR", "ADDRESS"};
char *nomeoperquad[32] = {"",
	"OR", "AND", "LT", "LE", "GT", "GE", "EQ", "NE", "MAIS",
	"MENOS", "MULT", "DIV", "RESTO", "MENUN", "NOT", "ATRIB",
	"OPENMOD", "NOP", "JUMP", "JF", "PARAM", "READ", "WRITE", 
    "JT", "IND", "INDEX", "ATRIBPONT", "CONTAPONT", "CALL", "RETURN", "EXIT"
};
char *nometipoopndquad[10] = {"IDLE", "VAR", "INT", "REAL", "CARAC", "LOGIC", "CADEIA", "ROTULO", "MODULO", "VAR"};

/* === Definições de Tipos: Análises Léxica, Sintática e Semântica === */
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

/* === Definições de Tipos: Código Intermediário === */
typedef union atribopnd atribopnd;
typedef struct operando operando;
typedef struct celquad celquad;
typedef celquad *quadrupla;
typedef struct celmodhead celmodhead;
typedef celmodhead *modhead;
typedef struct infoexpressao infoexpressao;
typedef struct infovariavel infovariavel;

/* === Definições de Tipos: Execução do CI === */
typedef struct nohopnd nohopnd;
typedef nohopnd *pilhaoperando;

/* === Estruturas: Análises Léxica, Sintática e Semântica === */
struct celsimb {
    char *cadeia;
    int  tid, tvar, ndims, nparam, dims[MAXDIMS+1], *valint;
    float *valfloat;
    char *valaddr;
    char inic, ref, array, param, *valchar, *vallogic;
    listsimb listvar, listparam, listfunc;
    simbolo escopo, prox;
    modhead fhead;
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

/* === Estruturas: Código Intermediário === */
union atribopnd {
    simbolo simb; 
    int valint; 
    float valfloat;
    char valchar, vallogic; 
    char *valcad;
    int *valpontint;
    quadrupla rotulo;
    modhead modulo;
};

struct operando {
    int tipo;
    atribopnd atr;
};

struct celquad {
    int num, oper; 
    operando opnd1, opnd2, result;
    quadrupla prox;
};

struct celmodhead {
    simbolo modname;
    modhead prox;
    quadrupla listquad;
};

struct infoexpressao {
	int tipo;
	operando opnd;
};

struct infovariavel {
	simbolo simb;
	operando opnd;
};

/* === Estruturas: Execução do CI  === */
struct nohopnd {
    operando opnd;
    nohopnd *prox;
};


/* ===  Variaveis globais: Análises Léxica, Sintática e Semântica === */
simbolo tabsimb[NCLASSHASH];
simbolo simb, escopo, escaux;
int tipocorrente = 0;
int tab = 0;
bool declparam = FALSE;
bool semanticamente_valido = TRUE;
listsimb pontvar;
listsimb pontparam;
listsimb pontfunc;

/* ===  Variaveis globais: Código Intermediário === */
quadrupla quadcorrente, quadaux, quadaux2;
modhead codintermed, modcorrente, modglobal;
int oper, numquadcorrente;
operando opnd1, opnd2, result, opndaux, opndaux2;
int numtemp;
const operando opndidle = {IDLEOPND, 0};

/* ===  Variaveis globais:  Execução do CI === */
 FILE *finput;
 pilhaoperando pilhaopnd;
 pilhaoperando pilhachamadas;
 pilhaoperando pilhaindices;

/* === Prototipos: Análises Léxica, Sintática e Semântica === */
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
void ChecaChamarId(char *);
void ChecaSeEhProcedimento(char *, simbolo);
simbolo InsereSimbDedup (char *, int, int, simbolo);

/* === Prototipos: Código Intermediário === */
void InicCodIntermed (void);
void InicCodIntermMod (simbolo);
void ImprimeQuadruplas (void);
quadrupla GeraQuadrupla (int, operando, operando, operando);
simbolo NovaTemp (int);
void RenumQuadruplas (quadrupla, quadrupla);

void InicPilhaOpnd (pilhaoperando*);
operando TopoOpnd (pilhaoperando);
void DesempilharOpnd (pilhaoperando*);
char VaziaOpnd (pilhaoperando);
void EmpilharOpnd (operando, pilhaoperando*);

void InterpCodIntermed (void);
void AlocaVariaveis (void);
void ExecQuadWrite (quadrupla);
void ExecQuadMais (quadrupla);
void ExecQuadMenos (quadrupla);
void ExecQuadMult(quadrupla);
void ExecQuadDiv(quadrupla);
void ExecQuadResto(quadruple);
void ExecQuadMenum(quadrupla);
void ExecQuadNot(quadrupla);
void ExecQuadLT (quadrupla);
void ExecQuadAtrib (quadrupla);
void ExecQuadRead (quadrupla);

void ExecQuadAND (quadrupla);
void ExecQuadOR (quadrupla);
void ExecQuadLE (quadrupla);
void ExecQuadGT (quadrupla);
void ExecQuadGE (quadrupla);
void ExecQuadEQ (quadrupla);
void ExecQuadNE (quadrupla);

%}

%union {
    char string[50];
    int atr, valint;
    int valor;
    float valreal;
    char carac;
    simbolo simb;
    quadrupla quad;
    int tipoexpr, nsubscr, nargs;
    infolistexpr infolexpr;
    infoexpressao infoexpr;
	infovariavel infovar;
}        

/* === Atributos e Tokens === */
%type     <infovar>     Variavel ChamadaFunc
%type     <infoexpr>    Expressao  ExprAux1  ExprAux2 ExprAux3   ExprAux4   Termo   Fator ElemEscr
%type     <infolexpr>   ListExpr Argumentos 
%type     <nsubscr>     ListSubscr Subscritos 
%type     <nargs>       ListLeit ListEscr

%token    <string>      ID
%token    <valor>       CTINT
%token    <carac>       CTCARAC
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
%token    <simb>        RETORNAR
%token    <quad>        SE
%token    <quad>        SENAO
%token                  VAR
%token                  VERDADE
%token                  INVAL
%%

Prog        :   {
                    InicTabSimb ();
                    InicCodIntermed ();
                    declparam = FALSE; 
                    simb = escopo = InsereSimb("##global", IDGLOB, NOTVAR, NULL);
                    pontvar = simb->listvar;
                    pontparam = simb->listparam;
                    pontfunc = simb->listfunc;
                    numtemp=0;
                } 
                PROGRAMA ID ABTRIP {
                    tabular(); 
                    InsereSimb ($3, IDPROG, NOTVAR, escopo);
                    modglobal = modcorrente;
                    printf("programa %s {{{", $3);
                    tab++; 
                    printf("\n");
                }  Decls ListMod ModPrincipal FTRIP {
                    printf("\n"); 
                    printf("}}}\n");

                    opnd2.tipo = MODOPND;
                    opnd2.atr.modulo = modcorrente;
                    opnd1.tipo = MODOPND;
                    opnd1.atr.modulo = modglobal;
                    modcorrente = modglobal;
                    quadcorrente = modcorrente->listquad;
                    numquadcorrente = 0;
                    quadcorrente->num = numquadcorrente;
                    GeraQuadrupla (OPENMOD, opnd1, opndidle, opndidle);
                    GeraQuadrupla (OPCALL, opnd2, opndidle, opndidle);
                    GeraQuadrupla (OPEXIT, opndidle, opndidle, opndidle);

                    VerificaInicRef();
                    ImprimeTabSimb();
                    ImprimeQuadruplas();
                    InterpCodIntermed();
                    if (semanticamente_valido) 
                        printf("\n\nPrograma Compilado com Sucesso!\n\n");
                    else 
                        printf("\n\nPROGRAMA COM ERROS SEMÂNTICOS!\n\n");

                    return;
                }
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
                        printf ("%s", $1);
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
                                                simb = escopo = InsereSimb($3, IDFUNC, tipocorrente, escopo);
                                            else {
                                                DeclaracaoRepetida($3);
                                                if(simb->tid == IDVAR)
                                                    MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                                
                                                // Adiciona um novo escopo com caracteres underline no final só para evitar a repetição
                                                simb = escopo = InsereSimbDedup($3, IDFUNC, tipocorrente, escopo);
                                            }
                                            pontvar = simb->listvar;
                                            printf("%s ()", $3);
                                        }
            |   FUNCAO Tipo ID ABPAR {
                                        simb = ProcuraSimb($3, escopo); 
                                        if (simb == NULL)
                                            simb = escopo = InsereSimb($3, IDFUNC, tipocorrente, escopo);
                                        else {
                                            DeclaracaoRepetida($3);
                                            if(simb->tid == IDVAR)
                                                MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                            
                                            // Adiciona um novo escopo com caracteres underline no final só para evitar a repetição
                                            simb = escopo = InsereSimbDedup($3, IDFUNC, tipocorrente, escopo);
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
                                                    if(simb->tid == IDVAR)
                                                        MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                                    
                                                    // Adiciona um novo escopo com caracteres underline no final só para evitar a repetição
                                                    simb = escopo = InsereSimbDedup($2, IDPROC, tipocorrente, escopo);
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
                                            if(simb->tid == IDVAR)
                                                MsgErro("Um módulo não pode ter o mesmo nome que o de uma variável global");
                                            // Adiciona um novo escopo com caracteres underline no final só para evitar a repetição
                                            simb = escopo = InsereSimbDedup($2, IDPROC, tipocorrente, escopo);
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
Corpo       :   Decls Comandos { 
                                simb = ProcuraSimb(escopo->cadeia, escopo->escopo);
                                if (simb) {
                                    if (simb->tid == IDPROC)
                                        GeraQuadrupla(OPRETURN, opndidle, opndidle, opndidle);
                                }
                                escopo = escopo->escopo;
                            }
            ;
ModPrincipal:   {printf("\n"); tabular();} PRINCIPAL {escopo = InsereSimb("##principal", IDPROG, NOTVAR, escopo); printf("principal \n"); tab++;}  Corpo {printf("\n"); tab--; GeraQuadrupla(OPRETURN, opndidle, opndidle, opndidle);}
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
CmdSe       :   SE   ABPAR {printf("se (");}  Expressao 
                {
                    if ($4.tipo != LOGICAL) Incompatibilidade("Expressao nao logica");
                    opndaux.tipo = ROTOPND;
                    $<quad>$ = GeraQuadrupla(OPJF, $4.opnd, opndidle, opndaux);
                } 
                FPAR { printf(") "); tab++;} Comando 
                {
                    $<quad>$ = quadcorrente;
                    $<quad>5->result.atr.rotulo = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                }
                CmdSenao 
                {
                    tab--;
                    if ($<quad>9->prox != quadcorrente) {
                        quadaux = $<quad>9->prox;
                        $<quad>9->prox = quadaux->prox;
                        quadaux->prox = $<quad>9->prox->prox;
                        $<quad>9->prox->prox = quadaux;
                        RenumQuadruplas ($<quad>9, quadcorrente);
                    }
                } 
            ;  
CmdSenao    : 
            |  SENAO   
            {
                tab--; printf("\n"); tabular(); printf("senao "); tab++;
                opndaux.tipo = ROTOPND;
                $<quad>$ = GeraQuadrupla(OPJUMP, opndidle, opndidle, opndaux);
            } Comando
            {
                $<quad>2->result.atr.rotulo = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
            }
            ;
CmdEnquanto :  ENQUANTO   ABPAR  
                {
                   printf("enquanto (");
                   $<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                } Expressao 
                {
                    if ($4.tipo != LOGICAL) Incompatibilidade("Expressao nao logica");
                    opndaux.tipo = ROTOPND;
                    $<quad>$ = GeraQuadrupla(OPJF, $4.opnd, opndidle, opndaux);
                } FPAR {printf(") "); tab++;} 
                Comando 
                {
                    tab--;
                    opndaux.tipo = ROTOPND;
                    opndaux.atr.rotulo = $<quad>3;
                    GeraQuadrupla(OPJUMP, opndidle, opndidle, opndaux);
                    opndaux.atr.rotulo = $<quad>5->result.atr.rotulo = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                } 
            ;
CmdRepetir  :  REPETIR 
               {
                    printf("repetir \n"); tab++;
                    $<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
               } 
               Comando  ENQUANTO ABPAR {printf("enquanto (");} Expressao 
               {
                   if ($7.tipo != LOGICAL) Incompatibilidade("Expressao nao logica");} FPAR  PVIG {printf(");");
                   opndaux.tipo = ROTOPND;
                   opndaux.atr.rotulo = $<quad>2;
                   GeraQuadrupla(OPJT, $7.opnd, opndidle, opndaux);
               } 
            ;
CmdPara     :  PARA {printf("para ");} Variavel 
               {
                    if ($3.simb->tvar != CHAR && $3.simb->tvar != INTEGER) Incompatibilidade("Expressao nao inteiro ou caractere");
                } 
               ABPAR {printf(" (");}  ExprAux4 {
                   GeraQuadrupla (OPATRIB, $7.opnd, opndidle, $3.opnd);
                   if ($7.tipo != INTEGER && $7.tipo != CHAR) Incompatibilidade("Expressao nao inteiro ou caractere");
                } 
               PVIG {
                   printf("; ");
                   // 1
                   $<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                }  Expressao 
                {
                    if ($11.tipo != LOGICAL) Incompatibilidade("Expressao nao logica");
                    // 12
                    opndaux.tipo = ROTOPND;
                    $<quad>$ = GeraQuadrupla(OPJF, $11.opnd, opndidle, opndaux);
                } PVIG 
                {
                    printf("; ");
                    // 14
                    $<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                } 
               ExprAux4 {if ($15.tipo != INTEGER && $15.tipo != CHAR) Incompatibilidade("Expressao nao inteiro ou caractere");} 
               FPAR {
                   //18
                   printf(") "); tab++;
                   GeraQuadrupla (OPATRIB, $15.opnd, opndidle, $3.opnd);
                   $<quad>$ = quadcorrente;
                }
                {//19
                    $<quad>$ = GeraQuadrupla(NOP, opndidle, opndidle, opndidle);
                } 
                /*{// 20
                    $<quad>$ = GeraQuadrupla (OPATRIB, $15.opnd, opndidle, $3.opnd);
                }*/
                Comando {
                    tab--;
                    quadaux = quadcorrente;
                    opndaux.tipo = ROTOPND; 
                    opndaux.atr.rotulo =$<quad>10;
                    quadaux2 = GeraQuadrupla(OPJUMP, opndidle, opndidle, opndaux);
                    $<quad>12->result.atr.rotulo = GeraQuadrupla(NOP, opndidle, opndidle, opndidle); // certo

                    
                    $<quad>12->prox = $<quad>19;
                    quadaux->prox = $<quad>14;
                    $<quad>18->prox = quadaux2;
                    RenumQuadruplas ($<quad>12, quadcorrente);
                }
            ;
CmdLer      :  LER   ABPAR  {printf("ler (");} ListLeit  FPAR
               {
                    opnd1.tipo = INTOPND;
                    opnd1.atr.valint = $4;
                    if ($4 > 0)
                        GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);     
               }  PVIG {printf(");");} 
            ;        
ListLeit    :  Variavel  
               {
                    if  ($1.simb != NULL) $1.simb->inic = $1.simb->ref = TRUE;
                    $$ = 1;
                    if ($1.opnd.tipo == PONTOPND) {
                        opndaux.tipo = VAROPND;
                        opndaux.atr.simb = NovaTemp (VAROPND);
                        GeraQuadrupla(PARAM, opndaux, opndidle, opndidle);
                        opnd1.tipo = INTOPND;
                        opnd1.atr.valint = 1;
                        GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);
                        GeraQuadrupla(OPATRIBPONT, opndaux, opndidle, $1.opnd);
                        $$ = 0;
                    }
                    else
                        quadaux = GeraQuadrupla(PARAM, $1.opnd, opndidle, opndidle);
               }
            |  ListLeit  VIRG {printf(", ");} Variavel {
                if  ($4.simb != NULL) $4.simb->inic = $4.simb->ref = TRUE;
                $$ = $1 + 1;
                if ($4.opnd.tipo == PONTOPND) {
                    opnd1.tipo = INTOPND;
                    opnd1.atr.valint = $1;
                    $<quad>$ = quadcorrente;
                    GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);
                    // ----- Reorder -----
                    quadcorrente->prox = quadaux->prox;
                    quadaux->prox = quadcorrente;
                    quadcorrente = $<quad>$;
                    // --------------------
                    opndaux.tipo = VAROPND;
                    opndaux.atr.simb = NovaTemp (VAROPND);
                    GeraQuadrupla(PARAM, opndaux, opndidle, opndidle);
                    opnd1.tipo = INTOPND;
                    opnd1.atr.valint = 1;
                    GeraQuadrupla(OPREAD, opnd1, opndidle, opndidle);
                    GeraQuadrupla(OPATRIBPONT, opndaux, opndidle, $4.opnd);
                    // ----- Renumerate -----
                    RenumQuadruplas(quadaux, quadcorrente);
                    $$ = 0;
                }
                else
                    quadaux = GeraQuadrupla(PARAM, $4.opnd, opndidle, opndidle);
            }
            ;  
CmdEscrever :  ESCREVER   ABPAR {printf("escrever (");} ListEscr  
               {
                   opnd1.tipo = INTOPND;
                   opnd1.atr.valint = $4;
                   GeraQuadrupla (OPWRITE, opnd1, opndidle, opndidle);
               }
               FPAR  PVIG {printf(");");}  
            ;    
ListEscr    :  ElemEscr  
                {
                    $$ = 1;
                    GeraQuadrupla(PARAM, $1.opnd, opndidle, opndidle);
                }
            |  ListEscr  VIRG {printf(", ");} ElemEscr 
                {
                    $$ = $1 + 1;
                    GeraQuadrupla(PARAM, $4.opnd, opndidle, opndidle);
                }
            ;    
ElemEscr    :  CADEIA 
               {
                    printf("%s", $1);
                    $$.opnd.tipo = CADOPND;
                    $$.opnd.atr.valcad = malloc(strlen($1) + 1);
                    strcpy($$.opnd.atr.valcad, $1);
               }
            |  Expressao 
            ;    
ChamadaProc :  CHAMAR   ID  ABPAR {printf("chamar %s (", $2); ChecaSeEhProcedimento($2, escopo); ChecaRecursividade($2, escopo); ChecaChamarId($2);} Argumentos  FPAR  PVIG  {
                            printf(");");
                            simb = ProcuraSimb($2, escopo->escopo);
                            opnd1.tipo = MODOPND;
                            opnd1.atr.modulo = simb->fhead;
                            opnd2.tipo = INTOPND;
                            opnd2.atr.valint = $5.nargs;
                            GeraQuadrupla(OPCALL, opnd1, opnd2, opndidle);
                        }
            ;    
Argumentos  :  {$$.nargs = 0; $$.listtipo = NULL;}
            |  ListExpr 
            ;
CmdRetornar :  RETORNAR   PVIG  {printf("retornar ;"); if (escopo->tvar != NOTVAR) Incompatibilidade ("Retorno da funcao improprio"); GeraQuadrupla(OPRETURN, opndidle, opndidle, opndidle);} 
            |  RETORNAR {printf("retornar ");} Expressao  PVIG {
                                                                    printf(";");
                                                                    if (((escopo->tvar == INTEGER || escopo->tvar == CHAR) &&
                                                                        ($3.tipo == FLOAT || $3.tipo == LOGICAL)) ||
                                                                        (escopo->tvar == FLOAT && $3.tipo == LOGICAL) ||
                                                                        (escopo->tvar == LOGICAL && $3.tipo != LOGICAL))
                                                                            Incompatibilidade ("Retorno da funcao improprio");
                                                                    else if( escopo->tvar == NOTVAR )
                                                                        Incompatibilidade ("Procedimento nao deve retornar variavel");
                                                                    GeraQuadrupla(OPRETURN, $3.opnd, opndidle, opndidle);
                                                               }  
            ;        
CmdAtrib    :  Variavel {if  ($1.simb != NULL) $1.simb->inic = $1.simb->ref = TRUE;}  
               ATRIB {printf(" = ");}  Expressao  PVIG 
               {
                   printf(";");
                   if ($1.simb != NULL)
                        if ((($1.simb->tvar == INTEGER || $1.simb->tvar == CHAR) &&
                            ($5.tipo == FLOAT || $5.tipo == LOGICAL)) ||
                            ($1.simb->tvar == FLOAT && $5.tipo == LOGICAL) ||
                            ($1.simb->tvar == LOGICAL && $5.tipo != LOGICAL))
                                Incompatibilidade ("Lado direito de comando de atribuicao improprio");
                        if ($1.opnd.tipo == PONTOPND) {
                            GeraQuadrupla (OPATRIBPONT, $5.opnd, opndidle, $1.opnd);
                        }
                        else
                            GeraQuadrupla (OPATRIB, $5.opnd, opndidle, $1.opnd);
                } 
            ;
ListExpr    :  Expressao {
                            $$.nargs = 1;
                            $$.listtipo = InicListTipo($1.tipo);
                            GeraQuadrupla(PARAM, $1.opnd, opndidle, opndidle);
                         }
            |  ListExpr  VIRG {printf(", ");} Expressao {
                                                            $$.nargs = $1.nargs + 1;
                                                            $$.listtipo = ConcatListTipo($1.listtipo, InicListTipo($4.tipo));
                                                            GeraQuadrupla(PARAM, $4.opnd, opndidle, opndidle);
                                                        }
            ;    
Expressao   :  ExprAux1 
            |  Expressao  OR {printf(" || ");} ExprAux1 {
                        if ($1.tipo != LOGICAL || $4.tipo != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador or");
                        $$.tipo = LOGICAL;
                        $$.opnd.tipo = VAROPND;
                        $$.opnd.atr.simb = NovaTemp ($$.tipo);
                        GeraQuadrupla (OPOR, $1.opnd, $4.opnd, $$.opnd);
                    }
            ;    
ExprAux1    :  ExprAux2 
            |  ExprAux1  AND {printf(" && ");} ExprAux2 {
                        if ($1.tipo != LOGICAL || $4.tipo != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador and");
                        $$.tipo = LOGICAL;
                        $$.opnd.tipo = VAROPND;
                        $$.opnd.atr.simb = NovaTemp ($$.tipo);
                        GeraQuadrupla (OPAND, $1.opnd, $4.opnd, $$.opnd);
                    }
            ;    
ExprAux2    :  ExprAux3 
            |  NOT {printf("!");} ExprAux3 {
                        if ($3.tipo != LOGICAL)
                            Incompatibilidade ("Operando improprio para operador not");
                        $$.tipo = LOGICAL;
                        $$.opnd.tipo = VAROPND;
                        $$.opnd.atr.simb = NovaTemp ($3.tipo);
                        GeraQuadrupla (OPNOT, $3.opnd, opndidle, $$.opnd);
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
                                if ($1.tipo != INTEGER && $1.tipo != FLOAT && $1.tipo != CHAR || $4.tipo != INTEGER && $4.tipo != FLOAT && $4.tipo != CHAR)
                                    Incompatibilidade    ("Operando improprio para operador relacional");
                                break;
                            case EQ: case NEQ:
                                if (($1.tipo == LOGICAL || $4.tipo == LOGICAL) && $1.tipo != $4.tipo)
                                    Incompatibilidade ("Operando improprio para operador relacional");
                                break;
                        }
                        $$.tipo = LOGICAL;
                        $$.opnd.tipo = VAROPND;
                        $$.opnd.atr.simb = NovaTemp ($$.tipo);
                        switch ($2) {
                            case LT:
                                GeraQuadrupla (OPLT, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case LEQ:
                                GeraQuadrupla (OPLE, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case GT:
                                GeraQuadrupla (OPGT, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case GEQ:
                                GeraQuadrupla (OPGE, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case EQ:
                                GeraQuadrupla (OPEQ, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case NEQ:
                                GeraQuadrupla (OPNE, $1.opnd, $4.opnd, $$.opnd);
                                break;
                        }
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
                        if ($1.tipo != INTEGER && $1.tipo != FLOAT && $1.tipo != CHAR || $4.tipo != INTEGER && $4.tipo !=FLOAT && $4.tipo !=CHAR)
                            Incompatibilidade ("Operando improprio para operador aritmetico");
                        if ($1.tipo == FLOAT || $4.tipo == FLOAT) $$.tipo = FLOAT;
                        else $$.tipo = INTEGER;
                        $$.opnd.tipo = VAROPND;
                        $$.opnd.atr.simb = NovaTemp ($$.tipo);
                        if ($2 == SOMA)
                            GeraQuadrupla (OPMAIS, $1.opnd, $4.opnd, $$.opnd);
                        else  GeraQuadrupla (OPMENOS, $1.opnd, $4.opnd, $$.opnd);
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
                                if ($1.tipo != INTEGER && $1.tipo != FLOAT && $1.tipo != CHAR
                                    || $4.tipo != INTEGER && $4.tipo !=FLOAT && $4.tipo != CHAR)
                                    Incompatibilidade ("Operando improprio para operador aritmetico");
                                if ($1.tipo == FLOAT || $4.tipo == FLOAT) $$.tipo = FLOAT;
                                else $$.tipo = INTEGER;
                                $$.opnd.tipo = VAROPND;
                                $$.opnd.atr.simb = NovaTemp($$.tipo);
                                if($2 == MULT)
                                    GeraQuadrupla(OPMULTIP, $1.opnd, $4.opnd, $$.opnd);
                                else
                                    GeraQuadrupla(OPDIV, $1.opnd, $4.opnd, $$.opnd);
                                break;
                            case MOD:
                                if ($1.tipo != INTEGER && $1.tipo != CHAR
                                    ||  $4.tipo != INTEGER && $4.tipo != CHAR)
                                    Incompatibilidade ("Operando improprio para operador resto");
                                $$.tipo = INTEGER;
                                $$.opnd.tipo = VAROPND;
                                $$.opnd.atr.simb = NovaTemp($$.tipo);
                                GeraQuadrupla(OPRESTO, $1.opnd, $4.opnd, $$.opnd);
                                break;
                        }
                    }
            ;    
Fator       :  Variavel {
                        if  ($1.simb != NULL) {
                            $1.simb->ref = TRUE;
                            $$.tipo = $1.simb->tvar;
                            $$.opnd = $1.opnd;
                            if ($1.opnd.tipo == PONTOPND) {
                                $$.opnd.tipo = VAROPND;
                                $$.opnd.atr.simb = NovaTemp($$.tipo);
                                GeraQuadrupla(OPCONTAPONT, $1.opnd, opndidle, $$.opnd);
                            }
                        }
                    }
            |  CTINT {printf ("%d", $1); $$.tipo = INTEGER; $$.opnd.tipo = INTOPND; $$.opnd.atr.valint = $1;}
            |  CTREAL {printf ("%g", $1); $$.tipo = FLOAT; $$.opnd.tipo = REALOPND; $$.opnd.atr.valfloat = $1;}
            |  CTCARAC {printf("\'%c\' ", $1); $$.tipo = CHAR; $$.opnd.tipo = CHAROPND; $$.opnd.atr.valchar = $1;}
            |  VERDADE  {printf("verdade"); $$.tipo = LOGICAL; $$.opnd.tipo = LOGICOPND; $$.opnd.atr.vallogic = 1;}
            |  FALSO  {printf("falso"); $$.tipo = LOGICAL; $$.opnd.tipo = LOGICOPND; $$.opnd.atr.vallogic = 0;}
            |  NEG {printf("~");} Fator {
                        if ($3.tipo != INTEGER &&
                            $3.tipo != FLOAT && $3.tipo != CHAR)
                            Incompatibilidade  ("Operando improprio para menos unario");
                            if ($3.tipo == FLOAT) $$.tipo = FLOAT;
                            else $$.tipo = INTEGER;
                            $$.opnd.tipo = VAROPND;
                            $$.opnd.atr.simb = NovaTemp($$.tipo);
                            GeraQuadrupla(OPMENUN, $3.opnd, opndidle, $$.opnd);
                    }
            |  ABPAR  Expressao  FPAR {$$.tipo = $2.tipo; $$.opnd = $2.opnd;}
            |  ChamadaFunc 
            ;
Variavel    : ID  {
                        printf ("%s", $1);
                        escaux = escopo;
                        simb = ProcuraSimb ($1, escaux);
                        while (escaux && !simb) {
                            escaux = escaux->escopo;
                            if (escaux)
                                simb = ProcuraSimb ($1, escaux);
                        }
                        if (simb == NULL)   {
                            NaoDeclarado ($1);
                            simb = InsereSimbDedup($1, IDVAR, tipocorrente, escopo);
                        }
                        else if (simb->tid != IDVAR)   TipoInadequado ($1);
                        $<simb>$ = simb;
                    }  Subscritos  {
                                    $$.simb = $<simb>2;
                                    if($$.simb != NULL) {
                                        if($$.simb->array == FALSE && $3 > 0)
                                            NaoEsperado("Subscrito\(s)");
                                        else if($$.simb->array == TRUE && $3 == 0){
                                            Esperado("Subscrito\(s)");
                                        }
                                        else if($$.simb->ndims!= $3)
                                            Incompatibilidade("Numero de subscritos incompativel com declaracao");
                                        if ($3 == 0) {
                                            $$.opnd.tipo = VAROPND;
                                            $$.opnd.atr.simb = $$.simb;
                                        }
                                        else {
                                            opndaux.tipo = VAROPND;
                                            opndaux.atr.simb = $<simb>2;
                                            opndaux2.tipo = INTOPND;
                                            opndaux2.atr.valint = $3;
                                            $$.opnd.tipo = PONTOPND;
                                            $$.opnd.atr.simb = NovaTemp(VAROPND);
                                            GeraQuadrupla(OPINDEX, opndaux, opndaux2, $$.opnd);
                                        }
                                    }
                        }
            ;    
Subscritos  :  {$$ = 0;}
            |  ABCOL {printf("[");}  ListSubscr  FCOL  { printf("]"); $$ = $3; }
            ;    
ListSubscr  :  ExprAux4 {
                            if($1.tipo != INTEGER && $1.tipo != CHAR) Incompatibilidade("Tipo inadequado para subscrito");
                            $$ = 1;
                            GeraQuadrupla(OPIND, $1.opnd, opndidle, opndidle);
                        }
            |  ListSubscr  VIRG {printf(", ");}  ExprAux4 {
                            if($4.tipo != INTEGER && $4.tipo != CHAR) Incompatibilidade("Tipo inadequado para subscrito");
                            $$ = $1 + 1;
                            GeraQuadrupla(OPIND, $4.opnd, opndidle, opndidle);
                        }
            ;    
ChamadaFunc :   ID  ABPAR  {
                                printf("%s (", $1);
                                simb = ProcuraSimb ($1, escopo->escopo);
                                ChecaRecursividade($1, escopo);
                                if (!simb) {
                                    NaoDeclarado($1);
                                    simb = InsereSimbDedup($1, IDFUNC, tipocorrente, escopo);
                                }
                                else if (simb->tid != IDFUNC)
                                    TipoInadequado($1);
                                $<simb>$ = simb;
                           } 
                           Argumentos  FPAR {
                                                printf(")");
                                                $$.simb = $<simb>3;
                                                if ($$.simb && $$.simb->tid == IDFUNC) {
                                                    if ($$.simb->nparam != $4.nargs)
                                                        Incompatibilidade("Numero de argumentos diferente do numero de parametros");
                                                    ChecArgumentos($4.listtipo, $$.simb->listparam);
                                                }
                                                opnd1.tipo = MODOPND;
                                                opnd1.atr.modulo = $$.simb->fhead;
                                                opnd2.tipo = INTOPND;
                                                opnd2.atr.valint = $4.nargs;
                                                if ($$.simb->tvar == NOTVAR)
                                                    result = opndidle;
                                                else {
                                                    result.tipo = VAROPND;
                                                    result.atr.simb = NovaTemp($$.simb->tvar);
                                                }
                                                GeraQuadrupla(OPCALL, opnd1, opnd2, result);
                                                $$.opnd = result;
                                            } 
            ;

%%

/* Inclusao do analisador lexico  */

#include "lex.yy.c"

/* ===== Funções: Análises Léxica, Sintática e Semântica ===== */
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
            InsereListSimb(s, pontparam);
        s->escopo->nparam++;
    }
    else {
        s->inic = s->ref = s->param = FALSE;
        if (s->tid == IDVAR)
            InsereListSimb(s, pontvar);
    }

    /* Código para identificados global ou nome de função */

    /* O Código a seguir foi substituido e inserido dentro da função InsereListSimb
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

    /* Se houver subprogramação abrir novo código intermediário */
    if (tid == IDFUNC || tid == IDPROC || tid == IDPROG) {
        InicCodIntermMod(s);
    }

    s->fhead = modcorrente;

    return s;
}

/*
    InsereSimbDedup (cadeia, tid, tvar): Insere cadeia na tabela de
    simbolos, deduplicando se ele já existir com tid como tipo de identificador e com tvar como
    tipo de variavel; Retorna um ponteiro para a celula inserida
 */

simbolo InsereSimbDedup (char *cadeia, int tid, int tvar, simbolo escopo) {
    simbolo simb = NULL;
    char dedup_name[60];
    strcpy(dedup_name, cadeia);
    while (simb != NULL) {
        strcat(dedup_name, "_");
        simb = ProcuraSimb(dedup_name, escopo);
    }
    return InsereSimb(dedup_name, tid, tvar, escopo);
}

/*
    ChecaRecursividade( nome, simbolo escopo): funcao que verifica se uma funcao/procedimento
    eh chamado por ele mesmo.
 */

void ChecaRecursividade(char* nome, simbolo escopo){
    // Acha na tabela o simbolo dessa funcao
    simbolo esc; int i;
    i = hash (nome);
    for (esc = tabsimb[i]; (esc != NULL) && (strcmp(nome, esc->cadeia) != 0);esc = esc->prox);

    if(esc != NULL)
        for(; esc != NULL; esc = esc->escopo){
            if(strcmp(esc->cadeia, escopo->cadeia) == 0 && (esc->tid == IDFUNC || esc->tid == IDPROC))
                printf ("\n\n***** Recursao da ma sorte! (Essa linguagem nao permite recursao) *****\n\n");
        }
}

void ChecaChamarId(char * cadeia) {
    // Acha na tabela o simbolo dessa funcao
    simbolo esc; int i;
    i = hash (cadeia);
    for (esc = tabsimb[i]; (esc != NULL) && (strcmp(cadeia, esc->cadeia) != 0);esc = esc->prox);

    // Verifica se é funcao ou procedimento
    if(esc->tid != IDFUNC && esc->tid != IDPROC)
        Incompatibilidade("O identificador de um comando chamar deve ser do tipo nome de procedimento ou funcao");
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
    printf ("\n\n===== TABELA  DE  SIMBOLOS: =====\n\n");
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
    printf ("\n\n===== VARIAVEIS NAO DECLARADAS OU NAO REFERENCIADAS: =====\n\n");
    for (i = 0; i < NCLASSHASH; i++)
        if (tabsimb[i])
            for (s = tabsimb[i]; s!=NULL; s = s->prox)
                if (s->tid == IDVAR) {
                    if (s->inic == FALSE)
                        printf ("Variavel %s (Escopo: %s): Nao Inicializada\n", s->cadeia, s->escopo->cadeia);
                    if (s->ref == FALSE)
                        printf ("Variavel %s (Escopo: %s): Nao Referenciada\n", s->cadeia, s->escopo->cadeia);
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
}

void Esperado(char *s) {
    semanticamente_valido = FALSE;
    printf("\n\n*****Esperado: %s *****\n\n", s);
}

void NaoEsperado(char *s) {
    semanticamente_valido = FALSE;
    printf("\n\n*****Nao Esperado: %s *****\n\n", s);
}


/*  Mensagens de erros semanticos  */

void DeclaracaoRepetida (char *s) {
    semanticamente_valido = FALSE;
    printf ("\n\n***** Declaracao Repetida: %s *****\n", s);
}

void NaoDeclarado (char *s) {
    semanticamente_valido = FALSE;
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}

void TipoInadequado (char *s) {
    semanticamente_valido = FALSE;
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}

void Incompatibilidade (char *s) {
    semanticamente_valido = FALSE;
    printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
}

void ChecaSeEhProcedimento(char * cadeia, simbolo escopo) {
    simbolo s; int i;
    i = hash (cadeia);
    
    // Procura o símbolo em todos os escopos
    for (s = tabsimb[i]; (s != NULL) && strcmp(cadeia, s->cadeia); s = s->prox);

    if (s == NULL)
        printf ("\n\n***** Procedimento desconhecido: %s *****\n\n", cadeia);

    if (s != NULL && s->tid != IDPROC)
        printf ("\n\n***** Procedimento desconhecido: %s *****\n\n", cadeia);
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

    if(Ltiparg) 
        p = Ltiparg->prox;
    else
        p = NULL;

    if(Lparam) 
        q = Lparam->prox;
    else
        q = NULL;

    while (p != NULL && q != NULL) {
        switch (q->simb->tvar) {
            case INTEGER: case CHAR:
                if (p->tipo != INTEGER && p->tipo != CHAR)
                    Incompatibilidade("Esperava-se inteiro ou caractere");
                break;
            case FLOAT:
                if (p->tipo != INTEGER &&  p->tipo != CHAR && p->tipo != FLOAT)
                    Incompatibilidade("Esperava-se numero real");
                break;
            case LOGICAL:
                if (p->tipo != LOGICAL)
                    Incompatibilidade("Esperava-se booleana");
                break;
            default:
                if (q->simb->tvar != p->tipo)
                    Incompatibilidade("Tipos incompativeis (desconhecido)");
                break;
        }
        p = p->prox; 
        q = q->prox;
    }
}

void MsgErro (char *s) {
    semanticamente_valido = FALSE;
    printf ("\n***** Erro: %s *****\n", s);
}

/* ===== Funções: Codigo Intermediario ===== */
void InicCodIntermed () {
    modcorrente = codintermed = malloc (sizeof (celmodhead));
    modcorrente->listquad = NULL;
    modcorrente->prox = NULL;
}

void InicCodIntermMod (simbolo simb) {
    modcorrente->prox = malloc (sizeof (celmodhead));
    modcorrente = modcorrente->prox;
    modcorrente->prox = NULL;
    modcorrente->modname = simb;
    modcorrente->listquad = malloc (sizeof (celquad));
    quadcorrente = modcorrente->listquad;
    quadcorrente->prox = NULL;
    numquadcorrente = 0;
    quadcorrente->num = numquadcorrente;
}

quadrupla GeraQuadrupla (int oper, operando opnd1, operando opnd2, operando result) {
    quadcorrente->prox = malloc (sizeof (celquad));
    quadcorrente = quadcorrente->prox;
    quadcorrente->oper = oper;
    quadcorrente->opnd1 = opnd1;
    quadcorrente->opnd2 = opnd2;
    quadcorrente->result = result;
    quadcorrente->prox = NULL;
    numquadcorrente ++;
    quadcorrente->num = numquadcorrente;
    return quadcorrente;
}

// **********************************************************************
// By Toso: Aqui eu adicionei um parâmetro para compilar, temos que
//          verificar se ta certo isso
// ********************************************************************** 
simbolo NovaTemp (int tip) {
    simbolo simb; 
    int temp, i, j;
    char nometemp[10] = "##", s[10] = {0};

    numtemp ++; temp = numtemp;
    for (i = 0; temp > 0; temp /= 10, i++)
        s[i] = temp % 10 + '0';
    i --;
    for (j = 0; j <= i; j++)
        nometemp[2+i-j] = s[j];
    // adicionei o "escopo" na linha abaixo
    simb = InsereSimb (nometemp, IDVAR, tip, escopo);
    simb->inic = simb->ref = TRUE;
    simb->array = FALSE;
    return simb;
}

void ImprimeQuadruplas () {
    modhead p;
    quadrupla q;
    for (p = codintermed->prox; p != NULL; p = p->prox) {
        printf ("\n\nQuadruplas do modulo %s:\n", p->modname->cadeia);
        for (q = p->listquad->prox; q != NULL; q = q->prox) {
            printf ("\n\t%4d) %s", q->num, nomeoperquad[q->oper]);
            printf (", (%s", nometipoopndquad[q->opnd1.tipo]);
            switch (q->opnd1.tipo) {
                case IDLEOPND: break;
                case PONTOPND:
                case VAROPND: printf (", %s", q->opnd1.atr.simb->cadeia); break;
                case INTOPND: printf (", %d", q->opnd1.atr.valint); break;
                case REALOPND: printf (", %g", q->opnd1.atr.valfloat); break;
                case CHAROPND: printf (", %c", q->opnd1.atr.valchar); break;
                case LOGICOPND: printf (", %d", q->opnd1.atr.vallogic); break;
                case CADOPND: printf (", %s", q->opnd1.atr.valcad); break;
                case ROTOPND: printf (", %d", q->opnd1.atr.rotulo->num); break;
                case MODOPND: printf(", %s", q->opnd1.atr.modulo->modname->cadeia); break;
            }
            printf (")");
            printf (", (%s", nometipoopndquad[q->opnd2.tipo]);
            switch (q->opnd2.tipo) {
                case IDLEOPND: break;
                case PONTOPND:
                case VAROPND: printf (", %s", q->opnd2.atr.simb->cadeia); break;
                case INTOPND: printf (", %d", q->opnd2.atr.valint); break;
                case REALOPND: printf (", %g", q->opnd2.atr.valfloat); break;
                case CHAROPND: printf (", %c", q->opnd2.atr.valchar); break;
                case LOGICOPND: printf (", %d", q->opnd2.atr.vallogic); break;
                case CADOPND: printf (", %s", q->opnd2.atr.valcad); break;
                case ROTOPND: printf (", %d", q->opnd2.atr.rotulo->num); break;
                case MODOPND: printf(", %s", q->opnd2.atr.modulo->modname->cadeia); break;
            }
            printf (")");
            printf (", (%s", nometipoopndquad[q->result.tipo]);
            switch (q->result.tipo) {
                case IDLEOPND: break;
                case PONTOPND:
                case VAROPND: printf (", %s", q->result.atr.simb->cadeia); break;
                case INTOPND: printf (", %d", q->result.atr.valint); break;
                case REALOPND: printf (", %g", q->result.atr.valfloat); break;
                case CHAROPND: printf (", %c", q->result.atr.valchar); break;
                case LOGICOPND: printf (", %d", q->result.atr.vallogic); break;
                case CADOPND: printf (", %s", q->result.atr.valcad); break;
                case ROTOPND: printf (", %d", q->result.atr.rotulo->num); break;
                case MODOPND: printf(", %s", q->result.atr.modulo->modname->cadeia); break;
            }
            printf (")");
        }
    }
   printf ("\n");
}

void RenumQuadruplas (quadrupla quad1, quadrupla quad2) {
    quadrupla q; int nquad;
    for (q = quad1->prox, nquad = quad1->num; q != quad2; q = q->prox) {
      nquad++;
        q->num = nquad;
    }
}

/* Funcoes para interpretar o codigo intermediario */

void InterpCodIntermed () {
	quadrupla quad, quadprox;  
    char encerra;
    char condicao;
    finput = fopen ("entrada2020", "r");
	printf ("\n\n----- EXECUÇÃO DO INTERPRETADOR -----\n\n");
    InicPilhaOpnd(&pilhaopnd);
    InicPilhaOpnd(&pilhachamadas);
    InicPilhaOpnd(&pilhaindices);
	encerra = FALSE;
	quad = codintermed->prox->listquad->prox;
	while (! encerra) {
		//printf ("\n%4d) %s", quad->num, nomeoperquad[quad->oper]);
		quadprox = quad->prox;
		switch (quad->oper) {
            case OPENMOD: AlocaVariaveis(); break;
			case OPEXIT: encerra = TRUE; break;
            case OPJF:
                if (quad->opnd1.tipo == LOGICOPND)
                    condicao = quad->opnd1.atr.vallogic;
                if (quad->opnd1.tipo == VAROPND)
                    condicao = *(quad->opnd1.atr.simb->vallogic);
                if (!condicao)
                    quadprox = quad->result.atr.rotulo;
                break;
            case OPJT:
                if (quad->opnd1.tipo == LOGICOPND)
                    condicao = quad->opnd1.atr.vallogic;
                if (quad->opnd1.tipo == VAROPND)
                    condicao = *(quad->opnd1.atr.simb->vallogic);
                if (condicao)
                    quadprox = quad->result.atr.rotulo;
                break;
            case OPJUMP:
                quadprox = quad->result.atr.rotulo;
                break;
            case OPLT:      ExecQuadLT (quad); break;
            case OPOR:      ExecQuadOR (quad); break;
            case OPAND:     ExecQuadAND (quad); break;
            case OPLE:      ExecQuadLE (quad); break;
            case OPGT:      ExecQuadGT (quad); break;
            case OPGE:      ExecQuadGE (quad); break;
            case OPEQ:      ExecQuadEQ (quad); break;
            case OPNE:      ExecQuadNE (quad); break;
            case OPREAD:    ExecQuadRead (quad);  break;
            case PARAM:     EmpilharOpnd(quad->opnd1, &pilhaopnd); break;
            case OPWRITE:   ExecQuadWrite(quad); break;
            case OPMAIS:    ExecQuadMais(quad); break;
            case OPMENOS:   ExecQuadMenos(quad); break;
            case OPMULTIP:  ExecQuadMult(quad); break;
            case OPDIV:     ExecQuadDiv(quad); break;
            case OPRESTO:   ExecQuadResto(quad); break;
            case OPMENUN:   ExecQuadMenum(quad); break;
            case OPNOT:     ExecQuadNot(quad); break;
            case OPATRIB:   ExecQuadAtrib(quad); break;
            // -----------------------------------------
            case OPCALL: { 
                int i;  
                operando opndaux;  
                pilhaoperando pilhaopndaux;
                listsimb listparam = quad->opnd1.atr.modulo->modname->listparam;

                InicPilhaOpnd (&pilhaopndaux);
                for (i = 1; i <= quad->opnd2.atr.valint; i++) {
                    EmpilharOpnd (TopoOpnd (pilhaopnd), &pilhaopndaux);
                    DesempilharOpnd (&pilhaopnd);
                }
                for (i = 1; i <= quad->opnd2.atr.valint; i++) {
                    opndaux = TopoOpnd (pilhaopndaux);
                    DesempilharOpnd (&pilhaopndaux);
                    switch (opndaux.tipo) {
                        case INTOPND:
                            *(listparam->prox->simb->valint) = opndaux.atr.valint; break;
                        case REALOPND:
                            *(listparam->prox->simb->valfloat) =  opndaux.atr.valfloat; break;
                        case LOGICOPND:
                            *(listparam->prox->simb->vallogic) = opndaux.atr.vallogic; break;
                        case CHAROPND:
                            *(listparam->prox->simb->valchar) = opndaux.atr.valchar; break;
                        case VAROPND:
                            switch (opndaux.atr.simb->tvar) {
                                case INTEGER:;
                                    listparam->prox->simb->valint = opndaux.atr.simb->valint; break;
                                case FLOAT:;
                                    listparam->prox->simb->valfloat =  opndaux.atr.simb->valfloat; break;
                                case LOGICAL:;
                                    listparam->prox->simb->vallogic = opndaux.atr.simb->vallogic; break;
                                case CHAR:;
                                    listparam->prox->simb->valchar = opndaux.atr.simb->valchar; break;
                            }
                        break;
                    }
                    listparam = listparam->prox;
                }
                opndaux.atr.rotulo = quad;
                EmpilharOpnd(opndaux, &pilhachamadas);
                quadprox = quad->opnd1.atr.modulo->listquad;
            }
            break;
            case OPRETURN: {

                opndaux = TopoOpnd(pilhachamadas);
                DesempilharOpnd(&pilhachamadas);
                if(quad->opnd1.tipo != IDLEOPND) {
                    switch (quad->opnd1.tipo) {
                        case INTOPND:
                            *(opndaux.atr.rotulo->result.atr.simb->valint) = quad->opnd1.atr.valint; break;
                        case REALOPND:
                            *(opndaux.atr.rotulo->result.atr.simb->valfloat) =  quad->opnd1.atr.valfloat; break;
                        case LOGICOPND:
                            *(opndaux.atr.rotulo->result.atr.simb->vallogic) = quad->opnd1.atr.vallogic; break;
                        case CHAROPND:
                            *(opndaux.atr.rotulo->result.atr.simb->valchar) = quad->opnd1.atr.valchar; break;
                        case VAROPND:
                            switch (opndaux.atr.rotulo->result.atr.simb->tvar) {
                                case INTEGER:;
                                    opndaux.atr.rotulo->result.atr.simb->valint = quad->opnd1.atr.simb->valint; break;
                                case FLOAT:;
                                    opndaux.atr.rotulo->result.atr.simb->valfloat =  quad->opnd1.atr.simb->valfloat; break;
                                case LOGICAL:;
                                    opndaux.atr.rotulo->result.atr.simb->vallogic = quad->opnd1.atr.simb->vallogic; break;
                                case CHAR:;
                                    opndaux.atr.rotulo->result.atr.simb->valchar = quad->opnd1.atr.simb->valchar; break;
                            }
                        break;
                    }
                }

                quadprox = opndaux.atr.rotulo->prox;
            }
            break;
            case OPIND: {
                EmpilharOpnd(quad->opnd1, &pilhaindices);
            }
            break;
            case OPINDEX: {
                simb = quad->opnd1.atr.simb;
                int desl = 0;
                int cont = 0;
                for (int i = 1; i <= quad->opnd2.atr.valint; i++) {
                    opndaux = TopoOpnd(pilhaindices);
                    DesempilharOpnd(&pilhaindices);
                    int aux = 1;
                    for (int k = 0; k < cont; k++) {
                        aux = aux * simb->dims[simb->ndims - k];
                    }
                    cont++;
                    switch (opndaux.tipo) {
                        case INTOPND: desl = desl + opndaux.atr.valint * aux; break;
                        case VAROPND: desl = desl + *(opndaux.atr.simb->valint) * aux; break;
                    }
                }
                switch (simb->tvar) {
                    case INTEGER:
                            (quad->result.atr.simb->valint) = &(quad->opnd1.atr.simb->valint) + desl; break;
                    case FLOAT:
                            (quad->result.atr.simb->valfloat) = &(quad->opnd1.atr.simb->valfloat) + desl; break;
                    case CHAR:
                            (quad->result.atr.simb->valchar) = &(quad->opnd1.atr.simb->valchar) + desl; break;
                    case LOGICAL:
                            (quad->result.atr.simb->vallogic) = &(quad->opnd1.atr.simb->vallogic) + desl; break;
                }
            }
            break;
            case OPCONTAPONT: {
                switch (quad->opnd1.atr.simb->tvar) {
                    case INTEGER:
                        *(quad->result.atr.simb->valint) = *(quad->opnd1.atr.simb->valint); break;
                    case FLOAT:
                        *(quad->result.atr.simb->valfloat) = *(quad->opnd1.atr.simb->valfloat); break;
                    case CHAR:
                        *(quad->result.atr.simb->valchar) = *(quad->opnd1.atr.simb->valchar); break;
                    case LOGICAL:
                        *(quad->result.atr.simb->vallogic) = *(quad->opnd1.atr.simb->vallogic); break;
                }
            }
            break;
            case OPATRIBPONT: {
                switch (quad->opnd1.tipo) {
                    case INTOPND:
                        *(quad->result.atr.simb->valint) = quad->opnd1.atr.valint; break;
                    case REALOPND:
                        *(quad->result.atr.simb->valfloat) = quad->opnd1.atr.valfloat; break;
                    case CHAROPND:
                        *(quad->result.atr.simb->valchar) = quad->opnd1.atr.valchar; break;
                    case LOGICOPND:
                        *(quad->result.atr.simb->vallogic) = quad->opnd1.atr.vallogic; break;
                    case VAROPND:
                        switch (quad->result.atr.simb->tvar) {
                            case INTEGER:
                                    *(quad->result.atr.simb->valint) = *(quad->opnd1.atr.simb->valint); break;
                            case FLOAT:
                                    *(quad->result.atr.simb->valfloat) = *(quad->opnd1.atr.simb->valfloat); break;
                            case CHAR:
                                    *(quad->result.atr.simb->valchar) = *(quad->opnd1.atr.simb->valchar); break;
                            case LOGICAL:
                                    *(quad->result.atr.simb->vallogic) = *(quad->opnd1.atr.simb->vallogic); break;
                        }
                    break;
                }
            }
            break;
		}
		if (!encerra) quad = quadprox;
	}
	printf ("\n");
}

void AlocaVariaveis () {
    simbolo s; int nelemaloc, i, j;
    printf ("\n\t\tAlocando as variaveis:");
    for (i = 0; i < NCLASSHASH; i++)
        if (tabsimb[i]) {
            for (s = tabsimb[i]; s != NULL; s = s->prox){
                if (s->tid == IDVAR) {
                    nelemaloc = 1;
                    if (s->array)
                        for (j = 1; j <= s->ndims; j++)  nelemaloc *= s->dims[j];
                    switch (s->tvar) {
                        case INTEGER:
                                s->valint = malloc (nelemaloc * sizeof (int)); break;
                        case FLOAT:
                                s->valfloat = malloc (nelemaloc * sizeof (float)); break;
                        case CHAR:
                                s->valchar = malloc (nelemaloc * sizeof (char)); break;
                        case LOGICAL:
                                s->vallogic = malloc (nelemaloc * sizeof (char)); break;
                    }
                    printf ("\n\t\t\t%s: %d elemento(s) alocado(s) ", s->cadeia, nelemaloc);
                }
            }
        }
    printf ("\n-------------------------------------\n");
}

void DesalocaVariaveis () {
    simbolo s; int i, j;
    printf ("\n\t\tDesalocando as variaveis:");
    for (i = 0; i < NCLASSHASH; i++)
        if (tabsimb[i]) {
            for (s = tabsimb[i]; s != NULL; s = s->prox){
                if (s->tid == IDVAR) {
    
                    switch (s->tvar) {
                        case INTEGER:
                            free (s->valint);
                        case FLOAT:
                            free (s->valfloat);
                        case CHAR:
                            free (s->valchar);
                        case LOGICAL:
                            free (s->vallogic); 
                    }
                    printf ("\n\t\t\t%s:  elemento dalocado ", s->cadeia);
                }
            }
        }
}

void EmpilharOpnd (operando x, pilhaoperando *P) {
    nohopnd *temp;
    temp = *P;   
    *P = (nohopnd *) malloc (sizeof (nohopnd));
    (*P)->opnd = x; (*P)->prox = temp;
}

char VaziaOpnd (pilhaoperando P) {
    if  (P == NULL)  
        return 1;  
    else 
        return 0; 
}

void DesempilharOpnd (pilhaoperando *P) {
    nohopnd *temp;
    if (! VaziaOpnd (*P)) {
        temp = *P;  *P = (*P)->prox; free (temp);
    }
    else  
        printf ("\n\tDelecao em pilha vazia\n");
}

operando TopoOpnd (pilhaoperando P) {
    if (! VaziaOpnd (P))  
        return P->opnd;
    else  
        printf ("\n\tTopo de pilha vazia\n");
}

void InicPilhaOpnd (pilhaoperando *P) { 
    *P = NULL;
}

void ExecQuadWrite (quadrupla quad) {
    int i;  
    operando opndaux;  
    pilhaoperando pilhaopndaux;
    InicPilhaOpnd (&pilhaopndaux);

    for (i = 1; i <= quad->opnd1.atr.valint; i++) {
        EmpilharOpnd (TopoOpnd (pilhaopnd), &pilhaopndaux);
        DesempilharOpnd (&pilhaopnd);
    }

    for (i = 1; i <= quad->opnd1.atr.valint; i++) {
        opndaux = TopoOpnd (pilhaopndaux);
        DesempilharOpnd (&pilhaopndaux);
        switch (opndaux.tipo) {
            case INTOPND:
                printf ("%d", opndaux.atr.valint); break;
            case REALOPND:
                printf ("%g", opndaux.atr.valfloat); break;
            case CHAROPND:
                printf ("%c", opndaux.atr.valchar); break;
            case LOGICOPND:
                if (opndaux.atr.vallogic == 1) printf ("VERDADE");
                else printf ("FALSO");
                break;
            case CADOPND:
                printf ("%s", opndaux.atr.valcad); 
                break ;
            case VAROPND:

            switch (opndaux.atr.simb->tvar) {
                case INTEGER:
                    printf ("%d", *(opndaux.atr.simb->valint)); break;
                case FLOAT:
                    printf ("%g", 
                        *(opndaux.atr.simb->valfloat));break;
                case LOGICAL:
                    if (*(opndaux.atr.simb->vallogic) == 1)
                    printf ("VERDADE"); 
                    else printf ("FALSO"); break;
                case CHAR:
                    printf ("%c", 
                        *(opndaux.atr.simb->valchar)); break;
            }
            break;
        }
    }
    printf ("\n");
}

void ExecQuadMais (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND;  valfloat1 = quad->opnd1.atr.valfloat; break;
        case CHAROPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valchar;  break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
                case FLOAT:
                    tipo1 = REALOPND;
                    valfloat1=*(quad->opnd1.atr.simb->valfloat);break;
                case CHAR:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar); break;
            }
            break;
    }

    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2 = REALOPND;  valfloat2 = quad->opnd2.atr.valfloat;  break;
        case CHAROPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valchar;  break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:
                    tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);  break;
                case FLOAT:
                    tipo2 = REALOPND;
                    valfloat2=*(quad->opnd2.atr.simb->valfloat);break;
                case CHAR:
                    tipo2 = INTOPND;
                    valint2=*(quad->opnd2.atr.simb->valchar);break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = valint1 + valint2;
            break;
        case FLOAT:
            if (tipo1 == INTOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valint1 + valint2;
            if (tipo1 == INTOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valint1 + valfloat2;
            if (tipo1 == REALOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 + valint2;
            if (tipo1 == REALOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 + valfloat2;
            break;
    }
}

void ExecQuadMenos (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND;  valfloat1 = quad->opnd1.atr.valfloat; break;
        case CHAROPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valchar;  break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
                case FLOAT:
                    tipo1 = REALOPND;
                    valfloat1=*(quad->opnd1.atr.simb->valfloat);break;
                case CHAR:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar); break;
            }
            break;
    }

    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2 = REALOPND;  valfloat2 = quad->opnd2.atr.valfloat;  break;
        case CHAROPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valchar;  break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:
                    tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);  break;
                case FLOAT:
                    tipo2 = REALOPND;
                    valfloat2=*(quad->opnd2.atr.simb->valfloat);break;
                case CHAR:
                    tipo2 = INTOPND;
                    valint2=*(quad->opnd2.atr.simb->valchar);break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = valint1 - valint2;
            break;
        case FLOAT:
            if (tipo1 == INTOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valint1 - valint2;
            if (tipo1 == INTOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valint1 - valfloat2;
            if (tipo1 == REALOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 - valint2;
            if (tipo1 == REALOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 - valfloat2;
            break;
    }
}

void ExecQuadMult (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND;  valfloat1 = quad->opnd1.atr.valfloat; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
                case FLOAT:
                    tipo1 = REALOPND;
                    valfloat1=*(quad->opnd1.atr.simb->valfloat);break;
            }
            break;
    }

    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2 = REALOPND;  valfloat2 = quad->opnd2.atr.valfloat;  break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:
                    tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);  break;
                case FLOAT:
                    tipo2 = REALOPND;
                    valfloat2=*(quad->opnd2.atr.simb->valfloat);break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = valint1 * valint2;
            break;
        case FLOAT:
            if (tipo1 == INTOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valint1 * valint2;
            if (tipo1 == INTOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valint1 * valfloat2;
            if (tipo1 == REALOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 * valint2;
            if (tipo1 == REALOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 * valfloat2;
            break;
    }
}

void ExecQuadDiv (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND;  valfloat1 = quad->opnd1.atr.valfloat; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
                case FLOAT:
                    tipo1 = REALOPND;
                    valfloat1=*(quad->opnd1.atr.simb->valfloat);break;
            }
            break;
    }

    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2 = REALOPND;  valfloat2 = quad->opnd2.atr.valfloat;  break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:
                    tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);  break;
                case FLOAT:
                    tipo2 = REALOPND;
                    valfloat2=*(quad->opnd2.atr.simb->valfloat);break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = valint1 / valint2;
            break;
        case FLOAT:
            if (tipo1 == INTOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valint1 / valint2;
            if (tipo1 == INTOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valint1 / valfloat2;
            if (tipo1 == REALOPND && tipo2 == INTOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 / valint2;
            if (tipo1 == REALOPND && tipo2 == REALOPND)
                *(quad->result.atr.simb->valfloat) = valfloat1 / valfloat2;
            break;
    }
}

void ExecQuadResto (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
            }
            break;
    }

    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:
                    tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);  break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = valint1 % valint2;
            break;
    }
}

void ExecQuadNot (quadrupla quad) {
	int tipo1, valint1;
    switch (quad->opnd1.tipo) {
        case LOGICOPND:
            tipo1 = LOGICOPND;  valint1 = quad->opnd1.atr.vallogic;  break;

        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case LOGICOPND:
                    tipo1 = LOGICOPND;
                    valint1 = *(quad->opnd1.atr.simb->vallogic);  break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case VAROPND:
            *(quad->result.atr.simb->vallogic) = !valint1;
            break;
    }
}

void ExecQuadMenum (quadrupla quad) {
	int tipo1, valint1;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);  break;
            }
            break;
    }
        
    switch (quad->result.atr.simb->tvar) {
        case INTEGER:
            *(quad->result.atr.simb->valint) = ~valint1;
            break;
    }
}

void ExecQuadAtrib (quadrupla quad) {
	int tipo1, valint1;
	float valfloat1;
	char valchar1, vallogic1;

    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;
            valint1 = quad->opnd1.atr.valint; break;
        case REALOPND:
            tipo1 = REALOPND;
            valfloat1 = quad->opnd1.atr.valfloat; break;
        case CHAROPND:
            tipo1 = CHAROPND;
            valchar1 = quad->opnd1.atr.valchar; break;
        case LOGICOPND:
            tipo1 = LOGICOPND;
            vallogic1 = quad->opnd1.atr.vallogic; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:
                    tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint); break;
                case FLOAT:
                    tipo1 = REALOPND;
                    valfloat1=*(quad->opnd1.atr.simb->valfloat);break;
                case CHAR:
                    tipo1 = CHAROPND;
                    valchar1=*(quad->opnd1.atr.simb->valchar);break;
                case LOGICAL:
                    tipo1 = LOGICOPND;
                    vallogic1 = *(quad->opnd1.atr.simb->vallogic);
                    break;
            }
            break;
    }
    switch (quad->result.atr.simb->tvar) {
		case INTEGER:
			if (tipo1 == INTOPND)  *(quad->result.atr.simb->valint) = valint1;
			if (tipo1 == CHAROPND)*(quad->result.atr.simb->valint)=valchar1;
			break;
		case CHAR:
			if (tipo1 == INTOPND) *(quad->result.atr.simb->valchar) = valint1;
			if (tipo1==CHAROPND)*(quad->result.atr.simb->valchar)=valchar1;
			break;
		case LOGICAL:  *(quad->result.atr.simb->vallogic) = vallogic1; break;
		case FLOAT:
			if (tipo1 == INTOPND)
				*(quad->result.atr.simb->valfloat) = valint1;
			if (tipo1 == REALOPND)
				*(quad->result.atr.simb->valfloat) = valfloat1;
			if (tipo1 == CHAROPND)
				*(quad->result.atr.simb->valfloat) = valchar1;
			break;
	}
}

void ExecQuadLT (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND; valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND; valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 < valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 < valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 < valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 < valfloat2;
}

void ExecQuadRead (quadrupla quad) {
	int i;  
    operando opndaux;  
    pilhaoperando pilhaopndaux;
	InicPilhaOpnd (&pilhaopndaux);
	for (i = 1; i <= quad->opnd1.atr.valint; i++) {
		EmpilharOpnd (TopoOpnd (pilhaopnd), &pilhaopndaux);
		DesempilharOpnd (&pilhaopnd);
	}
    for (i = 1; i <= quad->opnd1.atr.valint; i++) {
        opndaux = TopoOpnd (pilhaopndaux);
        DesempilharOpnd (&pilhaopndaux);
        switch (opndaux.atr.simb->tvar) {
            case INTEGER:
                fscanf (finput, "%d", opndaux.atr.simb->valint); break;
            case FLOAT:
                fscanf (finput, "%g", opndaux.atr.simb->valfloat);break;
            case LOGICAL:
                fscanf (finput, "%d", opndaux.atr.simb->vallogic); break;
            case CHAR:
                fscanf (finput, "%c", opndaux.atr.simb->valchar); break;
        }
    }
}

void ExecQuadLE (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 <= valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 <= valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 <= valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 <= valfloat2;
}

void ExecQuadGT (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 > valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 > valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 > valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 > valfloat2;
}

void ExecQuadGE (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 >= valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 >= valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 >= valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 >= valfloat2;
}

void ExecQuadEQ (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 == valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 == valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 == valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 == valfloat2;
}

void ExecQuadNE (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 != valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 != valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 != valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 != valfloat2;
}

void ExecQuadAND (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case LOGICOPND:
            tipo1 = LOGICOPND; valint1 = quad->opnd1.atr.vallogic; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
                case LOGICAL: tipo1 = LOGICOPND;
                    valint1 = *(quad->opnd1.atr.simb->vallogic);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case LOGICOPND:
            tipo2 = LOGICOPND; valint2 = quad->opnd1.atr.vallogic; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                case LOGICAL: tipo2 = LOGICOPND;
                    valint2 = *(quad->opnd2.atr.simb->vallogic);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 && valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 && valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 && valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 && valfloat2;
    if (tipo1 == LOGICOPND && tipo2 == LOGICOPND)
		*(quad->result.atr.simb->vallogic) = valint1 && valint2;
}

void ExecQuadOR (quadrupla quad) {
	int tipo1, tipo2, valint1, valint2;
	float valfloat1, valfloat2;
    switch (quad->opnd1.tipo) {
        case INTOPND:
            tipo1 = INTOPND;  valint1 = quad->opnd1.atr.valint;  break;
        case REALOPND:
            tipo1 = REALOPND; valfloat1=quad->opnd1.atr.valfloat;break;
        case CHAROPND:
            tipo1 = INTOPND; valint1 = quad->opnd1.atr.valchar; break;
        case LOGICOPND:
            tipo1 = LOGICOPND; valint1 = quad->opnd1.atr.vallogic; break;
        case VAROPND:
            switch (quad->opnd1.atr.simb->tvar) {
                case INTEGER:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valint);
                    break;
                case FLOAT:  tipo1 = REALOPND;
                    valfloat1 = *(quad->opnd1.atr.simb->valfloat);
                    break;
                case CHAR:  tipo1 = INTOPND;
                    valint1 = *(quad->opnd1.atr.simb->valchar);
                    break;
                case LOGICAL: tipo1 = LOGICOPND;
                    valint1 = *(quad->opnd1.atr.simb->vallogic);
                    break;
            }
            break;
        }
    switch (quad->opnd2.tipo) {
        case INTOPND:
            tipo2 = INTOPND;  valint2 = quad->opnd2.atr.valint;  break;
        case REALOPND:
            tipo2=REALOPND;valfloat2 = quad->opnd2.atr.valfloat;break;
        case CHAROPND:
            tipo2 = INTOPND;valint2 = quad->opnd2.atr.valchar; break;
        case LOGICOPND:
            tipo2 = LOGICOPND; valint2 = quad->opnd1.atr.vallogic; break;
        case VAROPND:
            switch (quad->opnd2.atr.simb->tvar) {
                case INTEGER:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valint);
                    break;
                case FLOAT:  tipo2 = REALOPND;
                    valfloat2 = *(quad->opnd2.atr.simb->valfloat);
                    break;
                case CHAR:  tipo2 = INTOPND;
                    valint2 = *(quad->opnd2.atr.simb->valchar);
                    break;
                case LOGICAL: tipo2 = LOGICOPND;
                    valint2 = *(quad->opnd2.atr.simb->vallogic);
                    break;
                }
            break;
    }
    if (tipo1 == INTOPND && tipo2 == INTOPND)
        *(quad->result.atr.simb->vallogic) = valint1 || valint2;
	if (tipo1 == INTOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valint1 || valfloat2;
	if (tipo1 == REALOPND && tipo2 == INTOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 || valint2;
	if (tipo1 == REALOPND && tipo2 == REALOPND)
		*(quad->result.atr.simb->vallogic) = valfloat1 || valfloat2;
    if (tipo1 == LOGICOPND && tipo2 == LOGICOPND)
		*(quad->result.atr.simb->vallogic) = valint1 || valint2;
}

