%{
	#include <stdio.h>
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    void yyerror(const char *s);
    extern int yylineno;
    #define YYERROR_VERBOSE 1
%}

%token MAIN INT CHAR IF ELSE ELSEIF WHILE CONTINUE BREAK FOR RETURN VOID IDENTIFIER INT_CONST CHAR_CONST DOT COMMA ISLESSEQ ISMOREQ ISEQL ISNEQL
%token ASSIGN LEFTB RIGHTB OR ORBIT AND ANDBIT XORBIT NOT PLUS MINUS MULTIPLY DIVIDE LEFTPAREN RIGHTPAREN LEFTBRACE RIGHTBRACE
%start S
%left PLUS MINUS
%left MULTIPLY DIVIDE
%left AND OR
%left ANDBIT ORBIT XORBIT

%%
S       :   {yyerror("EMPTY FILE");}   |
            M {printf("\n\tCode Successfuly Parsed!\n");} ;

M       :   FUNC M | INT MAIN LEFTPAREN RIGHTPAREN LEFTB STMTS RIGHTB;

FUNC    :   TYPE IDENTIFIER LEFTPAREN RIGHTPAREN LEFTB STMTS RIGHTB |
            TYPE IDENTIFIER LEFTPAREN TYPE IDENTIFIER RIGHTPAREN LEFTB STMTS RIGHTB |
            TYPE IDENTIFIER LEFTPAREN TYPE IDENTIFIER COMMA TYPE IDENTIFIER RIGHTPAREN LEFTB STMTS RIGHTB   |
            TYPE IDENTIFIER LEFTPAREN TYPE IDENTIFIER COMMA TYPE IDENTIFIER COMMA TYPE IDENTIFIER RIGHTPAREN LEFTB STMTS RIGHTB ;

FUNCCALL    :   IDENTIFIER LEFTPAREN EXPR RIGHTPAREN   |
                IDENTIFIER LEFTPAREN EXPR COMMA EXPR RIGHTPAREN   |
                IDENTIFIER LEFTPAREN EXPR COMMA EXPR COMMA EXPR RIGHTPAREN   ;

TYPE    :   VOID    |
            CHAR    |
            INT ;

STMTS   :   STMT STMTS  |
            STMT    ;

VARDEF1 :   INT IDENTIFIER DOT  |
            CHAR IDENTIFIER DOT ;

VARDEF2 :   INT IDENTIFIER ASSIGN INT_CONST DOT |
            CHAR IDENTIFIER ASSIGN CHAR_CONST DOT   ;

STMT    :   IFSTMT |
            WHILESTMT  |
            FORSTMT    |
            VARDEF1 |
            VARDEF2 |
            STEP DOT    |
            RETURN EXPR DOT   |
            BREAK DOT   |
            CONTINUE DOT    ;

STEP    :   IDENTIFIER ASSIGN EXPR  ;

EXPR    :   VALUE PLUS VALUE    |
            VALUE MINUS VALUE   |
            VALUE MULTIPLY VALUE    |
            VALUE DIVIDE VALUE  |  
            VALUE ANDBIT VALUE  |
            VALUE ORBIT VALUE   |
            VALUE XORBIT VALUE  |
            VALUE   ;

COMPOP  :   LEFTB   |
            RIGHTB  |
            ISLESSEQ    |
            ISMOREQ |
            ISEQL   |
            ISNEQL  ;

VALUE   :   INT_CONST   |
            CHAR_CONST  |
            IDENTIFIER  |
            FUNCCALL    |
            LEFTPAREN VALUE RIGHTPAREN  ;

COND    :   EXPR COMPOP EXPR  |
            CONDS   |
            NOT LEFTPAREN COND RIGHTPAREN   |
            EXPR    ;

CONDS   :   COND AND COND   |
            COND OR COND    ;

IFSTMT :    IF LEFTPAREN COND RIGHTPAREN LEFTB STMTS RIGHTB |
            IF LEFTPAREN COND RIGHTPAREN LEFTB STMTS RIGHTB ELSE LEFTB STMTS RIGHTB |
            IF LEFTPAREN COND RIGHTPAREN LEFTB STMTS RIGHTB ELIFSTMTS ELSE LEFTB STMTS RIGHTB ;

ELIFSTMTS   :   ELIFSTMT ELIFSTMTS  |
                ELIFSTMT    ;

ELIFSTMT    :   ELSEIF LEFTPAREN COND RIGHTPAREN LEFTB STMTS RIGHTB ;

WHILESTMT   :   WHILE LEFTPAREN COND RIGHTPAREN LEFTB STMTS RIGHTB  ;

FORSTMT :   FOR LEFTPAREN VARDEF2 COND DOT STEP RIGHTPAREN LEFTB STMTS RIGHTB   ;

%%


void yyerror(const char *s){
    fprintf(stderr,"\n\tError: %s in line %d\n", s, yylineno - 1);
	//printf ("\n\tError: %s\n", s);
}

int yywrap(){
	return 1;
}

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    yyparse();
    fclose(yyin);
    printf("\n\tEnd of Job!\n\n");
    return 0;
}