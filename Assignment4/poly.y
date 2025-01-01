%{
    #include "globals.h"
    int yylex(void);
%}

%union{
    int ival;
    char cval;
    struct _exprNode *expr;
}

%token <ival> DIGIT ZERO ONE
%token <cval> VAR EXPO PLUS MINUS
%start start_pt
%type <expr> S P T X N M

%%
start_pt: S{
    set_attr($1);
    printf("The annotated parse tree is:\n");
    print_tree($1, 0);
    printf("\n");
    for(long long i=-5;i<=5;i++){
        printf("f(%lld) = %lld\n", i, evalpoly($1, i));
    }
    printf("f'(x) =");print_derivative($1);printf("\n");
    }
    ;

S: P {
        $$ = insert('S');
        add_child($$, $1);
    }
    | PLUS P {
        $$ = insert('S');
        exprNode *plus_node = insert('+');
        plus_node->symbol.op = '+';
        add_child($$, $2);
        add_child($$, plus_node);
    }
    | MINUS P {
        $$ = insert('S');
        exprNode *minus_node = insert('-');
        minus_node->symbol.op = '-';
        add_child($$, $2);
        add_child($$, minus_node);
    }
    ;

P: T {
        $$ = insert('P');
        add_child($$, $1);
    }
    | T PLUS P {
        $$ = insert('P');
        exprNode *plus_node = insert('+');
        plus_node->symbol.op = '+';
        add_child($$, $3);
        add_child($$, plus_node);
        add_child($$, $1);
    }
    | T MINUS P {
        $$ = insert('P');
        exprNode *minus_node = insert('-');
        minus_node->symbol.op = '-';
        add_child($$, $3);
        add_child($$, minus_node);
        add_child($$, $1);
    }
    ;

T: ONE {
        $$ = insert('T');
        exprNode *one_node = insert('1');
        one_node->syn.value = 1;
        add_child($$, one_node);
    }
    | N {
        $$ = insert('T');
        add_child($$, $1);
    }
    | X {
        $$ = insert('T');
        add_child($$, $1);
    }
    | N X {
        $$ = insert('T');
        add_child($$, $2);
        add_child($$, $1);
    }
    ;

X: VAR {
        $$ = insert('X');
        exprNode *var_node = insert('x');
        var_node->symbol.var = 'x';
        add_child($$, var_node);
    }
    | VAR EXPO N {
        $$ = insert('X');
        exprNode *var_node = insert('x');
        exprNode *expo_node = insert('^');
        var_node->symbol.var = 'x';
        expo_node->symbol.op = '^';
        add_child($$, $3);
        add_child($$, expo_node);
        add_child($$, var_node);
    }
    ;

N: DIGIT {
        $$ = insert('N');
        char ch = '0' + $1;
        exprNode *digit_node = insert(ch);
        digit_node->syn.value = $1;
        add_child($$, digit_node);
    }
    | ONE M {
        $$ = insert('N');
        exprNode *one_node = insert('1');
        one_node->syn.value = 1;
        add_child($$, $2);
        add_child($$, one_node);
    }
    | DIGIT M {
        $$ = insert('N');
        char ch = '0' + $1;
        exprNode *digit_node = insert(ch);
        digit_node->syn.value = $1;
        add_child($$, $2);
        add_child($$, digit_node);
    }
    ;

M: ZERO {
        $$ = insert('M');
        exprNode *zero_node = insert('0');
        zero_node->syn.value = 0;
        add_child($$, zero_node);
    }
    | ONE {
        $$ = insert('M');
        exprNode *one_node = insert('1');
        one_node->syn.value = 1;
        add_child($$, one_node);
    }
    | DIGIT {
         
        $$ = insert('M');
        char ch = '0' + $1;
        exprNode *digit_node = insert(ch);
        digit_node->syn.value = $1;
        add_child($$, digit_node);
    }
    | ZERO M {
        $$ = insert('M');
        exprNode *zero_node = insert('0');
        zero_node->syn.value = 0;
        add_child($$, $2);
        add_child($$, zero_node);
    }
    | ONE M {
        $$ = insert('M');
        exprNode *one_node = insert('1');
        one_node->syn.value = 1;
        add_child($$, $2);
        add_child($$, one_node);
    }
    | DIGIT M {
        $$ = insert('M');
        char ch = '0' + $1;
        exprNode *digit_node = insert(ch);
        digit_node->syn.value = $1;
        add_child($$, $2);
        add_child($$, digit_node);
    }
    ;

%%