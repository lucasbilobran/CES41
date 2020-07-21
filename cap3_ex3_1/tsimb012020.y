%{
/* Inclusao de arquivos da biblioteca de C */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Definicao dos atributos dos atomos operadores */

#define 	LT 		    1
#define 	LE 	    	2
#define		GT			3
#define		GE			4
#define		EQ			5
#define		NE			6
#define		MAIS        7
#define		MENOS       8
#define		MULT    	9
#define		DIV   	    10
#define		RESTO   	11

/*   Definicao dos tipos de identificadores   */

#define 	IDPROG		1
#define 	IDVAR		2

/*  Definicao dos tipos de variaveis   */

#define 	NOTVAR		0
#define 	INTEGER		1
#define 	LOGICAL		2
#define 	FLOAT		3
#define 	CHAR		4

/*   Definicao de outras constantes   */

#define	NCLASSHASH	23
#define	TRUE		1
#define	FALSE		0

/*  Strings para nomes dos tipos de identificadores  */

char *nometipid[3] = {" ", "IDPROG", "IDVAR"};

/*  Strings para nomes dos tipos de variaveis  */

char *nometipvar[5] = {"NOTVAR",
	"INTEGER", "LOGICAL", "FLOAT", "CHAR"
};

/*    Declaracoes para a tabela de simbolos     */

typedef struct celsimb celsimb;
typedef celsimb *simbolo;
struct celsimb {
	char *cadeia;
	int tid, tvar;
	char inic, ref;
	simbolo prox;
};

/*  Variaveis globais para a tabela de simbolos e analise semantica */

simbolo tabsimb[NCLASSHASH];
simbolo simb;
int tipocorrente;

/*
	Prototipos das funcoes para a tabela de simbolos
    	e analise semantica
 */

void InicTabSimb (void);
void ImprimeTabSimb (void);
simbolo InsereSimb (char *, int, int);
int hash (char *);
simbolo ProcuraSimb (char *);
void DeclaracaoRepetida (char *);
void TipoInadequado (char *);
void NaoDeclarado (char *);

void VerificaInicRef(void);
void Incompatibilidade(char *s);

%}

/* Definicao do tipo de yylval e dos atributos dos nao terminais */

%union {
	char cadeia[50];
	int atr, valint;
	float valreal;
	char carac;
    simbolo simb; // Possibilita que terminais e /ou n-terminais tenham como atributo um ponteiro para uma celula tabsimb
    int tipoexpr; 
}

/* Declaracao dos atributos dos tokens e dos nao-terminais */

%type       <simb>          Variavel
%type       <tipoexpr>      Expressao ExprAux1 ExprAux2 ExprAux3 ExprAux4 Termo Fator

%token		<cadeia>		ID
%token		<carac>		    CTCARAC
%token		<valint>		CTINT
%token		<valreal>	    CTREAL
%token		OR
%token		AND
%token		NOT
%token		<atr>			OPREL
%token		<atr>			OPAD
%token		<atr>			OPMULT
%token		NEG
%token		ABPAR
%token		FPAR
%token		ABCHAV
%token		FCHAV
%token		ABTRIP
%token		FTRIP
%token		VIRG
%token		PVIRG
%token		ATRIB
%token		CARAC
%token		COMANDOS
%token		FALSO
%token		INT
%token		LOGIC
%token		PROGRAMA
%token		REAL
%token      VAR
%token      VERDADE
%token		<carac>         INVAL
%%
/* Producoes da gramatica:

	Os terminais sao escritos e, depois de alguns,
	para alguma estetica, ha mudanca de linha       */

Prog			:	{InicTabSimb();} PROGRAMA  ID  ABTRIP  {printf ("programa %s {{{\n", $3); InsereSimb($3, IDPROG, NOTVAR);}
                    Decls  Comandos  FTRIP  {printf ("}}}\n"); ImprimeTabSimb();}
                ;
Decls 		    :
                |   VAR  ABCHAV  {printf ("var {\n");}  ListDecl
                    FCHAV  {printf ("}\n");}
                ;
ListDecl		:	Declaracao  |  ListDecl  Declaracao
                ;
Declaracao 	    :	Tipo  ABPAR  {printf ("( ");}  ListElem
                    FPAR  {printf (")\n");}
                ;
Tipo			: 	INT  {printf ("int ");      tipocorrente = INTEGER;}
                |   REAL  {printf ("real ");    tipocorrente = FLOAT;  }
                |   CARAC  {printf ("carac ");  tipocorrente = CHAR;   }
                |   LOGIC  {printf ("logic ");  tipocorrente = LOGICAL;}
                ;
ListElem    	:	Elem  |  ListElem  VIRG  {printf (", ");}  Elem
                ;
Elem        	:	ID  {printf ("%s ", $1);
                            if(ProcuraSimb($1) != NULL)
                                DeclaracaoRepetida($1);
                            else
                                InsereSimb($1, IDVAR, tipocorrente);
                        }
                ;
Comandos       	:   COMANDOS  {printf ("comandos ");}  CmdComp
                ;
CmdComp 		:   ABCHAV  {printf ("{\n");}  ListCmd  FCHAV
                    {printf ("}\n");}
                ;
ListCmd 		:
                |   ListCmd  Comando
                ;
Comando        	:   CmdComp  |  CmdAtrib
                ;
CmdAtrib      	:   Variavel {if ($1!=NULL) $1->inic = $1->ref = TRUE;} ATRIB  {printf ("= ");}  Expressao  PVIRG
                    {   printf (";\n");
                        if ($1 != NULL)
                            if ((($1->tvar == INTEGER || $1->tvar == CHAR) && 
                                 ($5 == FLOAT || $5 == LOGICAL)) || ($1->tvar == FLOAT && $5 == LOGICAL) || 
                                 ($1->tvar == LOGICAL && $5 != LOGICAL)
                               )
                            Incompatibilidade ("Lado direito de comando de atribuicao improprio");
                    }
                ;
Expressao     	:   ExprAux1  |  Expressao  OR  {printf ("|| ");}  ExprAux1
                ;
ExprAux1    	:   ExprAux2  |  ExprAux1  AND  {printf ("&& ");}  ExprAux2
                ;
ExprAux2    	:   ExprAux3  |  NOT  {printf ("! ");}  ExprAux3
                ;
ExprAux3    	:   ExprAux4
                |   ExprAux4  OPREL  {
                        switch ($2) {
                            case LT: printf ("< "); break;
                            case LE: printf ("<= "); break;
                            case EQ: printf ("== "); break;
                            case NE: printf ("!= "); break;
                            case GT: printf ("> "); break;
                            case GE: printf (">= "); break;
                        }
                    }  ExprAux4
                ;
ExprAux4    	:   Termo
                |   ExprAux4  OPAD  {
                        switch ($2) {
                            case MAIS: printf ("+ "); break;
                            case MENOS: printf ("- "); break;
                        }
                    }  Termo
                ;
Termo  	    	:   Fator
                |   Termo  OPMULT  {
                        switch ($2) {
                            case MULT: printf ("* "); break;
                            case DIV: printf ("/ "); break;
                            case RESTO: printf ("%% "); break;
                        }
                    }  Fator
                    {
                        switch ($2) {
                            case MULT:
                            case DIV:
                                if ($1 != INTEGER && $1 != FLOAT && $1 != CHAR || $4 != INTEGER && $4 != FLOAT && $4 != CHAR)
                                    Incompatibilidade("Operando improprio para operador aritmetico");
                                
                                if ($1 == FLOAT || $4 == FLOAT)
                                    $$  = FLOAT;
                                else
                                    $$ = INTEGER;
                                break;

                            case RESTO: 
                                if ($1 != INTEGER && $1 != CHAR || $4 != INTEGER && $4 != CHAR) 
                                    Incompatibilidade("Operando improprio para operador resto");
                                $$ = INTEGER;
                                break;
                        }
                    }
                ;
Fator		    :   Variavel {
                                if ($1 != NULL) {
                                    $1->ref = TRUE;
                                    $$ = $1->tvar;
                                }
                            }
                |   CTINT  {printf ("%d ", $1); $$ = INTEGER;}
                |   CTREAL  {printf ("%g ", $1); $$ = FLOAT;}
                |   CTCARAC  {printf ("\'%c\' ", $1); $$ = CHAR;}
            	|   VERDADE  {printf ("verdade "); $$ = LOGICAL;}
            	|   FALSO  {printf ("falso "); $$ = LOGICAL;}
            	|   NEG  {printf ("~ ");}  Fator
                    {
                        if ($3 != INTEGER && $3 != FLOAT && $3 != CHAR)
                            Incompatibilidade("Operando improprio para menos unario");
                        if ($3 == FLOAT)
                            $$ = FLOAT;
                        else
                            $$ = INTEGER;
                    }
            	|   ABPAR  {printf ("( ");}  Expressao  FPAR  {printf (") "); $$ = $3;}
                ;
Variavel		:   ID  {printf ("%s ", $1);
                            simb = ProcuraSimb($1);
                            if(simb == NULL) 
                                NaoDeclarado($1);
                            else if (simb->tid != IDVAR) 
                                TipoInadequado($1);
                            $$ = simb; // O atributo do n-terminal Variavel eh um ponteiro para a celula corrsp ao atrb de ID na tabsimb
                        }
                ;
%%

/* Inclusao do analisador lexico  */

#include "lex.yy.c"

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

simbolo ProcuraSimb (char *cadeia) {
	simbolo s; int i;
	i = hash (cadeia);
	for (s = tabsimb[i]; (s!=NULL) && strcmp(cadeia, s->cadeia);
		s = s->prox);
	return s;
}

/*
	InsereSimb (cadeia, tid, tvar): Insere cadeia na tabela de
	simbolos, com tid como tipo de identificador e com tvar como
	tipo de variavel; Retorna um ponteiro para a celula inserida
 */

simbolo InsereSimb (char *cadeia, int tid, int tvar) {
	int i; simbolo aux, s;
	i = hash (cadeia); aux = tabsimb[i];
	s = tabsimb[i] = (simbolo) malloc (sizeof (celsimb));
	s->cadeia = (char*) malloc ((strlen(cadeia)+1) * sizeof(char));
	strcpy (s->cadeia, cadeia);
	s->tid = tid;		s->tvar = tvar;
	s->inic = FALSE;	s->ref = FALSE;
	s->prox = aux;	return s;
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
				if (s->tid == IDVAR)
					printf (", %s, %d, %d",
						nometipvar[s->tvar], s->inic, s->ref);
				printf(")\n");
			}
		}
}

/*  Mensagens de erros semanticos  */

void DeclaracaoRepetida (char *s) {
	printf ("\n\n***** Declaracao Repetida: %s *****\n\n", s);
}

void NaoDeclarado (char *s) {
    printf ("\n\n***** Identificador Nao Declarado: %s *****\n\n", s);
}

void TipoInadequado (char *s) {
    printf ("\n\n***** Identificador de Tipo Inadequado: %s *****\n\n", s);
}

void Incompatibilidade(char *s) {
    printf ("\n\n***** Incompatibilidade: %s *****\n\n", s);
}



void VerificaInicRef() {
	// Percorre a tabela de símbolos
	for (int i = 0; i < NCLASSHASH; i++) {
		for (simbolo s = tabsimb[i]; (s != NULL); s = s->prox) {
			// Verifica não-inicializados e/ou não-referenciados
			if (!s->ref) {
				printf ("\n\n***** Identificador não-referenciado: %s *****\n\n", s->cadeia);
			}
			if (!s->inic) {
				printf ("\n\n***** Identificador não-inicializado: %s *****\n\n", s->cadeia);
			}
		}
	}
}
