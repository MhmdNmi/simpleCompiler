bison -d phase3.y
flex phase3.l
gcc phase3.tab.c lex.yy.c
./a.out testFile