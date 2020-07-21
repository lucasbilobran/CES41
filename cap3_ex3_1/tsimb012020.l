%{
void comentario (void);
char tratachar (char *);
%}
delim			[ \t\n\r]
ws				{delim}+
digito		    [0-9]
letra			[A-Za-z]
ctint			{digito}+
id				{letra}({letra}|{digito})*
ctreal		    {digito}+\.{digito}*([Ee][+-]?{digito}+)?
carac1		    \\.|[^\\']
ctcarac		    '{carac1}'
%%
{ws}			{ ;}
"/*"			{comentario ();}
carac			{return CARAC;}
comandos        {return COMANDOS;}
falso			{return FALSO;}
int			    {return INT;}
logic			{return LOGIC;}
programa		{return PROGRAMA;}
real			{return REAL;}
var			    {return VAR;}
verdade		    {return VERDADE;}
{id}			{strcpy (yylval.cadeia, yytext); return ID;}
{ctcarac}	    {yylval.carac = tratachar (yytext); return CTCARAC;}
{ctint}		    {yylval.valint = atoi(yytext); return CTINT;}
{ctreal}		{yylval.valreal = atof(yytext); return CTREAL;}
"||"			{return OR;}
"&&"			{return AND;}
"!"			    {return NOT;}
"<"		    	{yylval.atr = LT; return OPREL;}
"<="			{yylval.atr = LE; return OPREL;}
">"		    	{yylval.atr = GT; return OPREL;}
">="			{yylval.atr = GE; return OPREL;}
"=="		    {yylval.atr = EQ; return OPREL;}
"!="			{yylval.atr = NE; return OPREL;}
"+"		    	{yylval.atr = MAIS; return OPAD;}
"-"	    		{yylval.atr = MENOS; return OPAD;}
"*"	    		{yylval.atr = MULT; return OPMULT;}
"/"		    	{yylval.atr = DIV; return OPMULT;}
"%"		    	{yylval.atr = RESTO; return OPMULT;}
"~"		    	{return NEG;}
"("		    	{return ABPAR;}
")"		    	{return FPAR;}
"{"		    	{return ABCHAV;}
"}"		    	{return FCHAV;}
"{{{"		    {return ABTRIP;}
"}}}"		    {return FTRIP;}
";"		    	{return PVIRG;}
","		    	{return VIRG;}
"="			    {return ATRIB;}
.				{yylval.carac = yytext[0]; return INVAL;}
%%

/*
	comentario: le e descarta os comentarios do programa
 */

void comentario () {
	char c;  int estado;
	estado = 1;
	while (estado != 3) {
		switch (estado) {
			case 1:
				c = input ();
				if (c == EOF) estado = 3;
				else if (c == '*') estado = 2;
				break;
			case 2:
				c = input ();
				if (c == EOF || c == '/') estado = 3;
				else if (c != '*') estado = 1;
		}
	}
}

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
