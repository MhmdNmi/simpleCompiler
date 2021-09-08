%option noyywrap

/* Definition */
%{
    #include <stdio.h>
    #include <string.h>
    FILE * fout;

%}

/* Rlue */
%%
"$$"(.)*                    {fprintf(fout, "TOKEN_COMMENT_SL\n");}
"$*"(.|\n)*"*$"             {fprintf(fout, "TOKEN_COMMENT_ML\n");}

"main"                      {fprintf(fout, "TOKEN_MAIN\n");}
"int"                       {fprintf(fout, "TOKEN_INT\n");}
"char"                      {fprintf(fout, "TOKEN_CHAR\n");}
"if"                        {fprintf(fout, "TOKEN_IF\n");}
"elseif"                    {fprintf(fout, "TOKEN_ELSEIF\n");}
"else"                      {fprintf(fout, "TOKEN_ELSE\n");}
"while"                     {fprintf(fout, "TOKEN_WHILE\n");}
"continue"                  {fprintf(fout, "TOKEN_CONTINUE\n");}
"break"                     {fprintf(fout, "TOKEN_BREAK\n");}
"for"                       {fprintf(fout, "TOKEN_FOR\n");}
"return"                    {fprintf(fout, "TOKEN_RETURN\n");}
"void"                      {fprintf(fout, "TOKEN_VOID\n");}

[a-zA-Z\_][a-zA-Z0-9\_]*    {fprintf(fout, "TOKEN_IDENTIFIER\n");}

[0-9]+                      {fprintf(fout, "TOKEN_INT_CONST\n");}
\'[a-zA-Z]\'                {fprintf(fout, "TOKEN_CHAR_CONST\n");}

"<="                        {fprintf(fout, "TOKEN_ISLESSEQ\n");}
">="                        {fprintf(fout, "TOKEN_ISMOREQ\n");}
"=="                        {fprintf(fout, "TOKEN_ISEQL\n");}
"!="                        {fprintf(fout, "TOKEN_ISNEQL\n");}
"="                         {fprintf(fout, "TOKEN_ASSIGN\n");}
"<"                         {fprintf(fout, "TOKEN_LEFTB\n");}
">"                         {fprintf(fout, "TOKEN_RIGHTB\n");}
"||"                        {fprintf(fout, "TOKEN_OR\n");}
"|"                         {fprintf(fout, "TOKEN_ORBIT\n");}
"&&"                        {fprintf(fout, "TOKEN_AND\n");}
"&"                         {fprintf(fout, "TOKEN_ANDBIT\n");}
"^"                         {fprintf(fout, "TOKEN_XORBIT\n");}
"!"                         {fprintf(fout, "TOKEN_NOT\n");}
"+"                         {fprintf(fout, "TOKEN_PLUS\n");}
"-"                         {fprintf(fout, "TOKEN_MINUS\n");}
"*"                         {fprintf(fout, "TOKEN_MULTIPLY\n");}
"/"                         {fprintf(fout, "TOKEN_DIVIDE\n");}
"("                         {fprintf(fout, "TOKEN_LEFTPAREN\n");}
")"                         {fprintf(fout, "TOKEN_RIGHTPAREN\n");}
"."                         {fprintf(fout, "TOKEN_DOT\n");}
","                         {fprintf(fout, "TOKEN_COMMA\n");}
"["                         {fprintf(fout, "TOKEN_LEFTBRACE\n");}
"]"                         {fprintf(fout, "TOKEN_RIGHTBRACE\n");}

\n                          {}
.                           {}
%%

/* Code */

int main(int argc, char *argv[]) {
    FILE * fin = fopen(argv[1], "r");
    yyin = fin;
    fout = fopen("tokens.txt", "w");
    yylex();

    printf("\n\tJob is Done!\n\n");
    return 0;
}