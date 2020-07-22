#!/bin/bash
./clean.sh
flex lexico.l
yacc sintatico.y
gcc y.tab.c main.c yyerror.c -o sintatico -lfl
./sintatico < completo.dat > ans