#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico-semantico.y
gcc y.tab.c main.c yyerror.c -o sintatico-semantico -lfl
./sintatico-semantico < exemplos/testeCondicional.comp > resultados/anstesteCondicional.comp
./sintatico-semantico < exemplos/testeSubscrito.comp > resultados/anstesteSubscrito.comp
./sintatico-semantico < exemplos/testeExpressoes.comp > resultados/anstesteExpressoes.comp
./sintatico-semantico < exemplos/testePara.comp > resultados/anstestePara.comp
./sintatico-semantico < exemplos/testeLerEscrever.comp > resultados/anstesteLerEscrever.comp
./sintatico-semantico < exemplos/testeEnquantoRepetir.comp > resultados/anstesteEnquantoRepetir.comp
./sintatico-semantico < exemplos/testeCompleto.comp > resultados/anstesteCompleto.comp