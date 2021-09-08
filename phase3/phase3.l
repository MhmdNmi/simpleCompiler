%option noyywrap yylineno
 
/* Definition */
%{
    #include "phase3.tab.h"
    #include <stdio.h>
    #include <string.h>
%}

/* Rlue */

%%
[ \t]		                {;}
[ \n]                       {yylineno = yylineno + 1;}

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

[a-zA-Z\_][a-zA-Z0-9\_]*    {printf("IDENTIFIER %s\n", yytext); yylval.str = strdup(yytext); return (IDENTIFIER);}

[0-9]+                      {printf("INT_CONST %s\n", yytext); yylval.str = strdup(yytext); return (INT_CONST);}
\'[a-zA-Z]\'                {printf("CHAR_CONST %s\n", yytext); yylval.str = strdup(yytext[1]); return (CHAR_CONST);}

"<="                        {yylval.str = strdup(yytext); return (ISLESSEQ);}
">="                        {yylval.str = strdup(yytext); return (ISMOREQ);}
"=="                        {yylval.str = strdup(yytext); return (ISEQL);}
"!="                        {yylval.str = strdup(yytext); return (ISNEQL);}
"="                         {yylval.str = strdup(yytext); return (ASSIGN);}
"<"                         {yylval.str = strdup(yytext); return (LEFTB);}
">"                         {yylval.str = strdup(yytext); return (RIGHTB);}
"||"                        {yylval.str = strdup(yytext); return (OR);}
"|"                         {yylval.str = strdup(yytext); return (ORBIT);}
"&&"                        {yylval.str = strdup(yytext); return (AND);}
"&"                         {yylval.str = strdup(yytext); return (ANDBIT);}
"^"                         {yylval.str = strdup(yytext); return (XORBIT);}
"!"                         {yylval.str = strdup(yytext); return (NOT);}
"+"                         {yylval.str = strdup(yytext); return (PLUS);}
"-"                         {yylval.str = strdup(yytext); return (MINUS);}
"*"                         {yylval.str = strdup(yytext); return (MULTIPLY);}
"/"                         {yylval.str = strdup(yytext); return (DIVIDE);}
"("                         {yylval.str = strdup(yytext); return (LEFTPAREN);}
")"                         {yylval.str = strdup(yytext); return (RIGHTPAREN);}
"."                         {yylval.str = strdup(yytext); return (DOT);}
","                         {yylval.str = strdup(yytext); return (COMMA);}
"["                         {yylval.str = strdup(yytext); return (LEFTBRACE);}
"]"                         {yylval.str = strdup(yytext); return (RIGHTBRACE);}

\n                          {;}
.                           {;}
%%
