%{
    #include "TinyC3_22CS30050_22CS30039_translator.h"
    extern int yylex();             // Function to get the next token
    extern int yylineno;        // Line number
    void yyerror(std::string);      // Function to throw an error
%}

%union {
    int intVal;    // Integer value
    char *floatVal; // Float value
    char *charVal;      // Character value
    char *stringVal;        // String value
    char *identifierVal;    // Identifier value
    int instructionNumber;  // Instruction number
    int parameterCount;    // Parameter count
    char unaryOperator;   // Unary operator
    Term *symbol;      // Symbol
    Expression *expression; // Expression
    Statement *statement;   // Statement
    Array *array;    // Array
    TType *symbolType;  // Symbol type
}

%token AUTO
%token BREAK
%token CASE
%token CHARTYPE
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOATTYPE
%token FOR
%token GOTO
%token IF
%token INLINE
%token INTTYPE
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token VOIDTYPE
%token VOLATILE
%token WHILE
%token _BOOL
%token _COMPLEX
%token _IMAGINARY

/*
IDENTIFIER points to its entry in the symbol table
The remaining are constants from the code
*/

%token<symbol> IDENTIFIER
%token<intVal> INTEGER_CONSTANT
%token<floatVal> FLOATING_CONSTANT
%token<charVal> CHARACTER_CONSTANT
%token<stringVal> STRING_LITERAL

%token LEFT_SQUARE_BRACKET
%token INCREMENT
%token SLASH
%token QUESTION_MARK
%token ASSIGNMENT
%token COMMA
%token RIGHT_SQUARE_BRACKET
%token LEFT_PARENTHESES
%token LEFT_CURLY_BRACKET
%token RIGHT_CURLY_BRACKET
%token DOT
%token ARROW
%token ASTERISK
%token PLUS
%token MINUS
%token TILDE
%token EXCLAMATION
%token MODULO
%token LEFT_SHIFT
%token RIGHT_SHIFT
%token LESS_THAN
%token GREATER_THAN
%token LESS_EQUAL_THAN
%token GREATER_EQUAL_THAN
%token COLON
%token SEMI_COLON
%token ELLIPSIS
%token ASTERISK_ASSIGNMENT
%token SLASH_ASSIGNMENT
%token MODULO_ASSIGNMENT
%token PLUS_ASSIGNMENT
%token MINUS_ASSIGNMENT
%token LEFT_SHIFT_ASSIGNMENT
%token HASH
%token DECREMENT
%token RIGHT_PARENTHESES
%token BITWISE_AND
%token EQUALS
%token BITWISE_XOR
%token BITWISE_OR
%token LOGICAL_AND
%token LOGICAL_OR
%token RIGHT_SHIFT_ASSIGNMENT
%token NOT_EQUALS
%token BITWISE_AND_ASSIGNMENT
%token BITWISE_OR_ASSIGNMENT
%token BITWISE_XOR_ASSIGNMENT

%token INVALID_TOKEN

%start translation_unit
%right THEN ELSE

// Store unary operator as character
%type<unaryOperator> 
    unary_operator

// Store parameter count as integer
%type<parameterCount> 
    argument_expression_list 
    argument_expression_list_opt

// Expressions
%type<expression>
	expression
	primary_expression  
	multiplicative_expression
	additive_expression
	shift_expression
	relational_expression
	equality_expression
	AND_expression
	exclusive_OR_expression
	inclusive_OR_expression
	logical_AND_expression
	logical_OR_expression
	conditional_expression
	assignment_expression
	expression_statement
    expression_opt

// Arrays
%type<array> 
    postfix_expression
	unary_expression
	cast_expression

// Statements
%type <statement>  
    statement
    loop_statement
	compound_statement
	selection_statement
	iteration_statement
	labeled_statement 
	jump_statement
	block_item
	block_item_list
	block_item_list_opt
    N

// symbol type
%type<symbolType> 
    pointer

// Term
%type<symbol> 
    initialiser
    direct_declarator 
    init_declarator 
    declarator

// Instruction number for backpatching
%type <instructionNumber> 
    M

%%

//The following are production rules for Three Address Code Generation in a Compiler. I have commented the code according to what each instruction does

/* Expressions */
primary_expression: 
                    IDENTIFIER 
                        { 
                            $$ = new Expression();          // Create a new expression
                            $$->loc = $1;                   // Store the symbol in the expression
                            $$->type = "not_bool";          // Set the type of the expression
                        }
                    | INTEGER_CONSTANT 
                        { 
                            $$ = new Expression();                                                      // Create a new expression
                            $$->loc = SymbolTable::genTemp(new TType("int"), std::to_string($1));      // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);                                               // Emit the instruction
                        }
                    | FLOATING_CONSTANT 
                        { 
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new TType("float"), $1);            // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);
                        }
                    | CHARACTER_CONSTANT 
                        { 
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new TType("char"), $1);         // Generate a temporary symbol for the constant
                            emit("=", $$->loc->name, $1);
                        }
                    | STRING_LITERAL 
                        { 
                            $$ = new Expression();
                            $$->loc = SymbolTable::genTemp(new TType("ptr"), $1);              // Generate a temporary symbol for the constant
                            $$->loc->type->arrType = new TType("char");                        // Set the type of the temporary symbol
                        }
                    | LEFT_PARENTHESES expression RIGHT_PARENTHESES
                        { 
                            $$ = $2;
                        }
                    ;

postfix_expression:
                    primary_expression
                        { 
                            $$ = new Array();                       // Create a new array
                            $$->Array = $1->loc;                    // Store the symbol in the array
                            $$->type = $1->loc->type;               // Set the type of the array
                            $$->loc = $$->Array;                    // Set the location of the array
                        }
                    | postfix_expression LEFT_SQUARE_BRACKET expression RIGHT_SQUARE_BRACKET
                        { 
                            $$ = new Array();                                                   // Create a new array
                            $$->type = $1->type->arrType;                                      // Set the type of the array
                            $$->Array = $1->Array;                                             // Store the symbol in the array
                            $$->loc = SymbolTable::genTemp(new TType("int"));                // Generate a temporary symbol for the index
                            $$->atype = "arr";                                                // Set the atype of the array

                            // If the Array is of type array
                            if ($1->atype == "arr") {                                         
                                Term* symbol = SymbolTable::genTemp(new TType("int"));       // Generate a temporary symbol
                                int temp_size = sizeOfType($$->type);                         // Get the size of the type
                                emit("*", symbol->name, $3->loc->name, std::to_string(temp_size)); // Multiply the index with the size of the type
                                emit("+", $$->loc->name, $1->loc->name, symbol->name);       // Add the base address of the array to the index
                            } else {                                                          
                                int temp_size = sizeOfType($$->type);                         // Get the size of the type
                                emit("*", $$->loc->name, $3->loc->name, std::to_string(temp_size)); // Multiply the index with the size of the type
                            }
                        }
                    | postfix_expression LEFT_PARENTHESES argument_expression_list_opt RIGHT_PARENTHESES
                        { 
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->type);                         // Generate a temporary symbol for the function
                            emit("call", $$->Array->name, $1->Array->name, std::to_string($3));     // Instruction to call the function
                        }
                    | postfix_expression DOT IDENTIFIER
                        { 
                        }
                    | postfix_expression ARROW IDENTIFIER
                        { 
                        }
                    | postfix_expression INCREMENT
                        { 
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->Array->type);              // Generate a temporary symbol
                            emit("=", $$->Array->name, $1->Array->name);                    // Instruction to copy the value of the array to the temporary symbol
                            emit("+", $1->Array->name, $1->Array->name, "1");               // Instruction to increment the value of the array
                        }
                    | postfix_expression DECREMENT
                        { 
                            $$ = new Array();
                            $$->Array = SymbolTable::genTemp($1->Array->type);              // Generate a temporary symbol
                            emit("=", $$->Array->name, $1->Array->name);                    // Instruction to copy the value of the array to the temporary symbol
                            emit("-", $1->Array->name, $1->Array->name, "1");               // Instruction to decrement the value of the array
                        }
                    | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initialiser_list RIGHT_CURLY_BRACKET
                        { 
                        }
                    | LEFT_PARENTHESES type_name RIGHT_PARENTHESES LEFT_CURLY_BRACKET initialiser_list COMMA RIGHT_CURLY_BRACKET
                        { 
                        }
                    ;

argument_expression_list_opt:
                                argument_expression_list
                                    { 
                                        $$ = $1;
                                    }
                                | 
                                    { 
                                        $$ = 0;
                                    }
                                ;

argument_expression_list:
                            assignment_expression
                                { 
                                    emit("param", $1->loc->name);                   // Instruction to list the parameter
                                    $$ = 1;
                                }
                            | argument_expression_list COMMA assignment_expression
                                { 
                                    emit("param", $3->loc->name);           // Instruction to list the parameter
                                    $$ = $1 + 1;                            // Increment the parameter count
                                }
                            ;

unary_expression:
                    postfix_expression
                        { 
                            $$ = $1;
                        }
                    | INCREMENT unary_expression
                        { 
                            emit("+", $2->Array->name, $2->Array->name, "1");       // Instruction to increment the value of the Array
                            $$ = $2;  
                        }
                    | DECREMENT unary_expression
                        { 
                            
                            emit("-", $2->Array->name, $2->Array->name, "1");           // Instruction to decrement the value of the Array
                            $$ = $2;
                        }
                    | unary_operator cast_expression
                        { 
                            $$ = new Array();  // Create a new Array

                            switch ($1) {
                                case '&': // Address
                                    $$->Array = SymbolTable::genTemp(new TType("ptr"));
                                    $$->Array->type->arrType = $2->Array->type;
                                    emit("= &", $$->Array->name, $2->Array->name);
                                    break;

                                case '*': // Dereferencing
                                    $$->atype = "ptr";
                                    $$->loc = SymbolTable::genTemp($2->Array->type->arrType);
                                    $$->Array = $2->Array;
                                    emit("= *", $$->loc->name, $2->Array->name);
                                    break;

                                case '+': // Unary plus
                                    $$ = $2;
                                    break;

                                case '-': // Unary minus
                                    $$->Array = SymbolTable::genTemp(new TType($2->Array->type->type));
                                    emit("= -", $$->Array->name, $2->Array->name);
                                    break;

                                case '~': // Bitwise not
                                    $$->Array = SymbolTable::genTemp(new TType($2->Array->type->type));
                                    emit("= ~", $$->Array->name, $2->Array->name);
                                    break;

                                case '!': // Logical not
                                    $$->Array = SymbolTable::genTemp(new TType($2->Array->type->type));
                                    emit("= !", $$->Array->name, $2->Array->name);
                                    break;
                            }

                        }
                    | SIZEOF unary_expression
                        { 
                        }
                    | SIZEOF LEFT_PARENTHESES type_name RIGHT_PARENTHESES
                        { 
                        }
                    ;

unary_operator:
                BITWISE_AND
                    { 
                        $$ = '&'; 
                    }
                | ASTERISK
                    { 
                        $$ = '*'; 
                    }
                | PLUS
                    { 
                        $$ = '+'; 
                    }
                | MINUS
                    { 
                        $$ = '-'; 
                    }
                | TILDE
                    { 
                        $$ = '~'; 
                    }
                | EXCLAMATION
                    { 
                        $$ = '!'; 
                    }
                ;

cast_expression:
                unary_expression
                    { 
                        $$ = $1;
                    }
                | LEFT_PARENTHESES type_name RIGHT_PARENTHESES cast_expression /* can be ignored */
                    { 
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Array();                                       // Create a new Array       
                        $$->Array = convertType($4->Array, globalContext.varType);            // Convert the type of the Array
                    }
                ;

multiplicative_expression:
                            cast_expression
                                { 
                                    $$ = new Expression(); // Create a new Expression

                                    if ($1->atype == "ptr") { // If the Array is of type pointer
                                        $$->loc = $1->loc; // Store the symbol in the Expression
                                    } else if ($1->atype == "arr") { // If the Array is of type array
                                        $$->loc = SymbolTable::genTemp($1->loc->type); // Generate a temporary symbol
                                        emit("=[]", $$->loc->name, $1->Array->name, $1->loc->name); // Emit Quad to copy the value of the Array at that index to the temporary symbol
                                    } else {
                                        $$->loc = $1->Array; // Default case
                                    }
                                }
                            | multiplicative_expression ASTERISK cast_expression
                                {
                                    if (typecheck($1->loc, $3->Array)) { // Check if the types are compatible
                                        $$ = new Expression(); // Create a new Expression
                                        $$->loc = SymbolTable::genTemp(new TType($1->loc->type->type)); // Generate a temporary symbol
                                        emit("*", $$->loc->name, $1->loc->name, $3->Array->name); // Emit Quad to multiply the two values
                                    } else {
                                        yyerror("Incompatible types"); // Throw an error if the types are incompatible
                                    }
                                }

                            | multiplicative_expression SLASH cast_expression
                                { 
                                    if(typecheck($1->loc, $3->Array)) {                                             // Check if the types are compatible
                                        $$ = new Expression();                                                      // Create a new Expression
                                        $$->loc = SymbolTable::genTemp(new TType($1->loc->type->type));            // Generate a temporary symbol
                                        emit("/", $$->loc->name, $1->loc->name, $3->Array->name);                   // Emit Quad to divide the two values
                                    }
                                    else {
                                        yyerror("Incompatible types");      // Throw an error if the types are incompatible
                                    }
                                }
                            | multiplicative_expression MODULO cast_expression
                                { 
                                    if(typecheck($1->loc, $3->Array)) {             // Check if the types are compatible
                                        $$ = new Expression();                                                      // Create a new Expression
                                        $$->loc = SymbolTable::genTemp(new TType($1->loc->type->type));        // Generate a temporary symbol
                                        emit("%", $$->loc->name, $1->loc->name, $3->Array->name);                   // Emit Quad to modulo the two values
                                    }
                                    else {
                                        yyerror("Incompatible types");                  // Throw an error if the types are incompatible
                                    }
                                }
                            ;

additive_expression:
                    multiplicative_expression
                        { 
                            $$ = $1;    
                        }
                    | additive_expression PLUS multiplicative_expression
                        { 
                            if(typecheck($1->loc, $3->loc)) {                                                   // Check if the types are compatible
                                $$ = new Expression();                                                          // Create a new Expression
                                $$->loc = SymbolTable::genTemp(new TType($1->loc->type->type));            // Generate a temporary symbol
                                emit("+", $$->loc->name, $1->loc->name, $3->loc->name);                         // Emit Quad to add the two values
                            }
                            else {
                                yyerror("Incompatible types");                      // Throw an error if the types are incompatible
                            }
                        }
                    | additive_expression MINUS multiplicative_expression
                        { 
                            if(typecheck($1->loc, $3->loc)) {                                           // Check if the types are compatible
                                $$ = new Expression();                                                  // Create a new Expression
                                $$->loc = SymbolTable::genTemp(new TType($1->loc->type->type));    // Generate a temporary symbol
                                emit("-", $$->loc->name, $1->loc->name, $3->loc->name);                 // Emit Quad to subtract the two values
                            }
                            else {
                                yyerror("Incompatible types");                                          // Throw an error if the types are incompatible
                            }
                        }
                    ;

shift_expression:
                    additive_expression
                        { 
                            $$ = $1;                                                        
                        }
                    | shift_expression LEFT_SHIFT additive_expression
                        { 
                            if($3->loc->type->type == "int") {                          // Confirms that the type of the additive expression is int
                                $$ = new Expression();                                      // Create a new Expression
                                $$->loc = SymbolTable::genTemp(new TType("int"));          // Generate a temporary symbol
                                emit("<<", $$->loc->name, $1->loc->name, $3->loc->name);        // Emit Quad to shift the value of the shift expression by the value of the additive expression
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    | shift_expression RIGHT_SHIFT additive_expression
                        { 
                            if($3->loc->type->type == "int") {                                  // Confirms that the type of the additive expression is int
                                $$ = new Expression();                                          // Create a new Expression
                                $$->loc = SymbolTable::genTemp(new TType("int"));          // Generate a temporary symbol
                                emit(">>", $$->loc->name, $1->loc->name, $3->loc->name);        // Emit Quad to shift the value of the shift expression by the value of the additive expression
                            }
                            else {
                                yyerror("Incompatible types");                          // Throw an error if the types are incompatible
                            }
                        }
                    ;

relational_expression:
                        shift_expression
                            { 
                                $$ = $1;
                            }
                        | relational_expression LESS_THAN shift_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                           // Check if the types are compatible
                                    $$ = new Expression();                                  // Create a new Expression
                                    $$->type = "bool";                                      // Set the type of the Expression to bool
                                    $$->trueList = makeList(nextInstruction());             // Set the trueList of the Expression
                                    $$->falseList = makeList(nextInstruction() + 1);        // Set the falseList of the Expression
                                    emit("<", "", $1->loc->name, $3->loc->name);            // Emit Quad to check if the value of the relational expression is less than the value of the shit expression, in which case, a goto is performed
                                    emit("goto", "");                                       // Emit Quad to perform a goto if the condition is false
                                }
                                else {
                                    yyerror("Incompatible types");                      // Throw an error if the types are incompatible
                                }
                            }
                        | relational_expression GREATER_THAN shift_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                                           // Check if the types are compatible
                                    $$ = new Expression();                                      // Create a new Expression
                                    $$->type = "bool";                                          // Set the type of the Expression to bool
                                    $$->trueList = makeList(nextInstruction());                 // Set the trueList of the Expression
                                    $$->falseList = makeList(nextInstruction() + 1);            // Set the falseList of the Expression
                                    emit(">", "", $1->loc->name, $3->loc->name);                // Emit Quad to check if the value of the relational expression is greater than the value of the shit expression, in which case, a goto is performed
                                    emit("goto", "");                                           // Emit Quad to perform a goto if the condition is false
                                }
                                else {
                                    yyerror("Incompatible types");                              // Throw an error if the types are incompatible
                                }
                            }
                        | relational_expression LESS_EQUAL_THAN shift_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                           // Check if the types are compatible
                                    $$ = new Expression();                                  // Create a new Expression
                                    $$->type = "bool";                                      // Set the type of the Expression to bool
                                    $$->trueList = makeList(nextInstruction());             // Set the trueList of the Expression
                                    $$->falseList = makeList(nextInstruction() + 1);        // Set the falseList of the Expression
                                    emit("<=", "", $1->loc->name, $3->loc->name);           // Emit Quad to check if the value of the relational expression is less than or equal to the value of the shit expression, in which case, a goto is performed
                                    emit("goto", "");                                       // Emit Quad to perform a goto if the condition is false
                                }
                                else {
                                    yyerror("Incompatible types");                          // Throw an error if the types are incompatible
                                }
                            }
                        | relational_expression GREATER_EQUAL_THAN shift_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                           // Check if the types are compatible
                                    $$ = new Expression();                                  // Create a new Expression
                                    $$->type = "bool";                                      // Set the type of the Expression to bool
                                    $$->trueList = makeList(nextInstruction());             // Set the trueList of the Expression
                                    $$->falseList = makeList(nextInstruction() + 1);        // Set the falseList of the Expression
                                    emit(">=", "", $1->loc->name, $3->loc->name);           // Emit Quad to check if the value of the relational expression is greater than or equal to the value of the shit expression, in which case, a goto is performed
                                    emit("goto", "");                                       // Emit Quad to perform a goto if the condition is false
                                }
                                else {
                                    yyerror("Incompatible types");                          // Throw an error if the types are incompatible
                                }
                            }
                        ;

equality_expression:
                    relational_expression
                        { 
                            $$ = $1;
                        }
                    | equality_expression EQUALS relational_expression
                        { 
                            if(typecheck($1->loc, $3->loc)) {                               // Check if the types are compatible
                                intMaker($1);                                               // Convert the type of the Expression to int
                                intMaker($3);                                               // Convert the type of the Expression to int
                                $$ = new Expression();                                      // Create a new Expression
                                $$->type = "bool";                                          // Set the type of the Expression to bool
                                $$->trueList = makeList(nextInstruction());                 // Set the trueList of the Expression
                                $$->falseList = makeList(nextInstruction() + 1);            // Set the falseList of the Expression
                                emit("==", "", $1->loc->name, $3->loc->name);               // Emit Quad to check if the value of the equality expression is equal to the value of the relational expression, in which case, a goto is performed
                                emit("goto", "");                                           // Emit Quad to perform a goto if the condition is false
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    | equality_expression NOT_EQUALS relational_expression
                        { 
                            if(typecheck($1->loc, $3->loc)) {                   
                                intMaker($1);                                               // Convert the type of the Expression to int
                                intMaker($3);                                               // Convert the type of the Expression to int
                                $$ = new Expression();                                      // Create a new Expression
                                $$->type = "bool";                                          // Set the type of the Expression to bool
                                $$->trueList = makeList(nextInstruction());                 // Set the trueList of the Expression
                                $$->falseList = makeList(nextInstruction() + 1);            // Set the falseList of the Expression
                                emit("!=", "", $1->loc->name, $3->loc->name);               // Emit Quad to check if the value of the equality expression is not equal to the value of the relational expression, in which case, a goto is performed
                                emit("goto", "");                                           // Emit Quad to perform a goto if the condition is false
                            }
                            else {
                                yyerror("Incompatible types");
                            }
                        }
                    ;

AND_expression:
                equality_expression
                    { 
                        $$ = $1;
                    }
                | AND_expression BITWISE_AND equality_expression
                    { 
                        if(typecheck($1->loc, $3->loc)) {                               // Check if the types are compatible
                            intMaker($1);                                               // Convert the type of the Expression to int
                            intMaker($3);                                               // Convert the type of the Expression to int
                            $$ = new Expression();                                      // Create a new Expression
                            $$->type = "not_bool";                                          // Set the type of the Expression to not_bool
                            $$->loc = SymbolTable::genTemp(new TType("int"));          // Generate a temporary symbol
                            emit("&", $$->loc->name, $1->loc->name, $3->loc->name);         // Emit Quad to perform a bitwise AND operation on the two values
                        }
                        else {
                            yyerror("Incompatible types");
                        }
                    }
                ;

exclusive_OR_expression:
                        AND_expression
                            { 
                                $$ = $1;
                            }
                        | exclusive_OR_expression BITWISE_XOR AND_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                                           // Check if the types are compatible          
                                    intMaker($1);                                                       // Convert the type of the Expression to int
                                    intMaker($3);                                                       // Convert the type of the Expression to int
                                    $$ = new Expression();                                                          // Create a new Expression                  
                                    $$->type = "not_bool";                                              // Set the type of the Expression to not_bool
                                    $$->loc = SymbolTable::genTemp(new TType("int"));                  // Generate a temporary symbol
                                    emit("^", $$->loc->name, $1->loc->name, $3->loc->name);                 // Emit Quad to perform a bitwise XOR operation on the two values
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

inclusive_OR_expression:
                        exclusive_OR_expression
                            { 
                                $$ = $1;
                            }
                        | inclusive_OR_expression BITWISE_OR exclusive_OR_expression
                            { 
                                if(typecheck($1->loc, $3->loc)) {                               
                                    intMaker($1);                                      
                                    intMaker($3);
                                    $$ = new Expression();
                                    $$->type = "not_bool";                                          // Set the type of the Expression to not_bool
                                    $$->loc = SymbolTable::genTemp(new TType("int"));          // Generate a temporary symbol
                                    emit("|", $$->loc->name, $1->loc->name, $3->loc->name);         // Emit Quad to perform a bitwise OR operation on the two values
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;


M:              // This is used to handle backpatching, which is used to handle control flow
        {
            $$ = nextInstruction();                 // Get the next instruction
        }   
    ;

N:      // Helps in Control Flo
        {
            $$ = new Statement();                               // Create a new Statement
            $$->nextList = makeList(nextInstruction());         // Set the nextList of the Statement
            emit("goto", "");                                   // Emit Quad to perform a goto
        }
	;

logical_AND_expression:             
                        inclusive_OR_expression
                            { 
                                $$ = $1;
                            }
                        | logical_AND_expression LOGICAL_AND M inclusive_OR_expression
                            { 
                                if(typecheck($1->loc, $4->loc)) {                       // Check if the types are compatible                       
                                    intMaker($1);
                                    intMaker($4);
                                    $$ = new Expression();                                      // Create a new Expression
                                    $$->type = "bool";                                          // Set the type of the Expression to bool
                                    backpatch($1->trueList, $3);                                // Backpatch the trueList of the Expression
                                    $$->trueList = $4->trueList;                                // Set the trueList of the Expression
                                    $$->falseList = merge($1->falseList, $4->falseList);        // Set the falseList of the Expression       
                                }
                                else {
                                    yyerror("Incompatible types");
                                }
                            }
                        ;

logical_OR_expression:
                        logical_AND_expression
                            { 
                                $$ = $1;
                            }
                        | logical_OR_expression LOGICAL_OR M logical_AND_expression
                            { 
                                if(typecheck($1->loc, $4->loc)) {                               
                                    intMaker($1);                                      
                                    intMaker($4);
                                    $$ = new Expression();                                  // Create a new Expression
                                    $$->type = "bool";                                      // Set the type of the Expression to bool
                                    backpatch($1->falseList, $3);                           // Backpatch the falseList of the Expression
                                    $$->trueList = merge($1->trueList, $4->trueList);       // Set the trueList of the Expression
                                    $$->falseList = $4->falseList;                          // Set the falseList of the Expression
                                }
                                else {
                                    yyerror("Incompatible types");                      
                                }
                            }
                        ;

conditional_expression:
                        logical_OR_expression
                            { 
                                $$ = $1;
                            }
                        | logical_OR_expression N QUESTION_MARK M expression N COLON M conditional_expression   
                            { 
                                $$->loc = SymbolTable::genTemp($5->loc->type);          // Generate a temporary symbol
                                $$->loc->update($5->loc->type);                         // Update the type of the temporary symbol
                                backpatch($1->trueList, $4);                            // Backpatch the trueList of the Expression
                                backpatch($1->falseList, $8);                           // Backpatch the falseList of the Expression
                                emit("=", $$->loc->name, $9->loc->name);                // Assign the value of the conditional expression to the temporary symbol
                                std::list<int> l1 = makeList(nextInstruction());             // Create a new list
                                emit("goto", "");                                       // Emit Quad to perform a goto
                                backpatch($6->nextList, nextInstruction());             // Backpatch the nextList of the Expression
                                emit("=", $$->loc->name, $5->loc->name);                // Assign the value of the expression to the temporary symbol
                                std::list<int> l2 = makeList(nextInstruction());             // Create a new list
                                l1 = merge(l1, l2);                                     // Merge the two lists
                                emit("goto", "");                                       // Emit Quad to perform a goto
                                backpatch($2->nextList, nextInstruction());             // Backpatch the nextList of N
                                boolMaker($1);                                           // Convert the type of the Expression to bool
                                backpatch(l1, nextInstruction());                       // Backpatch the list. The list l1 ensures that after either of the assignments, the control flow is transferred to the next instruction
                            }
                        ;

assignment_expression:
                        conditional_expression
                            { 
                                $$ = $1;
                            }
                        | unary_expression assignment_operator assignment_expression
                            { 
                                if($1->atype == "arr") {                                                // If the Array is of type array
                                    $3->loc = convertType($3->loc, $1->type->type);                     // Convert the type of the Array
                                    emit("[]=", $1->Array->name, $1->loc->name, $3->loc->name);         // Emit Quad to copy the value of the Array to the location
                                }   
                                else if($1->atype == "ptr") {                               // If the Array is of type pointer
                                    emit("*=", $1->Array->name, $3->loc->name);             // Emit Quad to copy the value of the Array to the location
                                }
                                else {                                                              // If the Array is of type int
                                    $3->loc = convertType($3->loc, $1->Array->type->type);          // Convert the type of the Array
                                    emit("=", $1->Array->name, $3->loc->name);                      // Emit Quad to copy the value of the Array to the location
                                }
                                $$ = $3;
                            }
                        ;

assignment_operator:
                    ASSIGNMENT
                        { 
                        }
                    | ASTERISK_ASSIGNMENT
                        { 
                        }
                    | SLASH_ASSIGNMENT
                        { 
                        }
                    | MODULO_ASSIGNMENT
                        { 
                        }
                    | PLUS_ASSIGNMENT
                        { 
                        }
                    | MINUS_ASSIGNMENT
                        { 
                        }
                    | LEFT_SHIFT_ASSIGNMENT
                        { 
                        }
                    | RIGHT_SHIFT_ASSIGNMENT
                        { 
                        }
                    | BITWISE_AND_ASSIGNMENT
                        { 
                        }
                    | BITWISE_XOR_ASSIGNMENT
                        { 
                        }
                    | BITWISE_OR_ASSIGNMENT
                        { 
                        }
                    ;

expression:
            assignment_expression
                { 
                    $$ = $1;
                }
            | expression COMMA assignment_expression
                {
                }
            ;

constant_expression:
                    conditional_expression
                        {
                        }
                    ;

/* Declarations */

declaration:
            declaration_specifiers init_declarator_list_opt SEMI_COLON
                {
                }
            ;

init_declarator_list_opt:
                            init_declarator_list
                                {
                                }
                            |
                                {
                                }
                            ;

declaration_specifiers:
                        storage_class_specifier declaration_specifiers_opt
                            {
                            }
                        | type_specifier declaration_specifiers_opt
                            {
                            }
                        | type_qualifier declaration_specifiers_opt
                            {
                            }
                        | function_specifier declaration_specifiers_opt
                            {
                            }
                        ;

declaration_specifiers_opt:
                            declaration_specifiers
                                {
                                }
                            |
                                {
                                }
                            ;

init_declarator_list:
                        init_declarator
                            {
                            }
                        | init_declarator_list COMMA init_declarator
                            {
                            }
                        ;

init_declarator:
                declarator
                    { 
                        $$ = $1;
                    }
                | declarator ASSIGNMENT initialiser
                    { 
                        if($3->value != "") {                           // If the value of the initialiser is not empty
                            $1->value = $3->value;                      // Set the value of the declarator to the value of the initialiser
                        }
                        emit("=", $1->name, $3->name);                  // Emit Quad to assign the value of the initialiser to the declarator
                    }
                ;

storage_class_specifier:
                        EXTERN
                            {
                            }
                        | STATIC
                            {
                            }
                        | AUTO
                            {
                            }
                        | REGISTER
                            {
                            }
                        ;

type_specifier:
                VOIDTYPE
                    { 
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        globalContext.varType = "void";                   // Set the type of the variable to void
                    }
                | CHARTYPE
                    { 
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        globalContext.varType = "char";                   // Set the type of the variable to char
                    }
                | SHORT
                    {
                    }
                | INTTYPE
                    { 
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        globalContext.varType = "int";                    // Set the type of the variable to int
                    }
                | LONG
                    {
                    }
                | FLOATTYPE
                    { 
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        globalContext.varType = "float";                  // Set the type of the variable to float
                    }
                | DOUBLE
                    {
                    }
                | SIGNED
                    {
                    }
                | UNSIGNED
                    {
                    }
                | _BOOL
                    {
                    }
                | _COMPLEX
                    {
                    }
                | _IMAGINARY
                    {
                    }
                | enum_specifier 
                    {
                    }
                ;

specifier_qualifier_list:
                            type_specifier specifier_qualifier_list_opt
                                { 
                                }
                            | type_qualifier specifier_qualifier_list_opt
                                { 
                                }
                            ;

specifier_qualifier_list_opt:
                                specifier_qualifier_list
                                    { 
                                    }
                                | 
                                    { 
                                    }
                                ;

enum_specifier:
                ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list RIGHT_CURLY_BRACKET 
                    { 
                    }
                | ENUM identifier_opt LEFT_CURLY_BRACKET enumerator_list COMMA RIGHT_CURLY_BRACKET
                    { 
                    }
                | ENUM IDENTIFIER
                    { 
                    }
                ;

identifier_opt:
                IDENTIFIER 
                    { 
                    }
                | 
                    { 
                    }
                ;

enumerator_list:
                enumerator 
                    { 
                    }
                | enumerator_list COMMA enumerator
                    { 
                    }
                ;

enumerator:
            IDENTIFIER 
                { 
                }
            | IDENTIFIER ASSIGNMENT constant_expression
                { 
                }
            ;

type_qualifier:
                CONST
                    { 
                    }
                | RESTRICT
                    { 
                    }
                | VOLATILE
                    { 
                    }
                ;

function_specifier:
                    INLINE
                        { 
                        }
                    ;

/*

Declarations

*/
declarator:
            pointer direct_declarator
                { 
                    TType* temp = $1;                          // Create a temporary TType
                    while(temp->arrType != NULL) {                  // For multi-dimensional arrays, traverse down the array till reching the base type
                        temp = temp->arrType;                       
                    }
                    temp->arrType = $2->type;                   // Set the type of the array to the type of the direct_declarator
                    $$ = $2->update($1);                        // Update the direct_declarator
                }
            | direct_declarator
                { 
                }
            ;

direct_declarator:
                    IDENTIFIER 
                        { 
                            GlobalContext &globalContext = GlobalContext::getInstance();
                            $$ = $1->update(new TType(globalContext.varType));               // Update the SymbolTable entry of the IDENTIFIER
                            globalContext.currentSymbol = $$;                                     // Set the globalContext.currentSymbol to the IDENTIFIER
                        }
                    | LEFT_PARENTHESES declarator RIGHT_PARENTHESES
                        { 
                            $$ = $2;
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                            TType* cur_type = $1->type;                                        // Get the type of the direct_declarator
                            TType* prev = NULL;                                                // Create a temporary TType prev
                            while (cur_type->type == "arr") {                                       //Get Base Type
                                prev = cur_type;
                                cur_type = cur_type->arrType;
                            }
                            if (prev == NULL) {                                                 // If the direct_declarator is not an array
                                int temp = atoi($3->loc->value.c_str());                        // Convert the value of the assignment_expression to an integer
                                TType* tp = new TType("arr", $1->type, temp);         // Create a new TType
                                $$ = $1->update(tp);                                            // Update the direct_declarator
                            }
                            else {                                                              // If the direct_declarator is an array
                                int temp = atoi($3->loc->value.c_str());                        // Convert the value of the assignment_expression to an integer
                                prev->arrType = new TType("arr", cur_type, temp);          // Create a new TType
                                $$ = $1->update($1->type);                                      // Update the direct_declarator
                            }
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET RIGHT_SQUARE_BRACKET
                        { 
                            TType* cur_type = $1->type;                                    // Same as above, but for no given size
                            TType* prev = NULL;                                                    
                            while(cur_type->type == "arr") {
                                prev = cur_type;
                                cur_type = cur_type->arrType;
                            }
                            if(prev == NULL) {
                                TType* tp = new TType("arr", $1->type, 0);
                                $$ = $1->update(tp);
                            }
                            else {
                                prev->arrType = new TType("arr", cur_type, 0);
                                $$ = $1->update($1->type);
                            }
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET STATIC type_qualifier_list assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET STATIC assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list STATIC assignment_expression RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET type_qualifier_list ASTERISK RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_SQUARE_BRACKET ASTERISK RIGHT_SQUARE_BRACKET
                        { 
                        }
                    | direct_declarator LEFT_PARENTHESES change_table parameter_type_list RIGHT_PARENTHESES
                        { 
                            GlobalContext &globalContext = GlobalContext::getInstance();
                            globalContext.currentST->name = $1->name;                             // Set the name of the SymbolTable to the name of the direct_declarator
                            if($1->type->type != "void") {                          // If the type of the direct_declarator is not void
                                Term* s = globalContext.currentST->lookup("return");            // Lookup the SymbolTable for the return type
                                s->update($1->type);                                // Update the return type
                            }
                            $1->nestedTable = globalContext.currentST;                            // Set the nestedTable of the direct_declarator to the current SymbolTable
                            globalContext.currentST->parent = globalContext.globalST;                           // Set the parent of the current SymbolTable to the global SymbolTable
                            changeTable(globalContext.globalST);                                  // Change the current SymbolTable to the global SymbolTable
                            globalContext.currentSymbol = $$;                                     // Set the globalContext.currentSymbol to the direct_declarator
                        }
                    | direct_declarator LEFT_PARENTHESES identifier_list RIGHT_PARENTHESES
                        { 
                        }
                    | direct_declarator LEFT_PARENTHESES change_table RIGHT_PARENTHESES
                        { 
                            GlobalContext &globalContext = GlobalContext::getInstance();
                            globalContext.currentST->name = $1->name;                         //Same as above, but for no parameters
                            if($1->type->type != "void") {
                                Term* s = globalContext.currentST->lookup("return");   
                                s->update($1->type);
                            }
                            $1->nestedTable = globalContext.currentST;
                            globalContext.currentST->parent = globalContext.globalST;  
                            changeTable(globalContext.globalST);        
                            globalContext.currentSymbol = $$; 
                        }
                    ;

type_qualifier_list_opt:
                        type_qualifier_list
                            { 
                            }
                        |
                            { 
                            }
                        ;

pointer:
        ASTERISK type_qualifier_list_opt
            { 
                $$ = new TType("ptr");                                 
            }
        | ASTERISK type_qualifier_list_opt pointer
            { 
                $$ = new TType("ptr", $3);
            }
        ;

type_qualifier_list:
                    type_qualifier
                        { 
                        }
                    | type_qualifier_list type_qualifier
                        { 
                        }
                    ;

parameter_type_list:
                    parameter_list
                        { 
                        }
                    | parameter_list COMMA ELLIPSIS
                        { 
                        }
                    ;

parameter_list:
                parameter_declaration
                    { 
                    }
                | parameter_list COMMA parameter_declaration
                    { 
                    }
                ;

parameter_declaration:
                        declaration_specifiers declarator
                            { 
                            }
                        | declaration_specifiers
                            { 
                            }
                        ;

identifier_list:
                IDENTIFIER 
                    { 
                    }
                | identifier_list COMMA IDENTIFIER
                    { 
                    }
                ;

type_name:
            specifier_qualifier_list
                { 
                }
            ;

initialiser:
            assignment_expression
                { 
                    $$ = $1->loc;
                }
            | LEFT_CURLY_BRACKET initialiser_list RIGHT_CURLY_BRACKET
                { 
                }  
            | LEFT_CURLY_BRACKET initialiser_list COMMA RIGHT_CURLY_BRACKET
                { 
                }
            ;

initialiser_list:
                    designation_opt initialiser
                        { 
                        }
                    | initialiser_list COMMA designation_opt initialiser
                        { 
                        }
                    ;

designation_opt:
                designation
                    { 
                    }
                |
                    { 
                    }
                ;

designation:
            designator_list ASSIGNMENT
                { 
                }
            ;

designator_list:
                designator
                    { 
                    }
                | designator_list designator
                    { 
                    }
                ;

designator:
            LEFT_SQUARE_BRACKET constant_expression RIGHT_SQUARE_BRACKET
                { 
                }
            | DOT IDENTIFIER
                { 
                }   
            ;

/* Statements */

statement:
            labeled_statement
                { 
                }
            | compound_statement
                { 
                    $$ = $1; 
                }
            | expression_statement
                { 
                    $$ = new Statement();
                    $$->nextList = $1->nextList;
                }
            | selection_statement
                { 
                    $$ = $1;
                }
            | iteration_statement
                { 
                    $$ = $1;
                }
            | jump_statement
                { 
                    $$ = $1;
                }
            ;

labeled_statement:
                    IDENTIFIER COLON statement
                        { 
                        }
                    | CASE constant_expression COLON statement
                        { 
                        }    
                    | DEFAULT COLON statement
                        { 
                        }
                    ;

loop_statement:         //Identical to statement, but for loops, is useful to prevent Shift Reduce Conflicts
                labeled_statement
                { 
                }
                | expression_statement
                {
                    $$ = new Statement();           
                    $$->nextList = $1->nextList;    
                }
                | selection_statement
                {
                    $$ = $1;    
                }
                | iteration_statement
                {
                    $$ = $1;    
                }
                | jump_statement
                {
                    $$ = $1;
                }
                ;

change_table:
                {   
                    GlobalContext &globalContext = GlobalContext::getInstance();
                    if(globalContext.currentSymbol->nestedTable != NULL) {                // If the globalContext.currentSymbol has a nested SymbolTable
                        changeTable(globalContext.currentSymbol->nestedTable);            // Change the current SymbolTable to the nested SymbolTable
                        emit("label", globalContext.currentST->name);                     // Emit Quad to create a label for the nested SymbolTable
                    }
                    else {
                        changeTable(new SymbolTable(""));                   // Else, create a new SymbolTable
                    }
                }
                ;

compound_statement:
                    LEFT_CURLY_BRACKET D change_table block_item_list_opt RIGHT_CURLY_BRACKET
                        { 
                            GlobalContext &globalContext = GlobalContext::getInstance();
                            $$ = $4;
                            changeTable(globalContext.currentST->parent);         // Change the current SymbolTable to the parent SymbolTable
                        }
                    ;

block_item_list_opt:
                    block_item_list
                        { 
                            $$ = $1;
                        }
                    |
                        { 
                            $$ = new Statement();
                        }
                    ;

block_item_list:
                block_item
                    {
                        $$ = $1;
                    }
                | block_item_list M block_item
                    { 
                        $$ = $3;
                        backpatch($1->nextList, $2);        // Backpatch the nextList of the block_item_list to the M
                    }
                ;

block_item:
            declaration
                { 
                    $$ = new Statement();
                }
            | statement
                { 
                    $$ = $1;
                }
            ;

expression_statement:
                        expression_opt SEMI_COLON
                            { 
                                $$ = $1;
                            }
                        ;

expression_opt:
                expression
                    { 
                        $$ = $1;
                    }
                |
                    { 
                        $$ = new Expression();
                    }
                ;

selection_statement:
                    IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N %prec THEN
                        { 
                            backpatch($4->nextList, nextInstruction());                  // Backpatch the nextList of N with the next instruction
                            boolMaker($3);                                               // Convert the expression to a boolean expression
                            $$ = new Statement();                                       // Create a new Statement
                            backpatch($3->trueList, $6);                                // Backpatch the trueList of the expression with the M
                        
                            std::list<int> temp = merge($3->falseList, $7->nextList);        // Merge the falseList of the expression with the nextList of the statement
                            $$->nextList = merge($8->nextList, temp);                   // Merge the nextList of the N with the nextList of the statement and make it the nextList of the selection_statement
                        }
                    | IF LEFT_PARENTHESES expression N RIGHT_PARENTHESES M statement N ELSE M statement
                        { 
                            backpatch($4->nextList, nextInstruction());                     // Backpatch the nextList of N with the next instruction
                            boolMaker($3);                                                   // Convert the expression to a boolean expression
                            $$ = new Statement();                                               // Create a new Statement
                            backpatch($3->trueList, $6);                                    // Backpatch the trueList of the expression with the M
                            backpatch($3->falseList, $10);                                  // Backpatch the falseList of the expression with the M
                            std::list<int> temp = merge($7->nextList, $8->nextList);             // Merge the nextList of the statement with the nextList of the statement
                            $$->nextList = merge($11->nextList, temp);                      // Merge the nextList of the N with the nextList of the statement and make it the nextList of the selection_statement
                        }
                    | SWITCH LEFT_PARENTHESES expression RIGHT_PARENTHESES statement
                        { 
                        }
                    ;

iteration_statement:
                    WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES M loop_statement
                    {   
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                       // Create a new Statement
                        boolMaker($7);                               // Convert the expression to a boolean expression
                        backpatch($10->nextList, $6);               // Backpatch the nextList of the loop_statement with the M
                        backpatch($7->trueList, $9);                // Backpatch the trueList of the expression with the M
                        $$->nextList = $7->falseList;               // Make the falseList of the expression the nextList of the iteration_statement
                        emit("goto", std::to_string($6));               // Emit Quad to goto the M
                        globalContext.blockName = "";                             // Reset the globalContext.blockName
                        changeTable(globalContext.currentST->parent);             // Change the current SymbolTable to the parent SymbolTable
                    }
                    | WHILE W LEFT_PARENTHESES X change_table M expression RIGHT_PARENTHESES LEFT_CURLY_BRACKET M block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                 
                        boolMaker($7);                 
                        backpatch($11->nextList, $6);         
                        backpatch($7->trueList, $10);          
                        $$->nextList = $7->falseList;         
                        emit("goto", std::to_string($6));  
                        globalContext.blockName = "";
                        changeTable(globalContext.currentST->parent);
                    }
                    | DO D M loop_statement M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                       // Create a new Statement
                        boolMaker($8);                               // Convert the expression to a boolean expression
                        backpatch($8->trueList, $3);                // Backpatch the trueList of the expression with the M
                        backpatch($4->nextList, $5);                // Backpatch the nextList of the loop_statement with the M
                        $$->nextList = $8->falseList;               // Make the falseList of the expression the nextList of the iteration_statement
                        globalContext.blockName = "";                             // Reset the globalContext.blockName
                    }
                    | DO D LEFT_CURLY_BRACKET M block_item_list_opt RIGHT_CURLY_BRACKET M WHILE LEFT_PARENTHESES expression RIGHT_PARENTHESES SEMI_COLON
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                  
                        boolMaker($10);                 
                        backpatch($10->trueList, $4);          
                        backpatch($5->nextList, $7);           
                        $$->nextList = $10->falseList;         
                        globalContext.blockName = "";
                    }
                    | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                       // Create a new Statement
                        boolMaker($8);                               // Convert the expression to a boolean expression
                        backpatch($8->trueList, $13);               // Backpatch the trueList of the expression with the M3
                        backpatch($11->nextList, $7);               // Backpatch the nextList of the N with the M1
                        backpatch($14->nextList, $9);               // Backpatch the nextList of the loop_statement with the M2
                        emit("goto", std::to_string($9));               // Emit Quad to goto the M2
                        $$->nextList = $8->falseList;               // Make the falseList of the expression the nextList of the iteration_statement
                        globalContext.blockName = "";                             // Reset the globalContext.blockName
                        changeTable(globalContext.currentST->parent);             // Change the current SymbolTable to the parent SymbolTable
                    }
                    | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M loop_statement
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                
                        boolMaker($8);                  
                        backpatch($8->trueList, $13);        
                        backpatch($11->nextList, $7);          
                        backpatch($14->nextList, $9);          
                        emit("goto", std::to_string($9));   
                        $$->nextList = $8->falseList;          
                        globalContext.blockName = "";
                        changeTable(globalContext.currentST->parent);
                    }
                    | FOR F LEFT_PARENTHESES X change_table declaration M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                  
                        boolMaker($8);                   
                        backpatch($8->trueList, $13);        
                        backpatch($11->nextList, $7);        
                        backpatch($15->nextList, $9);         
                        emit("goto", std::to_string($9));   
                        $$->nextList = $8->falseList;        
                        globalContext.blockName = "";
                        changeTable(globalContext.currentST->parent);
                    }
                    | FOR F LEFT_PARENTHESES X change_table expression_statement M expression_statement M expression N RIGHT_PARENTHESES M LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                    {
                        GlobalContext &globalContext = GlobalContext::getInstance();
                        $$ = new Statement();                  
                        boolMaker($8);                   
                        backpatch($8->trueList, $13);         
                        backpatch($11->nextList, $7);          
                        backpatch($15->nextList, $9);          
                        emit("goto", std::to_string($9));  
                        $$->nextList = $8->falseList;         
                        globalContext.blockName = "";
                        changeTable(globalContext.currentST->parent);
                    }
                    ;

jump_statement:
                GOTO IDENTIFIER SEMI_COLON
                    { 
                    }    
                | CONTINUE SEMI_COLON
                    { 
                        $$ = new Statement();
                    }
                | BREAK SEMI_COLON
                    { 
                        $$ = new Statement();
                    }
                | RETURN expression SEMI_COLON
                    { 
                        $$ = new Statement();               // Create a new Statement
                        emit("return", $2->loc->name);      // Emit Quad to return the expression
                    }
                | RETURN SEMI_COLON
                    { 
                        $$ = new Statement();
                        emit("return", ""); 
                    }
                ;

F:                  //Useful for Block names
        {
            GlobalContext &globalContext = GlobalContext::getInstance();
            
            globalContext.blockName = "FOR";
        }
        ;

W:              //Useful for Block names
        {
           
            GlobalContext &globalContext = GlobalContext::getInstance();
            globalContext.blockName = "WHILE";
        }
        ;

D:              //Useful for Block names
        {
           
            GlobalContext &globalContext = GlobalContext::getInstance();
            globalContext.blockName = "DO_WHILE";
        }
        ;

X:              //Needed to create new symbol tables after curly brackets
        {
            GlobalContext &globalContext = GlobalContext::getInstance();
           
            std::string newST = globalContext.currentST->name + "#" + globalContext.blockName + "#" + std::to_string(globalContext.STCount++);  
            Term* temp_symbol = globalContext.currentST->lookup(newST);
            temp_symbol->nestedTable = new SymbolTable(newST); 
            temp_symbol->name = newST;
            temp_symbol->nestedTable->parent = globalContext.currentST;
            temp_symbol->type = new TType("block");   
            globalContext.currentSymbol = temp_symbol; 
        }
        ;

translation_unit:
                    external_declaration
                        { 
                        }
                    | translation_unit external_declaration
                        { 
                        }
                    ;

external_declaration:
                        function_definition
                            { 
                            }
                        | declaration
                            { 
                            }
                        ;

function_definition: // to prevent block change here which is there in the compound statement grammar rule
                     // this rule is slightly modified by expanding the original compound statement rule over here
                    declaration_specifiers declarator declaration_list_opt change_table LEFT_CURLY_BRACKET block_item_list_opt RIGHT_CURLY_BRACKET
                        { 
                            GlobalContext &globalContext = GlobalContext::getInstance();
                            globalContext.currentST->parent = globalContext.globalST;
                            globalContext.STCount = 0;
                            changeTable(globalContext.globalST); 
                        }
                    ;

declaration_list_opt:
                        declaration_list
                            { 
                            }
                        |
                            { 
                            }
                        ;

declaration_list:
                    declaration
                        { 
                        }
                    | declaration_list declaration
                        { 
                        }
                    ;

%%

void yyerror(std::string s) {
    printf("ERROR [Line %d] : %s\n", yylineno, s.c_str());
}
