%{
    #include "globals.h"
    int yyerrstatus = 0;
    int yylex();
%}

%union{
    int ival;
    char *sval;
    char cval;
    struct _type *dval;
    
}

%token LP RP ADD SUB MUL DIV MOD POW SET
%token <ival> NUM
%token <sval> ID
%start PROGRAM
%type <cval> OP
%type <dval> ARG EXPR

%%
PROGRAM: STMT PROGRAM
        | STMT
        ;

STMT: SETSTMT {freeAllRegisters(); STMT_CNT++;}
    | EXPRSTMT {freeAllRegisters(); STMT_CNT++;}
    ;
    // first lets fill up expected functions and behaviiours in the grammar and then we will implement the functions

SETSTMT: LP SET ID NUM RP{
            emitAssignment($3, $4);
        }
        | LP SET ID ID RP{
            emitCopy($3, $4);
        }
        | LP SET ID EXPR RP{
            emitExpr($3, $4->status, $4->loc, $4->num);
        }
        ;

EXPRSTMT: EXPR{
        printf("\teprn(R, %d);\n", $1->loc);
        }
        ;

EXPR: LP OP ARG ARG RP{

        char* str1 = convertStr($3->status, $3->loc, $3->num);
        char* str2 = convertStr($4->status, $4->loc, $4->num);

        if($3->status == 1){
            regUsage[$3->loc] = 0;
        }
        if($4->status == 1){
            regUsage[$4->loc] = 0;
        }
        regUsage[0] = 0;
        regUsage[1] = 0;
        int availabilty = allocateRegister();

        if(availabilty != -1){
            $$ = (data)malloc(sizeof(data));
            $$->status = 1;
            $$->loc = availabilty;
            regUsage[availabilty] = 1;
            if($2=='^')
                printf("\tR[%d] = pwr(%s, %s);\n", availabilty, str1, str2);
            else
                printf("\tR[%d] = %s %c %s;\n", availabilty, str1, $2, str2);
            
        }
        else{
            $$ = (data)malloc(sizeof(data));
            $$->status = 2;
            $$->loc = allocateMemory();

            if($2=='^')
                printf("\tR[0] = pwr(%s, %s);\n", str1, str2);
            else
                printf("\tR[0] = %s %c %s;\n",  str1, $2, str2);
            printf("\tMEM[%d] = R[0];\n", $$->loc);
        }
    }
    ;

OP: ADD { $$ = '+'; }
    | SUB { $$ = '-'; }
    | MUL { $$ = '*'; }
    | DIV { $$ = '/'; }
    | MOD { $$ = '%'; }
    | POW { $$ = '^'; }
    ;

ARG: ID{
        $$ = (data)malloc(sizeof(data));
        $$->status = 2;
        $$->loc = lookup($1);
    }
    | NUM{
        $$ = (data)malloc(sizeof(data));
        $$->status = 0;
        $$->num = $1;
    }
    | EXPR{
        $$ = (data)malloc(sizeof(data));
        $$->status = $1->status;
        $$->loc = $1->loc;
        $$->num = $1->num;
    }
    ;

%%


int yyerror(const char *s) {

    ERROR_CNT++;

    printf("\tPausing parsing");
    for (int i = 0; i < 3; ++i) {
        printf("\t.");
        fflush(stdout);
        sleep(1);
    }
    printf("\t\n"); 

    printf("\tError in Statement # %d\n", STMT_CNT);
    fprintf(stderr, "%s\n", s);
    sleep(1);
    yyerrstatus = 0;                // doesnt raise a make error as error has been handled

    printf("\tAttempt to resume parsing");
    for (int i = 0; i < 3; ++i) {
        printf("\t.");
        fflush(stdout);
        sleep(1);
    }
    printf("\t\n");
    STMT_CNT--;                    // decrement the statement count as the error statement is not executed

    return 0;
}

