#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico-semantico.y
gcc y.tab.c main.c yyerror.c -o sintatico-semantico -lfl

# # Matriz Transposta
# cp exemplos/matrizTransposta.in entrada2020
# ./sintatico-semantico < exemplos/matrizTransposta.comp > resultados/matrizTransposta.dat

# # Matriz Transposta
 cp exemplos/mergeSort.in entrada2020
 ./sintatico-semantico < exemplos/mergeSort.comp 

# ./sintatico-semantico < exemplos/testeEnquanto.comp 