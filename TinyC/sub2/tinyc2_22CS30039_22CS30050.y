%{
    #include "globals.h"
    int yylex();
%}

%union{
    int ival;
    float fval;
    char *sval;
    char cval;
    struct _node* tree_node;
}

%token AUTO BREAK CASE CHAR CONST CONTINUE DEFAULT DO DOUBLE ELSE EXTERN FLOAT FOR GOTO IF INLINE INT LONG REGISTER RESTRICT RETURN SHORT SIGNED SIZEOF STATIC SWITCH UNSIGNED VOID VOLATILE WHILE BOOL COMPLEX IMAGINARY
%token LBRACKET RBRACKET LPAREN RPAREN LBRACE RBRACE DOT ARROW INC DEC AMP AST PLUS MINUS TILDE NOT DIV MOD LSHIFT RSHIFT LT GT LTE GTE EQ NE XOR OR AND OROR QUEST COLON SEMICOLON ELLIPSIS ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN SUB_ASSIGN LSHIFT_ASSIGN RSHIFT_ASSIGN AND_ASSIGN XOR_ASSIGN OR_ASSIGN COMMA

%token <sval> IDENTIFIER
%token <ival> CONST_INT
%token <fval> CONST_FLT
%token <cval> CONST_CHAR
%token <sval> STR_LIT
%type <tree_node> init_declarator_list init_declarator primary_expression postfix_expression argument_expression_list_opt argument_expression_list unary_expression unary_operator cast_expression multiplicative_expression additive_expression shift_expression relational_expression equality_expression AND_expression exclusive_OR_expression inclusive_OR_expression logical_AND_expression logical_OR_expression conditional_expression assignment_expression assignment_expression_opt assignment_operator expression constant_expression declaration declaration_specifiers init_declarator_list_opt declaration_specifiers_opt storage_class_specifier type_specifier specifier_qualifier_list specifier_qualifier_list_opt type_qualifier function_specifier declarator direct_declarator pointer_opt pointer type_qualifier_list_opt type_qualifier_list parameter_type_list parameter_list parameter_declaration identifier_list_opt identifier_list type_name initializer initializer_list designation_opt designation designator_list designator statement labeled_statement compound_statement block_item_list_opt block_item_list expression_statement expression_opt selection_statement iteration_statement jump_statement translation_unit external_declaration function_definition declaration_list_opt declaration_list block_item

%start start_pt

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

primary_expression  : IDENTIFIER{
                                        std::string str = "primary_expression -> " + std::string($1);
                                        $$ = insert(str);
                                    }
                    | CONST_INT{
                                        std::string str = "primary_expression -> " + std::to_string($1);
                                        $$ = insert(str);
                                    }
                    | CONST_FLT{
                                        std::string str = "primary_expression -> " + std::to_string($1);
                                        $$ = insert(str);
                                    }
                    | CONST_CHAR{
                                        std::string str = "primary_expression -> " + std::to_string($1);
                                        $$ = insert(str);
                                    }
                    | STR_LIT{
                                        std::string str = "primary_expression -> " + std::string($1);
                                        $$ = insert(str);
                                    }
                    | LPAREN expression RPAREN{
                                        $$ = insert("primary_expression -> ( expression )");
                                        add_child($$, $2);
                                    }
                    ;

postfix_expression  : primary_expression{
                                        $$ = insert("postfix_expression -> primary_expression");
                                        add_child($$, $1);
                                    }    
                    | postfix_expression LBRACKET expression RBRACKET{
                                        $$ = insert("postfix_expression -> postfix_expression [ expression ]");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | postfix_expression LPAREN argument_expression_list_opt RPAREN{
                                        $$ = insert("postfix_expression -> postfix_expression ( argument_expression_list_opt )");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | postfix_expression DOT IDENTIFIER{
                                        std::string str = "postfix_expression -> postfix_expression . " + std::string($3);
                                        $$ = insert(str);
                                        add_child($$, $1);
                                    }
                    | postfix_expression ARROW IDENTIFIER{
                                        std::string str = "postfix_expression -> postfix_expression -> " + std::string($3);
                                        $$ = insert(str);
                                        add_child($$, $1);
                                    }
                    | postfix_expression INC{
                                        $$ = insert("postfix_expression -> postfix_expression ++");
                                        add_child($$, $1);
                                    }
                    | postfix_expression DEC{
                                        $$ = insert("postfix_expression -> postfix_expression --");
                                        add_child($$, $1);
                                    }
                    | LPAREN type_name RPAREN LBRACE initializer_list RBRACE{
                                        $$ = insert("postfix_expression -> ( type_name ) { initializer_list }");
                                        add_child($$, $5);
                                        add_child($$, $2);
                                    }
                    | LPAREN type_name RPAREN LBRACE initializer_list COMMA RBRACE{
                                        $$ = insert("postfix_expression -> ( type_name ) { initializer_list , }");
                                        add_child($$, $5);
                                        add_child($$, $2);
                                    }
                    ;

argument_expression_list_opt : /* empty */{
                                        $$ = insert("argument_expression_list_opt -> epsilon");
                                    }
                            | argument_expression_list{
                                        $$ = insert("argument_expression_list_opt -> argument_expression_list");
                                        add_child($$, $1);
                                    }
                            ;

argument_expression_list : assignment_expression{
                                        $$ = insert("argument_expression_list -> assignment_expression");
                                        add_child($$, $1);
                                    }
                        | argument_expression_list COMMA assignment_expression{
                                        $$ = insert("argument_expression_list -> argument_expression_list , assignment_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

unary_expression    : postfix_expression{
                                        $$ = insert("unary_expression -> postfix_expression");
                                        add_child($$, $1);
                                    }
                    | INC unary_expression{
                                        $$ = insert("unary_expression -> ++ unary_expression");
                                        add_child($$, $2);
                                    }
                    | DEC unary_expression{
                                        $$ = insert("unary_expression -> -- unary_expression");
                                        add_child($$, $2);
                                    }
                    | unary_operator cast_expression{
                                        $$ = insert("unary_expression -> unary_operator cast_expression");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    | SIZEOF unary_expression{
                                        $$ = insert("unary_expression -> sizeof unary_expression");
                                        add_child($$, $2);
                                    }
                    | SIZEOF LPAREN type_name RPAREN{
                                        $$ = insert("unary_expression -> sizeof ( type_name )");
                                        add_child($$, $3);
                                    }
                    ;

unary_operator      : AMP{ $$ = insert("unary_operator -> &"); }
                    | AST{ $$ = insert("unary_operator -> *"); }
                    | PLUS{ $$ = insert("unary_operator -> +"); }
                    | MINUS{ $$ = insert("unary_operator -> -"); }
                    | TILDE{ $$ = insert("unary_operator -> ~"); }
                    | NOT{ $$ = insert("unary_operator -> !"); }
                    ;

cast_expression     : unary_expression{
                                        $$ = insert("cast_expression -> unary_expression");
                                        add_child($$, $1);
                                    }
                    | LPAREN type_name RPAREN cast_expression{
                                        $$ = insert("cast_expression -> ( type_name ) cast_expression");
                                        add_child($$, $4);
                                        add_child($$, $2);
                                    }
                    ;

multiplicative_expression : cast_expression{
                                        $$ = insert("multiplicative_expression -> cast_expression");
                                        add_child($$, $1);
                                    }
                        | multiplicative_expression AST cast_expression{
                                        $$ = insert("multiplicative_expression -> multiplicative_expression * cast_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        | multiplicative_expression DIV cast_expression{
                                        $$ = insert("multiplicative_expression -> multiplicative_expression / cast_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        | multiplicative_expression MOD cast_expression{
                                        $$ = insert("multiplicative_expression -> multiplicative_expression %% cast_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

additive_expression : multiplicative_expression{
                                        $$ = insert("additive_expression -> multiplicative_expression");
                                        add_child($$, $1);
                                    }
                    | additive_expression PLUS multiplicative_expression{
                                        $$ = insert("additive_expression -> additive_expression + multiplicative_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | additive_expression MINUS multiplicative_expression{
                                        $$ = insert("additive_expression -> additive_expression - multiplicative_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

shift_expression    : additive_expression{
                                        $$ = insert("shift_expression -> additive_expression");
                                        add_child($$, $1);
                                    }
                    | shift_expression LSHIFT additive_expression{
                                        $$ = insert("shift_expression -> shift_expression << additive_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | shift_expression RSHIFT additive_expression{
                                        $$ = insert("shift_expression -> shift_expression >> additive_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

relational_expression : shift_expression{
                                        $$ = insert("relational_expression -> shift_expression");
                                        add_child($$, $1);
                                    }
                        | relational_expression LT shift_expression{
                                        $$ = insert("relational_expression -> relational_expression < shift_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        | relational_expression GT shift_expression{
                                        $$ = insert("relational_expression -> relational_expression > shift_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        | relational_expression LTE shift_expression{
                                        $$ = insert("relational_expression -> relational_expression <= shift_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        | relational_expression GTE shift_expression{
                                        $$ = insert("relational_expression -> relational_expression >= shift_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;
                 
equality_expression : relational_expression{
                                        $$ = insert("equality_expression -> relational_expression");
                                        add_child($$, $1);
                                    }
                    | equality_expression EQ relational_expression{
                                        $$ = insert("equality_expression -> equality_expression == relational_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | equality_expression NE relational_expression{
                                        $$ = insert("equality_expression -> equality_expression != relational_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;
        
AND_expression      : equality_expression{
                                        $$ = insert("AND_expression -> equality_expression");
                                        add_child($$, $1);
                                    }
                    | AND_expression AMP equality_expression{
                                        $$ = insert("AND_expression -> AND_expression & equality_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

exclusive_OR_expression : AND_expression{
                                        $$ = insert("exclusive_OR_expression -> AND_expression");
                                        add_child($$, $1);
                                    }
                        | exclusive_OR_expression XOR AND_expression{
                                        $$ = insert("exclusive_OR_expression -> exclusive_OR_expression ^ AND_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

inclusive_OR_expression : exclusive_OR_expression{
                                        $$ = insert("inclusive_OR_expression -> exclusive_OR_expression");
                                        add_child($$, $1);
                                    }
                        | inclusive_OR_expression OR exclusive_OR_expression{
                                        $$ = insert("inclusive_OR_expression -> inclusive_OR_expression | exclusive_OR_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

logical_AND_expression : inclusive_OR_expression{
                                        $$ = insert("logical_AND_expression -> inclusive_OR_expression");
                                        add_child($$, $1);
                                    }
                        | logical_AND_expression AND inclusive_OR_expression{
                                        $$ = insert("logical_AND_expression -> logical_AND_expression && inclusive_OR_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

logical_OR_expression : logical_AND_expression{
                                        $$ = insert("logical_OR_expression -> logical_AND_expression");
                                        add_child($$, $1);
                                    } 
                        | logical_OR_expression OROR logical_AND_expression{
                                        $$ = insert("logical_OR_expression -> logical_OR_expression || logical_AND_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

conditional_expression : logical_OR_expression{
                                        $$ = insert("conditional_expression -> logical_OR_expression");
                                        add_child($$, $1);
                                    } 
                        | logical_OR_expression QUEST expression COLON conditional_expression{
                                        $$ = insert("conditional_expression -> logical_OR_expression ? expression : conditional_expression");
                                        add_child($$, $5);
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                        ;

assignment_expression : conditional_expression{
                                        $$ = insert("assignment_expression -> conditional_expression");
                                        add_child($$, $1);
                                    }
                        | unary_expression assignment_operator assignment_expression{
                                        $$ = insert("assignment_expression -> unary_expression assignment_operator assignment_expression");
                                        add_child($$, $3);
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        ;

assignment_expression_opt : /* empty */{
                                        $$ = insert("assignment_expression_opt -> epsilon");
                                    }
                        | assignment_expression{
                                        $$ = insert("assignment_expression_opt -> assignment_expression");
                                        add_child($$, $1);
                                    }
                        ;

assignment_operator : ASSIGN{
                                        $$ = insert("assignment_operator -> =");
                                    }
                    | MUL_ASSIGN{
                                        $$ = insert("assignment_operator -> *=");
                                    }
                    | DIV_ASSIGN{
                                        $$ = insert("assignment_operator -> /=");
                                    }
                    | MOD_ASSIGN{
                                        $$ = insert("assignment_operator -> %=");
                                    }
                    | ADD_ASSIGN{
                                        $$ = insert("assignment_operator -> +=");
                                    }
                    | SUB_ASSIGN{
                                        $$ = insert("assignment_operator -> -=");
                                    }
                    | LSHIFT_ASSIGN{
                                        $$ = insert("assignment_operator -> <<=");
                                    }
                    | RSHIFT_ASSIGN{
                                        $$ = insert("assignment_operator -> >>=");
                                    }
                    | AND_ASSIGN{
                                        $$ = insert("assignment_operator -> &=");
                                    }
                    | XOR_ASSIGN{
                                        $$ = insert("assignment_operator -> ^=");
                                    }
                    | OR_ASSIGN{
                                        $$ = insert("assignment_operator -> |=");
                                    }
                    ;

expression          : assignment_expression{
                                        $$ = insert("expression -> assignment_expression");
                                        add_child($$, $1);
                                    }
                    | expression COMMA assignment_expression{
                                        $$ = insert("expression -> expression , assignment_expression");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

constant_expression : conditional_expression{
                                        $$ = insert("constant_expression -> conditional_expression");
                                        add_child($$, $1);
                                    }
                    ;

declaration         : declaration_specifiers init_declarator_list_opt SEMICOLON{
                                        $$ = insert("declaration -> declaration_specifiers init_declarator_list_opt ;");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    ;

init_declarator_list_opt : /* empty */{
                                        $$ = insert("init_declarator_list_opt -> epsilon");
                                    }
                        | init_declarator_list{
                                        $$ = insert("init_declarator_list_opt -> init_declarator_list");
                                        add_child($$, $1);
                                    }
                        ;
                    
declaration_specifiers_opt : /* empty */{
                                        $$ = insert("declaration_specifiers_opt -> epsilon");
                                    }
                            | declaration_specifiers{
                                        $$ = insert("declaration_specifiers_opt -> declaration_specifiers");
                                        add_child($$, $1);
                                    }
                            ;

declaration_specifiers : storage_class_specifier declaration_specifiers_opt{
                                        $$ = insert("declaration_specifiers -> storage_class_specifier declaration_specifiers_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        | type_specifier declaration_specifiers_opt{
                                        $$ = insert("declaration_specifiers -> type_specifier declaration_specifiers_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        | type_qualifier declaration_specifiers_opt{
                                        $$ = insert("declaration_specifiers -> type_qualifier declaration_specifiers_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        | function_specifier declaration_specifiers_opt{
                                        $$ = insert("declaration_specifiers -> function_specifier declaration_specifiers_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        ;

init_declarator_list : init_declarator{
                                        $$ = insert("init_declarator_list -> init_declarator");
                                        add_child($$, $1);
                                    }
                    | init_declarator_list COMMA init_declarator{
                                        $$ = insert("init_declarator_list -> init_declarator_list , init_declarator");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

init_declarator     : declarator{
                                        $$ = insert("init_declarator -> declarator");
                                        add_child($$, $1);
                                    }
                    | declarator ASSIGN initializer{
                                        $$ = insert("init_declarator -> declarator = initializer");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;
            
storage_class_specifier : AUTO{
                                        $$ = insert("storage_class_specifier -> auto");
                                    }
                        | REGISTER{
                                        $$ = insert("storage_class_specifier -> register");
                                    }
                        | STATIC{
                                        $$ = insert("storage_class_specifier -> static");
                                    }
                        | EXTERN{
                                        $$ = insert("storage_class_specifier -> extern");
                                    }
                        ;

type_specifier      : VOID{
                                        $$ = insert("type_specifier -> void");
                                    }
                    | CHAR{
                                        $$ = insert("type_specifier -> char");
                                    }
                    | SHORT{
                                        $$ = insert("type_specifier -> short");
                                    }
                    | INT{
                                        $$ = insert("type_specifier -> int");
                                    }
                    | LONG{
                                        $$ = insert("type_specifier -> long");
                                    }
                    | FLOAT{
                                        $$ = insert("type_specifier -> float");
                                    }
                    | DOUBLE{
                                        $$ = insert("type_specifier -> double");
                                    }
                    | SIGNED{
                                        $$ = insert("type_specifier -> signed");
                                    }
                    | UNSIGNED{
                                        $$ = insert("type_specifier -> unsigned");
                                    }
                    | BOOL{
                                        $$ = insert("type_specifier -> _Bool");
                                    }
                    | COMPLEX{
                                        $$ = insert("type_specifier -> _Complex");
                                    }
                    | IMAGINARY{
                                        $$ = insert("type_specifier -> _Imaginary");
                                    }
                    ;

specifier_qualifier_list : type_specifier specifier_qualifier_list_opt{
                                        $$ = insert("specifier_qualifier_list -> type_specifier specifier_qualifier_list_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        | type_qualifier specifier_qualifier_list_opt{
                                        $$ = insert("specifier_qualifier_list -> type_qualifier specifier_qualifier_list_opt");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                        ;

specifier_qualifier_list_opt : /* empty */{
                                        $$ = insert("specifier_qualifier_list_opt -> epsilon");
                                    }
                            | specifier_qualifier_list{
                                        $$ = insert("specifier_qualifier_list_opt -> specifier_qualifier_list");
                                        add_child($$, $1);
                                    }
                            ;

type_qualifier      : CONST{
                            $$ = insert("type_qualifier -> const");
                        }
                    | VOLATILE{
                            $$ = insert("type_qualifier -> volatile");
                        }
                    | RESTRICT{
                            $$ = insert("type_qualifier -> restrict");
                        }
                    ;

function_specifier  : INLINE{
                            $$ = insert("function_specifier -> inline");
                        }
                    ;

declarator          : pointer_opt direct_declarator{
                                        $$ = insert("declarator -> pointer_opt direct_declarator");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    ;

direct_declarator   : IDENTIFIER{
                                        std::string str = "direct_declarator -> " + std::string($1);
                                        $$ = insert(str);
                                    }
                    | LPAREN declarator RPAREN{
                                        $$ = insert("direct_declarator -> ( declarator )");
                                        add_child($$, $2);
                                    }
                    | direct_declarator LBRACKET type_qualifier_list_opt assignment_expression_opt RBRACKET{
                                        $$ = insert("direct_declarator -> direct_declarator [ type_qualifier_list_opt assignment_expression_opt ]");
                                        add_child($$, $4);
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | direct_declarator LBRACKET STATIC type_qualifier_list_opt assignment_expression RBRACKET{
                                        $$ = insert("direct_declarator -> direct_declarator [ static type_qualifier_list_opt assignment_expression ]");
                                        add_child($$, $5);
                                        add_child($$, $4);
                                        add_child($$, $1);
                                    }
                    | direct_declarator LBRACKET type_qualifier_list STATIC assignment_expression RBRACKET{
                                        $$ = insert("direct_declarator -> direct_declarator [ type_qualifier_list static assignment_expression ]");
                                        add_child($$, $5);
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | direct_declarator LBRACKET type_qualifier_list_opt AST RBRACKET{
                                        $$ = insert("direct_declarator -> direct_declarator [ type_qualifier_list_opt * ]");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | direct_declarator LPAREN parameter_type_list RPAREN{
                                        $$ = insert("direct_declarator -> direct_declarator ( parameter_type_list )");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    | direct_declarator LPAREN identifier_list_opt RPAREN{
                                        $$ = insert("direct_declarator -> direct_declarator ( identifier_list_opt )");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

pointer_opt         : /* empty */{
                                        $$ = insert("pointer_opt -> epsilon");
                                    }
                    | pointer{
                                        $$ = insert("pointer_opt -> pointer");
                                        add_child($$, $1);
                                    }
                    ;
                
pointer             : AST type_qualifier_list_opt pointer{
                                        $$ = insert("pointer -> * type_qualifier_list_opt pointer");
                                        add_child($$, $3);
                                        add_child($$, $2);
                                    }
                    | AST type_qualifier_list_opt{
                                        $$ = insert("pointer -> * type_qualifier_list_opt");
                                        add_child($$, $2);
                                    }
                    ;

type_qualifier_list_opt : /* empty */{
                                        $$ = insert("type_qualifier_list_opt -> epsilon");
                                    }
                        | type_qualifier_list{
                                        $$ = insert("type_qualifier_list_opt -> type_qualifier_list");
                                        add_child($$, $1);
                                    }
                        ;

type_qualifier_list : type_qualifier{
                                        $$ = insert("type_qualifier_list -> type_qualifier");
                                        add_child($$, $1);
                                    }
                    | type_qualifier_list type_qualifier{
                                        $$ = insert("type_qualifier_list -> type_qualifier_list type_qualifier");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    ;

parameter_type_list : parameter_list{
                                        $$ = insert("parameter_type_list -> parameter_list");
                                        add_child($$, $1);
                                    }
                    | parameter_list COMMA ELLIPSIS{
                                        $$ = insert("parameter_type_list -> parameter_list , ...");
                                        add_child($$, $1);
                                    }
                    ;

parameter_list      : parameter_declaration{
                                        $$ = insert("parameter_list -> parameter_declaration");
                                        add_child($$, $1);
                                    }
                    | parameter_list COMMA parameter_declaration{
                                        $$ = insert("parameter_list -> parameter_list , parameter_declaration");
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

parameter_declaration : declaration_specifiers declarator{
                                        $$ = insert("parameter_declaration -> declaration_specifiers declarator");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    | declaration_specifiers{
                                        $$ = insert("parameter_declaration -> declaration_specifiers");
                                        add_child($$, $1);
                                    }
                    ;

identifier_list_opt : /* empty */{
                                        $$ = insert("identifier_list_opt -> epsilon");
                                    }
                    | identifier_list{
                                        $$ = insert("identifier_list_opt -> identifier_list");
                                        add_child($$, $1);
                                    }
                    ;

identifier_list     : IDENTIFIER{
                                        std::string str = "identifier_list -> " + std::string($1);
                                        $$ = insert(str);
                                    }
                    | identifier_list COMMA IDENTIFIER{
                                        std::string str = "identifier_list -> " + std::string($3);
                                        $$ = insert(str);
                                        add_child($$, $1);
                                    }
                    ;

type_name           : specifier_qualifier_list{
                                        $$ = insert("type_name -> specifier_qualifier_list");
                                        add_child($$, $1);
                                    }
                    ;

initializer         : assignment_expression{
                                        $$ = insert("initializer -> assignment_expression");
                                        add_child($$, $1);
                                    }
                    | LBRACE initializer_list RBRACE{
                                        $$ = insert("initializer -> { initializer_list }");
                                        add_child($$, $2);
                                    }
                    | LBRACE initializer_list COMMA RBRACE{
                                        $$ = insert("initializer -> { initializer_list , }");
                                        add_child($$, $2);
                                    }
                    ;

initializer_list    : designation_opt initializer{
                                        $$ = insert("initializer_list -> designation_opt initializer");
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    | initializer_list COMMA designation_opt initializer{
                                        $$ = insert("initializer_list -> initializer_list , designation_opt initializer");
                                        add_child($$, $4);
                                        add_child($$, $3);
                                        add_child($$, $1);
                                    }
                    ;

designation_opt     : /* empty */{
                                        $$ = insert("designation_opt -> epsilon"); 
                                    }
                    | designation{
                                        $$ = insert("designation_opt -> designation"); 
                                        add_child($$, $1);
                                    }
                    ;

designation         : designator_list ASSIGN{
                                        $$ = insert("designation -> designator_list =");
                                        add_child($$, $1);
                                    }
                    ;
                
designator_list     : designator{
                                    $$ = insert("designator_list -> designator"); 
                                    add_child($$, $1);
                                }
                    | designator_list designator{
                                        $$ = insert("designator_list -> designator_list designator"); 
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    ;

designator          : LBRACKET constant_expression RBRACKET{
                                        $$ = insert("designator -> [ constant_expression ]");
                                        add_child($$, $2); 
                                    }
                    | DOT IDENTIFIER{
                                        std::string str = "designator -> . " + std::string($2);
                                        $$ = insert(str);
                                    }
                    ;

statement           : labeled_statement{
                                        $$ = insert("statement -> labeled_statement");
                                        add_child($$, $1);
                                    }
                    | compound_statement{
                                        $$ = insert("statement -> compound_statement");
                                        add_child($$, $1);
                                    }
                    | expression_statement{
                                        $$ = insert("statement -> expression_statement");
                                        add_child($$, $1); 
                                    }
                    | selection_statement{
                                        $$ = insert("statement -> selection_statement");
                                        add_child($$, $1); 
                                    }
                    | iteration_statement{
                                        $$ = insert("statement -> iteration_statement");
                                        add_child($$, $1); 
                                    }
                    | jump_statement{
                                        $$ = insert("statement -> jump_statement"); 
                                        add_child($$, $1);
                                    }
                    ;

labeled_statement   : IDENTIFIER COLON statement{
                                        std::string str = "labeled_statement -> " + std::string($1) + " : statement";
                                        $$ = insert(str); 
                                        add_child($$, $3);
                                    }
                    | CASE constant_expression COLON statement{
                                        $$ = insert("labeled_statement -> case constant_expression : statement"); 
                                        add_child($$, $4);
                                        add_child($$, $2);
                                    }
                    | DEFAULT COLON statement{
                                        $$ = insert("labeled_statement -> default : statement"); 
                                        add_child($$, $3);
                                    }
                    ;

compound_statement  : LBRACE block_item_list_opt RBRACE{
                                        $$ = insert("compound_statement -> { block_item_list_opt }"); 
                                        add_child($$, $2);
                                    }
                    ;

block_item_list_opt : /* empty */{
                                        $$ = insert("block_item_list_opt -> epsilon"); 
                                    }
                    | block_item_list{
                                        $$ = insert("block_item_list_opt -> block_item_list"); 
                                        add_child($$, $1);
                                    }
                    ;

block_item_list     : block_item{
                                        $$ = insert("block_item_list -> block_item"); 
                                        add_child($$, $1);
                                    }
                    | block_item_list block_item{
                                        $$ = insert("block_item_list -> block_item_list block_item"); 
                                        add_child($$, $2);
                                        add_child($$, $1);
                                    }
                    ;

block_item          : declaration{
                                        $$ = insert("block_item -> declaration"); 
                                        add_child($$, $1);
                                    }
                    | statement{
                                        $$ = insert("block_item -> statement"); 
                                        add_child($$, $1);
                                    }
                    ;

expression_statement : expression_opt SEMICOLON{
                                            $$ = insert("expression_statement -> expression_opt ;"); 
                                            add_child($$, $1);
                                        }
                    ;

expression_opt      : /* empty */{
                                        $$ = insert("expression_opt -> epsilon"); 
                                    }
                    | expression{
                                        $$ = insert("expression_opt -> expression"); 
                                        add_child($$, $1);
                                    }
                    ;

selection_statement : IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE {
                                            $$ = insert("selection_statement -> if ( expression ) statement"); 
                                            add_child($$, $5);
                                            add_child($$, $3);
                                        }
                    | IF LPAREN expression RPAREN statement ELSE statement{
                                            $$ = insert("selection_statement -> if ( expression ) statement else statement"); 
                                            add_child($$, $7);
                                            add_child($$, $5);
                                            add_child($$, $3);
                                        }
                    | SWITCH LPAREN expression RPAREN statement{
                                            $$ = insert("selection_statement -> switch ( expression ) statement"); 
                                            add_child($$, $5);
                                            add_child($$, $3);
                                        }
                    ;

iteration_statement : WHILE LPAREN expression RPAREN statement{
                                            $$ = insert("iteration_statement -> while ( expression ) statement"); 
                                            add_child($$, $5);
                                            add_child($$, $3);
                                        }
                    | DO statement WHILE LPAREN expression RPAREN SEMICOLON{
                                            $$ = insert("iteration_statement -> do statement while ( expression ) ;"); 
                                            add_child($$, $5);
                                            add_child($$, $2);
                                        }
                    | FOR LPAREN expression_opt SEMICOLON expression_opt SEMICOLON expression_opt RPAREN statement{
                                            $$ = insert("iteration_statement -> for ( expression_opt ; expression_opt ; expression_opt ) statement"); 
                                            add_child($$, $9);
                                            add_child($$, $7);
                                            add_child($$, $5);
                                            add_child($$, $3);
                    }
                    | FOR LPAREN declaration expression_opt SEMICOLON expression_opt RPAREN statement{
                                            $$ = insert("iteration_statement -> for ( declaration expression_opt ; expression_opt ) statement"); 
                                            add_child($$, $8);
                                            add_child($$, $6);
                                            add_child($$, $4);
                                            add_child($$, $3);
                                        }
                    ;

jump_statement      : GOTO IDENTIFIER SEMICOLON{
                                            std::string str = "jump_statement -> goto " + std::string($2) + " ;";
                                            $$ = insert(str); 
                                        }
                    | CONTINUE SEMICOLON{
                                            $$ = insert("jump_statement -> continue ;"); 
                                        }
                    | BREAK SEMICOLON{
                                            $$ = insert("jump_statement -> break ;"); 
                                        }
                    | RETURN expression_opt SEMICOLON{
                                            $$ = insert("jump_statement -> return expression_opt ;"); 
                                            add_child($$, $2);
                                        }
                    ;

translation_unit    : external_declaration{
                                            $$ = insert("translation_unit -> external_declaration"); 
                                            add_child($$, $1);
                                        }
                    | translation_unit external_declaration{
                                            $$ = insert("translation_unit -> translation_unit external_declaration"); 
                                            add_child($$, $2);
                                            add_child($$, $1);
                                        }
                    ;

external_declaration : function_definition{
                                            $$ = insert("external_declaration -> function_definition"); 
                                            add_child($$, $1);
                                        }
                    | declaration{
                                            $$ = insert("external_declaration -> declaration"); 
                                            add_child($$, $1);
                                        }
                    ;

function_definition : declaration_specifiers declarator declaration_list_opt compound_statement{
                                            $$ = insert("function_definition -> declaration_specifiers declarator declaration_list_opt compound_statement"); 
                                            add_child($$, $4);
                                            add_child($$, $3);
                                            add_child($$, $2);
                                            add_child($$, $1);
                                        }
                    ;

declaration_list_opt : /* empty */ {
                                            $$ = insert("declaration_list_opt -> epsilon"); 
                                        }
                    | declaration_list{
                                            $$ = insert("declaration_list_opt -> declaration_list"); 
                                            add_child($$, $1);
                                        }
                    ;

declaration_list    : declaration{
                                            $$ = insert("declaration_list -> declaration"); 
                                            add_child($$, $1);
                                        }
                    | declaration_list declaration{
                                            $$ = insert("declaration_list -> declaration_list declaration"); 
                                            add_child($$, $2);
                                            add_child($$, $1);
                                        }
                    ;

start_pt            : translation_unit{
                                            print_tree($1, 0);
                                        }
                    ;

%%

