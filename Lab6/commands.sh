#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico-semantico.y
gcc y.tab.c main.c yyerror.c -o sintatico-semantico -lfl

# Matriz Transposta
cp exemplos/matrizTransposta.in entrada2020
./sintatico-semantico < exemplos/matrizTransposta.comp > resultados/matrizTransposta.dat

# Aproximação de PI
./sintatico-semantico < exemplos/piApprox.comp > resultados/piApprox.dat

# Matriz MergeSort
cp exemplos/mergeSort.in entrada2020
./sintatico-semantico < exemplos/mergeSort.comp > resultados/mergeSort.dat

# Matriz BBSort
cp exemplos/BBsort.in entrada2020
./sintatico-semantico < exemplos/BBsort.comp > resultados/BBsort.dat
