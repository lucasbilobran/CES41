#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico-semantico.y
gcc y.tab.c main.c yyerror.c -o sintatico-semantico -lfl
./sintatico-semantico < exemplos/testeCondicional.comp > resultados/testeCondicional.comp
./sintatico-semantico < exemplos/testeSubscrito.comp > resultados/testeSubscrito.comp
./sintatico-semantico < exemplos/testeExpressoes.comp > resultados/testeExpressoes.comp
./sintatico-semantico < exemplos/testePara.comp > resultados/testePara.comp
./sintatico-semantico < exemplos/testeLerEscrever.comp > resultados/testeLerEscrever.comp
