#!/bin/bash
./clean.sh
flex tsimb022020.l
yacc tsimb022020.y
gcc y.tab.c main.c yyerror.c -o tsimb022020 -lfl
./tsimb022020 < tsimb022020.dat > ans