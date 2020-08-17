%{
#include <string.h>
char tratachar (char *);
void tratacadeia (char *);
%}

delim               [ \t\n\r]
ws                  {delim}+
digito              [0-9]
letra               [A-Za-z]
ctint               {digito}+
carac1              \\.|[^\\'\n]
ctcarac             '{carac1}'
carac2              \\.|[^\\\"\n]
cadeia              \"{carac2}*\"
ctreal              {digito}+\.{digito}*([Ee][+-]?{digito}+)?
caractere           {letra}|{digito}
id                  {letra}{caractere}*
comentario          \/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/

%%
{ws}                {;}
{comentario}        {;}

carac               {return CARAC;}
chamar              {return CHAMAR;}
comandos            {return COMANDOS;}
enquanto            {return ENQUANTO;}
escrever            {return ESCREVER;}
falso               {return FALSO;}
funcao              {return FUNCAO;}
int                 {return INT;}
ler                 {return LER;}
logic               {return LOGIC;}
para                {return PARA;}
principal           {return PRINCIPAL;}
procedimento        {return PROCEDIMENTO;}
programa            {return PROGRAMA;}
real                {return REAL;}
repetir             {return REPETIR;}
retornar            {return RETORNAR;}
se                  {return SE;}
senao               {return SENAO;}
var                 {return VAR;}
verdade             {return VERDADE;}

{id}                {strcpy (yylval.string, yytext); return ID;}
{ctint}             {yylval.valor = atoi(yytext); return CTINT;}
{ctcarac}           {yylval.carac = tratachar (yytext); return CTCARAC;}
{ctreal}            {yylval.valreal = atof(yytext); return CTREAL;}
{cadeia}            {strcpy(yylval.string, yytext); /*tratacadeia (yylval.string);*/ return CADEIA;}

"!="                {yylval.atr = NEQ; return OPREL;}
"<="                {yylval.atr = LEQ; return OPREL;}
"<"                 {yylval.atr = LT; return OPREL;}
">="                {yylval.atr = GEQ; return OPREL;}
">"                 {yylval.atr = GT; return OPREL;}
"=="                {yylval.atr = EQ; return OPREL;}
"+"                 {yylval.atr = SOMA; return OPAD;}
"-"                 {yylval.atr = SUB; return OPAD;}
"*"                 {yylval.atr = MULT; return OPMULT;}
"/"                 {yylval.atr = DIV; return OPMULT;}
"%"                 {yylval.atr = MOD; return OPMULT;}
"||"                {return OR;}
"&&"                {return AND;}
"!"                 {return NOT;}
"~"                 {return NEG;}
"="                 {return ATRIB;}
"("                 {return ABPAR;}
")"                 {return FPAR;}
"["                 {return ABCOL;}
"]"                 {return FCOL;}
"{"                 {return ABCHAV;}
"}"                 {return FCHAV;}
"{{{"               {return ABTRIP;}
"}}}"               {return FTRIP;}
";"                 {return PVIG;}
","                 {return VIRG;}

.                   {yylval.carac = yytext[0]; yylval.atr = INVAL; return INVAL;}
%%

/*
	tratachar: retorna o codigo ASCII de uma constante do tipo char,
   eliminando os apostrofos e as barras invertidas
 */

char tratachar (char *s) {
	if (s[1] != '\\') return s[1];
	else switch (s[2]) {
		case 'a': 	return 7;		case '\\': 	return 92;
		case 'b': 	return 8;		case 'r': 	return 13;
		case '\"': 	return 34;		case 'f': 	return 12;
		case 't': 	return 9;		case 'n': 	return 10;
		case '0': 	return 0;		case '\'': 	return 39;
		case 'v': 	return 11;
		default:	return s[2];
	}
}

/*
	tratacadeia: elimina as aspas e as barras invertidas
	de uma constante do tipo char, substituindo-as pelo respectivo
	codigo ASCII
 */

 void tratacadeia (char *s) {
	int i, n, d;
	n = strlen (s);
	for (i = 0, d = 1; i <= n-2-d; i++)   {
		if (s[i+d] != '\\') s[i] = s[i+d];
		else {
			switch (s[i+d+1]) {
				case 'a': 	s[i] = 7;break;
				case '\\': 	s[i] = 92; break;
				case 'b': 	s[i] = 8; break;
				case 'r': 	s[i] = 13; break;
				case '\"': 	s[i] = 34; break;
				case 'f': 	s[i] = 12; break;
				case 't': 	s[i] = 9;  break;
				case 'n': 	s[i] = 10; break;
				case '\0': 	s[i] = 0;  break;
				case '\'': 	s[i] = 39; break;
				case 'v': 	s[i] = 11; break;
				default:		s[i] = s[i+d+1];
			}
			d++;
		}
	}
	s[i] = s[n];
}