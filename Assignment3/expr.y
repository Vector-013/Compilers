%{
    #include "globals.h"
    int yyerrstatus = 0;
    int yylex();
%}

%union{
    int ival;
    char *sval;
    char cval;
    struct _exprNode *expr;
    
}

%token LP RP ADD SUB MUL DIV MOD POW SET
%token <ival> NUM
%token <sval> ID
%start PROGRAM
%type <expr> EXPR
%type <cval> OP
%type <expr> ARG
%type <expr> SETSTMT

%%
PROGRAM: STMT PROGRAM
        | STMT
        ;

STMT: SETSTMT { STMT_CNT++;}
    | EXPRSTMT {STMT_CNT++;}
    ;

SETSTMT: LP SET ID NUM RP { 
            node* cur = lookup($3);
            if(cur == NULL){
                cur = insert($3);
            }
            set(cur, $4);
            printf("Variable %s set to %d\n", $3, $4);
            
            }
        | LP SET ID ID RP { 
            node* n1 = lookup($3);
            node* n2 = lookup($4);
            if(n1 == NULL){
                n1 = insert($3);
            }
            if(n2 != NULL){
                set(n1, n2->value);
                printf("Variable %s set to %s (%d)\n", $3, $4,n2->value);
            }
            else{
                printf("Variable %s not found\n", $4);
                yyerrstatus = 1;
                yyerror("[PARSE ERROR] Variable not found");
            }
        }
        | LP SET ID EXPR RP { 
            node* cur = lookup($3);
            if(cur == NULL){
                cur = insert($3);
            }
            int value = evaluate($4);
            set(cur, value);
            printf("Variable %s set to %d\n", $3, value);
            deleteTree($4);                                     // use the expression tree to evaluate the expression, free the tree for this expression after wards
        } 
        ;

EXPRSTMT: EXPR { 
            int value = evaluate($1);
            printf("Result: %d\n", value);
            deleteTree($1);
        }
        ;

EXPR: LP OP ARG ARG RP {
        exprNode *root = createOpNode($2, $3, $4);
        $$ = root;
        }
    ;

OP: ADD { $$ = '+'; }
    | SUB { $$ = '-'; }
    | MUL { $$ = '*'; }
    | DIV { $$ = '/'; }
    | MOD { $$ = '%'; }
    | POW { $$ = '^'; }
    ;

ARG: ID { exprNode *root = createLeafNodeID(lookup($1)); $$ = root; }
    | NUM { exprNode *root = createLeafNodeConst($1); $$ = root; }
    | EXPR {
        exprNode *root = $1; $$ = root;
        }
    ;

%%


int yyerror(const char *s) {

    ERROR_CNT++;

    printf("Pausing parsing");
    for (int i = 0; i < 3; ++i) {
        printf(".");
        fflush(stdout);
        sleep(1);
    }
    printf("\n"); 

    printf("Error in Statement # %d\n", STMT_CNT);
    fprintf(stderr, "%s\n", s);
    sleep(1);
    yyerrstatus = 0;                // doesnt raise a make error as error has been handled

    printf("Attempt to resume parsing");
    for (int i = 0; i < 3; ++i) {
        printf(".");
        fflush(stdout);
        sleep(1);
    }
    printf("\n");
    STMT_CNT--;                    // decrement the statement count as the error statement is not executed

    return 0;
}

