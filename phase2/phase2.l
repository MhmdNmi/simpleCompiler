%option noyywrap yylineno
 
/* Definition */
%{
    #include "phase2.tab.h"
    #include <stdio.h>
    #include <string.h>
%}

/* Rlue */

%%
"$$"(.)*                    {;}
"$*"(.|\n)*"*$"             {;}

"main"                      {return (MAIN);}
"int"                       {return (INT);}
"char"                      {return (CHAR);}
"if"                        {return (IF);}
"elseif"                    {return (ELSEIF);}
"else"                      {return (ELSE);}
"while"                     {return (WHILE);}
"continue"                  {return (CONTINUE);}
"break"                     {return (BREAK);}
"for"                       {return (FOR);}
"return"                    {return (RETURN);}
"void"                      {return (VOID);}

[a-zA-Z\_][a-zA-Z0-9\_]*    {return (IDENTIFIER);}

[0-9]+                      {return (INT_CONST);}
\'[a-zA-Z]\'                {return (CHAR_CONST);}

"<="                        {return (ISLESSEQ);}
">="                        {return (ISMOREQ);}
"=="                        {return (ISEQL);}
"!="                        {return (ISNEQL);}
"="                         {return (ASSIGN);}
"<"                         {return (LEFTB);}
">"                         {return (RIGHTB);}
"||"                        {return (OR);}
"|"                         {return (ORBIT);}
"&&"                        {return (AND);}
"&"                         {return (ANDBIT);}
"^"                         {return (XORBIT);}
"!"                         {return (NOT);}
"+"                         {return (PLUS);}
"-"                         {return (MINUS);}
"*"                         {return (MULTIPLY);}
"/"                         {return (DIVIDE);}
"("                         {return (LEFTPAREN);}
")"                         {return (RIGHTPAREN);}
"."                         {return (DOT);}
","                         {return (COMMA);}
"["                         {return (LEFTBRACE);}
"]"                         {return (RIGHTBRACE);}

\n                          {;}
.                           {;}
%%

/* Code 

int main(int argc, char *argv[]) {
    FILE * fin = fopen(argv[1], "r");
    yyin = fin;
    fout = fopen("tokens.txt", "w");
    yylex();

    printf("\n\tJob is Done!\n");
    return 0;
}
*/