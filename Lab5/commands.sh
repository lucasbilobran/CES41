#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico-semantico.y
gcc y.tab.c main.c yyerror.c -o sintatico-semantico -lfl
./sintatico-semantico < exemplos/testeCompleto.comp > resultados/testeCompleto.dat
./sintatico-semantico < exemplos/testeCondicional.comp > resultados/testeCondicional.dat
./sintatico-semantico < exemplos/testeEnquantoRepetir.comp > resultados/testeEnquantoRepetir.dat
./sintatico-semantico < exemplos/testeErros.comp > resultados/testeErros.dat
./sintatico-semantico < exemplos/testeExpressoes.comp > resultados/testeExpressoes.dat
./sintatico-semantico < exemplos/testeLerEscrever.comp > resultados/testeLerEscrever.dat
./sintatico-semantico < exemplos/testePara.comp > resultados/testePara.dat
./sintatico-semantico < exemplos/testeSubscrito.comp > resultados/testeSubscrito.dat