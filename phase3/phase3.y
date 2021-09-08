%{
	#include <stdio.h>
    extern int yylex();
    extern int yyparse();
    extern FILE *yyin;
    FILE * fout;
    void yyerror(const char *s);
    extern int yylineno;
    extern char* yytext;
    #define YYERROR_VERBOSE 1
%}

%token MAIN INT CHAR IF ELSE ELSEIF WHILE CONTINUE BREAK FOR RETURN VOID IDENTIFIER INT_CONST CHAR_CONST DOT COMMA ISLESSEQ ISMOREQ ISEQL ISNEQL
%token ASSIGN LEFTB RIGHTB OR ORBIT AND ANDBIT XORBIT NOT PLUS MINUS MULTIPLY DIVIDE LEFTPAREN RIGHTPAREN LEFTBRACE RIGHTBRACE
%start S
%right ASSIGN
%left PLUS MINUS
%left MULTIPLY DIVIDE
%left AND OR
%left ANDBIT ORBIT XORBIT
%left LEFTB RIGHTB
%left ISLESSEQ ISMOREQ

%union{
    char *str;
}

%%
S       :   {yyerror("EMPTY FILE");}   |
            M {printf("\n\tCode Successfuly Parsed!\n");} ;

M       :   FUNC M | INT MAIN LEFTPAREN RIGHTPAREN {openScope();} BSTMTSB  ;

BSTMTSB :   LEFTB STMTS {closeScope();} RIGHTB  ;

STMTS   :   STMT STMTS  |
            STMT    ;

STMT    :   IFSTMT  |
            FORSTMT |
            WHILESTMT   |
            VARDEF  |
            STEP DOT    |
            RETURN EXPR DOT   |
            BREAK DOT   |
            CONTINUE DOT    ;

FUNC    :   TYPEF {setType();} IDENTIFIER {functionDeclare();} LEFTPAREN {openScope();} RIGHTPAREN BSTMTSB |
            TYPEF {setType();} IDENTIFIER {functionDeclare();} LEFTPAREN {openScope();} TYPEF IDENTIFIER RIGHTPAREN BSTMTSB |
            TYPEF {setType();} IDENTIFIER {functionDeclare();} LEFTPAREN {openScope();} TYPEF IDENTIFIER COMMA TYPEF IDENTIFIER RIGHTPAREN BSTMTSB   |
            TYPEF {setType();} IDENTIFIER {functionDeclare();} LEFTPAREN {openScope();} TYPEF IDENTIFIER COMMA TYPEF IDENTIFIER COMMA TYPEF IDENTIFIER RIGHTPAREN BSTMTSB ;

FUNCCALL    :   IDENTIFIER {checkFunc(); call();} LEFTPAREN EXPR RIGHTPAREN   |
                IDENTIFIER {checkFunc(); call();} LEFTPAREN EXPR COMMA EXPR RIGHTPAREN   |
                IDENTIFIER {checkFunc(); call();} LEFTPAREN EXPR COMMA EXPR COMMA EXPR RIGHTPAREN   ;

TYPEF   :   VOID    |
            TYPED   ;

TYPED   :   CHAR    |
            INT ;

VARDEF   :   TYPED {setType();} IDENTIFIER {symbolDeclare(yytext);} VARDEFFIN ;

VARDEFFIN   :   DOT {pop();}    |
                ASSIGN {push(yytext);} EXPR {assignCG();} DOT   ;

STEP    :   IDENTIFIER {checkPushSymbol(yytext);} ASSIGN {push(yytext);} EXPR {assignCG();}  ;

EXPR    :   EXPR PLUS {push(yytext);} EXPR {operationCG();}    |
            EXPR MINUS {push(yytext);} EXPR {operationCG();}   |
            EXPR MULTIPLY {push(yytext);} EXPR {operationCG();}    |
            EXPR DIVIDE {push(yytext);} EXPR {operationCG();}  |  
            EXPR ANDBIT {push(yytext);} EXPR {operationCG();}  |
            EXPR ORBIT {push(yytext);} EXPR {operationCG();}   |
            EXPR XORBIT {push(yytext);} EXPR {operationCG();}  |
            EXPR AND {push(yytext);} EXPR {operationCG();} |
            EXPR OR {push(yytext);} EXPR {operationCG();}  |
            EXPR COMPOP {push(yytext);} EXPR {operationCG();}  |
            INT_CONST {printf("*\trule INT_CONST %s\n", $1); push(yytext);}   |
            CHAR_CONST {printf("*\trule CHAR_CONST %s\n", $1); push(yytext);}  |
            IDENTIFIER {printf("*\trule IDENTIFIER %s\n", $1); checkPushSymbol($1);}  |
            FUNCCALL    |
            LEFTPAREN EXPR RIGHTPAREN  |
            NOT LEFTPAREN EXPR RIGHTPAREN ;

COMPOP  :   LEFTB   |
            RIGHTB  |
            ISLESSEQ    |
            ISMOREQ |
            ISEQL   |
            ISNEQL  ;

IFSTMT :    IF LEFTPAREN EXPR RIGHTPAREN {labelIfStart(); openScope();} BSTMTSB IFSTMTEND ;

IFSTMTEND   :   {labelIfFinish();} |
                ELSE {labelElse(); openScope();} BSTMTSB {labelIfFinish();} |
                ELIFSTMTS ELSE {labelElse(); openScope();} BSTMTSB {labelIfFinish();} ;   

ELIFSTMTS   :   ELIFSTMT ELIFSTMTS  |
                ELIFSTMT    ;

ELIFSTMT    :   ELSEIF LEFTPAREN EXPR RIGHTPAREN {labelElse(); labelElseIfStart(); openScope();} BSTMTSB ;

WHILESTMT   :   {labelWhileStart();} WHILE LEFTPAREN EXPR RIGHTPAREN {openScope(); labelWhileRepeat();} BSTMTSB {labelWhileFinish();}  ;

FORSTMT :   FOR LEFTPAREN {labelWhileStart(); openScope();} VARDEF EXPR {labelWhileRepeat();} DOT STEP RIGHTPAREN BSTMTSB {labelWhileFinish();}   ;

%%


int count = 0;
char stack[1000][10];
int stackTop = 0;
char tempVar[3] = "t";
int labels[1000];
int labelCount = 0;
int labelTop = 0;
int tempCount = 0;
char tmpType[10];

struct symbolTableEntity {
	char id[20];
	char type[10];
} symbolTable[10000];

int symbolTableCount = 1;

struct functionTableEntity {
	char id[20];
	char type[10];
    char label[5];
} functionTable[100];

int functionTableCount = 0;

void yyerror(const char *s){
    printf("\n\tError %s in line %d\n\n", s, yylineno);
    //printf("\n\tError %s in line %d: %s\n\n", s, yylineno, yytext);
    //fprintf(stderr,"\n\tError: %s in line %d\n", s, yylineno - 1);
	//printf ("\n\tError: %s\n", s);
}

int yywrap() {
	return 1;
}

void push(char * val) {
    char tmp[20];
    strcpy(tmp, val);
    printf("Pushing %s\n", tmp);
    if (tmp[0] == '+') strcpy(stack[++stackTop], "add");
    else if (tmp[0] == '-') strcpy(stack[++stackTop], "sub");
    else if (tmp[0] == '*') strcpy(stack[++stackTop], "mul");
    else if (tmp[0] == '/') strcpy(stack[++stackTop], "div");
    else if (tmp[0] == '&') strcpy(stack[++stackTop], "and");
    else if (tmp[0] == '|') strcpy(stack[++stackTop], "or");
    else if (tmp[0] == '^') strcpy(stack[++stackTop], "xor");
    else if (tmp[0] == '<') {
        if (tmp[1] == '=') strcpy(stack[++stackTop], "sle");
        else strcpy(stack[++stackTop], "slt");
    }
    else if (tmp[0] == '>') {
        if (tmp[1] == '=') strcpy(stack[++stackTop], "sge");
        else strcpy(stack[++stackTop], "sgt");
    }
    else if (tmp[1] == '=') {
        if (tmp[0] == '=') strcpy(stack[++stackTop], "seq");
        else if (tmp[0] == '!') strcpy(stack[++stackTop], "sne");
    }
    else strcpy(stack[++stackTop], val);
    printf("\n\tStack: ");
    for (int i = 1; i <= stackTop; i++) {
        printf(" %s,", stack[i]);
    }
    printf("\n\n");
}

void pop() {
    printf("popping %s\n", stack[stackTop]);
    stackTop--;
    printf("\n\tStack: ");
    for (int i = 1; i <= stackTop; i++) {
        printf(" %s,", stack[i]);
    }
    printf("\n\n");
}

void operationCG() { //codegen_logical //codegen_algebric
    sprintf(tempVar, "$t%d", tempCount);
 	tempCount++;
  	fprintf(fout, "\t%s,\t %s,\t %s,\t %s\n", stack[stackTop-1], tempVar, stack[stackTop-2], stack[stackTop]);
  	printf("\t%s,\t %s,\t %s,\t %s\n", stack[stackTop-1], tempVar, stack[stackTop-2], stack[stackTop]);
    stackTop -= 2;
 	strcpy(stack[stackTop], tempVar);
}

void assignCG() { //codegen_assign
    if (stack[stackTop][0] == '$' || (stack[stackTop][0] >= 'a' && stack[stackTop][0] <= 'z') || (stack[stackTop][0] >= 'A' && stack[stackTop][0] <= 'Z')) {
     	fprintf(fout,"\tmov,\t %s,\t %s\n", stack[stackTop-2], stack[stackTop]);
     	printf("\tmov,\t %s,\t %s\n", stack[stackTop-2], stack[stackTop]);
    }
    else {
        fprintf(fout,"\tli,\t %s,\t %s\n", stack[stackTop-2], stack[stackTop]);
        printf("\tli,\t %s,\t %s\n", stack[stackTop-2], stack[stackTop]);
    }
 	stackTop -= 3;
}

void labelIfStart() { // push label
    printf("labelIfStart()\n");
 	labelCount++;
 	fprintf(fout, "\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labelCount);
 	printf("\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labelCount);
 	labels[++labelTop] = labelCount;
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelElse() { // pop a label, push another label
    printf("labelElse()\n");
	int tmp;
	labelCount++;
	tmp = labels[labelTop--]; 
	fprintf(fout,"\tjmp,\t $L%d\n$L%d:\n", labelCount, tmp);
	printf("\tjmp,\t $L%d\n$L%d:\n", labelCount, tmp);
	labels[++labelTop] = labelCount;
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelElseIfStart() {
    printf("labelElseIfStart()\n");
 	fprintf(fout, "\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labels[labelTop]);
 	printf("\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labels[labelTop]);
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelIfFinish() { // pop label
    printf("labelIfFinish()\n");
	int tmp;
	tmp = labels[labelTop--];
	fprintf(fout,"$L%d:\n", tmp);
	printf("$L%d:\n", tmp);
	stackTop--;
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelWhileStart() {
    printf("labelWhileStart()\n");
	labels[++labelTop] = ++labelCount;
	fprintf(fout, "$L%d:\n", labelCount);
    printf("$L%d:\n", labelCount);
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelWhileRepeat() {
    printf("labelWhileRepeat()\n");
	labelCount++;
 	fprintf(fout, "\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labelCount);
 	printf("\tbeqz,\t %s,\t $L%d\n", stack[stackTop], labelCount);
 	labels[++labelTop] = labelCount;
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

void labelWhileFinish() {
    printf("labelWhileFinish()\n");
	int tmp1, tmp2;
	tmp2 = labels[labelTop--];
	tmp1 = labels[labelTop--];
	fprintf(fout, "\tjmp,\t $L%d\n$L%d:\n", tmp1, tmp2);
	printf("\tjmp,\t $L%d\n$L%d:\n", tmp1, tmp2);
	stackTop--;
    printf("\n\tlabelStack: ");
    for (int i = 0; i <= labelTop; i++) {
        printf(" %d,", labels[i]);
    }
    printf("\n\n");
}

// SymbolTable Functions
void checkPushSymbol(char * val) {
	char tmp[20];
//	strcpy(tmp, yytext);
    strcpy(tmp, val);
    printf("checking %s\n", tmp);
    printf("\n\tsymbolTable: %d\t", symbolTableCount);
    for (int i = 0; i < symbolTableCount; i++) {
        printf(" %s,", symbolTable[i].id);
    }
    printf("\n\n");
	int find = 0;
	for(int i = symbolTableCount - 1; i >= 0; i--) {
		if (!strcmp(symbolTable[i].id, tmp)) {
			find = 1;
			break;
		}
	}
	if (!find) {
        char op[35] = "Undeclared Variable ";
        strcat(op, tmp);
		yyerror(op);
		exit(0);
	}
    else {
        push(val);
    }
}

void setType() {
    printf("setType()\n");
	strcpy(tmpType, yytext);
}

void openScope() {
    printf("openScope()\n");
    //printf("symbolTable[%d].id: %s\n", symbolTableCount, symbolTable[symbolTableCount].id);
    strcpy(symbolTable[symbolTableCount].id, "newScope");
    symbolTableCount++;
}

void closeScope() {
    printf("closeScope()\n");
    for (int i = symbolTableCount; strcmp(symbolTable[i].id, "newScope") && strcmp(symbolTable[i].id, "globScope"); i--) {
        symbolTableCount--;
    }
}

void symbolDeclare(char * val) {
    printf("symbolDeclare() %s\n", val);
	char tmp[20];
	int find = 0;
//	strcpy(tmp, yytext);
	strcpy(tmp, val);
	for(int i = symbolTableCount - 1; i >= 0; i--) {
        if(!strcmp(symbolTable[i].id, "newScope")) break;
		if(!strcmp(symbolTable[i].id, tmp)) {
			find = 1;
			break;
		}
	}
	if(find) {
        char op[35] = "Redeclared Variable ";
        strcat(op, tmp);
		yyerror(op);
		exit(0);
	}
	else {
		strcpy(symbolTable[symbolTableCount].id, tmp);
		strcpy(symbolTable[symbolTableCount].type, tmpType);
		symbolTableCount++;
        printf("\n\tsymbolTable: ");
        for (int i = 0; i < symbolTableCount; i++) {
            printf(" %s,", symbolTable[i].id);
        }
        printf("\n\n");
        push(tmp);
	}
}

// FunctionTable Functions
void functionDeclare() {

}

void checkFunc() {

}

void call(){

}

int main(int argc, char *argv[]){
    yyin = fopen(argv[1], "r");
    fout = fopen("outFile", "w");

    strcpy(symbolTable[0].id, "globScope");
    strcpy(stack[0], "END");

    if(!yyparse()) printf("\n\tSuccessfully Compiled!\n\n");
    else {
		printf("\n\tParsing failed\n\n");
		exit(0);
    }

    fclose(yyin);
    fclose(fout);

    return 0;
}