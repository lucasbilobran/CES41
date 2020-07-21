#!/bin/bash
./clean.sh
flex tsimb012020.l
yacc tsimb012020.y
gcc y.tab.c main.c yyerror.c -o tsimb012020 -lfl
./tsimb012020 < tsimb012020.dat > ans