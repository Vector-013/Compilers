%{
    #include <iostream>
    #include <string>
    #include <vector>
    using namespace std;

    struct quad
    {
        string op;
        string arg1;
        string arg2;
        string result;
        int alt_ins;
    };

    struct symbol
    {
        string name;
        int regno;
        int is_temp;
        int is_const;
        int is_mem;
        symbol *next;
    };

    struct symtab
    {
        symbol *head;
        symtab *next;
    };

    struct RegisterBank
    {
        symtab *symbols;
    };

    symbol *symbol_search(string name, int is_temp, int is_const);
    void emit(const string &op, const string &arg1, const string &arg2, const string &result, int assembly);
    symbol *gen_temp();

    extern vector <quad> quads;
    extern vector <int> leaders;

    extern int temp_count;
    extern int next_instr;

    extern int yylex();
    void yyerror(string s);
    extern int yylex(void);

%}

%union { int num; char *str; struct symbol *sym; }

%token <str> IDEN NUMB
%token SET WHEN WHILE OB CB
%token <str> ADD SUB MUL DIV MOD EQ NEQ LT GT LE GE

%type LIST STMT ASGN COND LOOP
%type <num> BOOL M
%type <str> OPER RELN
%type <sym> ATOM EXPR

%start LIST

%%

LIST : STMT
    | STMT LIST
    ;

STMT : ASGN
    | COND
    | LOOP
    ;

ASGN : OB SET IDEN ATOM CB{
        symbol *var = symbol_search($3, 0, 0);
        emit("=", $4->name, "", var->name, 0);
    }
    ;

COND : OB WHEN M BOOL M LIST CB {
        int x = $4;
        if(quads[x].op == "if" || quads[x].op == "gt")
        {
            string gotoIns = to_string(next_instr);
            quads[x].result = gotoIns;
        }
        leaders[next_instr] = 1;
    }
    ;

LOOP : OB WHILE M BOOL M LIST CB {
        int x = $4;
        if(quads[x].op == "if" || quads[x].op == "gt")
        {
            string gotoIns = to_string(next_instr + 1);
            quads[x].result = gotoIns;
        }
        string s = to_string($3);
        emit("gt", "", "", s, 0);
        leaders[next_instr] = 1;
    }
    ;

M : {
        leaders[next_instr] = 1;
        $$ = next_instr;
    }

ATOM : IDEN { $$ = symbol_search($1, 0, 0); }
    | NUMB  { $$ = symbol_search($1, 0, 1); }
    | EXPR
    ;
EXPR : OB OPER ATOM ATOM CB {
        symbol *temp = gen_temp();
        emit($2, $3->name, $4->name, temp->name, 0);
        $$ = temp;
    }
    ;

BOOL : OB RELN ATOM ATOM CB {
        string s = $3->name + " " + $2 + " " + $4->name;
        $$ = next_instr;
        emit("if", s, "", "", 0);
    }
    ;

OPER : ADD
    | SUB
    | MUL
    | DIV
    | MOD
    ;

RELN : EQ
    | NEQ
    | LT
    | GT
    | LE
    | GE
    ;

%%