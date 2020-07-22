#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico.y
gcc y.tab.c main.c yyerror.c -o aaaa -lfl
./aaaa < exemplos/tsimb032020.comp > exemplos/tsimb03202.dat