%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include<ctype.h>
    
    int yylex();
    int yyerror(const char *s);

    typedef struct _node{
        char *name;
        int value;
        struct _node *next;
    }node;

    typedef enum { OP_TYPE, NUM_TYPE, ID_TYPE } nodeType;

    typedef struct _exprNode{
        nodeType type;
        struct _exprNode *left;
        struct _exprNode *right;
        union {
        char op;
        int numValue;
        char *idName;
    } data;
    }exprNode;

    typedef node* symbolTable;

    node* insert(char *name);
    node* lookup(char *name);
    void set(node *name, int value);

    

    // simple function declarations
    exprNode* createLeafNodeConst(int value);
    exprNode* createLeafNodeID(symbolTable symtbl);
    exprNode* createOpNode(char op, exprNode *left, exprNode *right);
    void printExprTree(exprNode *root);
    int evaluate(exprNode *root);
    void deleteTree(exprNode *root);

%}

%union{
    int ival;
    char *sval;
    char cval;
    struct _exprNode *expr;
    
}
/*
PROGRAM ⟶ STMT PROGRAM | STMT
STMT ⟶ SETSTMT | EXPRSTMT
SETSTMT ⟶ ( set ID NUM ) | ( set ID ID ) | ( set ID EXPR )
EXPRSTMT ⟶ EXPR
EXPR ⟶ ( OP ARG ARG )
OP ⟶ + | – | * | / | % | **
ARG ⟶ ID | NUM | EXPR
*/

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

STMT: SETSTMT 
    | EXPRSTMT
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
                fprintf(stderr, "Variable %s not found\n", $4);
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
            deleteTree($4);
        } // use the expression tree to evaluate the expression, free the tree for this expression after wards
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

