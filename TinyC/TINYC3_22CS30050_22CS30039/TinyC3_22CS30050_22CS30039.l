%{
    #include <stdio.h>
    #include <stdlib.h>
    #include "TinyC3_22CS30050_22CS30039_translator.h"
    #include "y.tab.h"
%}

%option yylineno
%option noyywrap

%x IN_SINGLELINE_COMMENT
%x IN_MULTILINE_COMMENT

ESCAPE_SEQUENCE         "\\\'"|"\\\""|"\\?"|"\\\\"|"\\a"|"\\b"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"

IDENTIFIER              [A-Za-z_][A-Za-z0-9_]*

DIGIT                   [0-9]
DIGIT_SEQUENCE          {DIGIT}+
NONZERO_DIGIT           [1-9]
INTEGER_CONSTANT        {NONZERO_DIGIT}{DIGIT}*|"0"

EXPONENT_PART           [eE]([+-]?){DIGIT_SEQUENCE}
FRACTIONAL_CONSTANT     {DIGIT_SEQUENCE}?\.{DIGIT_SEQUENCE}|{DIGIT_SEQUENCE}\.
FLOATING_CONSTANT       {FRACTIONAL_CONSTANT}({EXPONENT_PART}?)|{DIGIT_SEQUENCE}{EXPONENT_PART}

ENUMERATION_CONSTANT    {IDENTIFIER}

C_CHAR                  [^\'\n\\]|{ESCAPE_SEQUENCE}
C_CHAR_SEQUENCE         {C_CHAR}+
CHARACTER_CONSTANT      \'{C_CHAR_SEQUENCE}\'

S_CHAR                  [^\"\n\\]|{ESCAPE_SEQUENCE}
S_CHAR_SEQUENCE         {S_CHAR}+
STRING_LITERAL          \"({S_CHAR_SEQUENCE}?)\"

WHITESPACE              [ \t]
NEWLINE                 \n

AUTO                   "auto"
BREAK                  "break"
CASE                   "case"
CHAR                   "char"
CONST                  "const"
CONTINUE               "continue"
DEFAULT                "default"
DO                     "do"
DOUBLE                 "double"
ELSE                   "else"
ENUM                   "enum"
EXTERN                 "extern"
FLOAT                  "float"
FOR                    "for"
GOTO                   "goto"
IF                     "if"
INLINE                 "inline"
INT                    "int"
LONG                   "long"
REGISTER               "register"
RESTRICT               "restrict"
RETURN                 "return"
SHORT                  "short"
SIGNED                 "signed"
SIZEOF                 "sizeof"
STATIC                 "static"
STRUCT                 "struct"
SWITCH                 "switch"
TYPEDEF                "typedef"
UNION                  "union"
UNSIGNED               "unsigned"
VOID                   "void"
VOLATILE               "volatile"
WHILE                  "while"
BOOL                   "_Bool"
COMPLEX                "_Complex"
IMAGINARY              "_Imaginary"

%%

"/*"                    {BEGIN(IN_MULTILINE_COMMENT);}
<IN_MULTILINE_COMMENT>{
    "\n"                {/*printf("\nParsing Line Number: %d \n", yylineno);*/}
    "*/"                {BEGIN(INITIAL);}
    .                   {}
}

"//"                    {BEGIN(IN_SINGLELINE_COMMENT);}
<IN_SINGLELINE_COMMENT>{
    "\n"                {/*printf("\nParsing Line Number: %d \n", yylineno);*/ BEGIN(INITIAL);}
    <<EOF>>             {BEGIN(INITIAL);}
    .                   {}
}

{AUTO}                  {return AUTO;}
{BREAK}                 {return BREAK;}
{CASE}                  {return CASE;}
{CHAR}                  {return CHARTYPE;}
{CONST}                 {return CONST;}
{CONTINUE}              {return CONTINUE;}
{DEFAULT}               {return DEFAULT;}
{DO}                    {return DO;}
{DOUBLE}                {return DOUBLE;}
{ELSE}                  {return ELSE;}
{ENUM}                  {return ENUM;}
{EXTERN}                {return EXTERN;}
{FLOAT}                 {return FLOATTYPE;}
{FOR}                   {return FOR;}
{GOTO}                  {return GOTO;}
{IF}                    {return IF;}
{INLINE}                {return INLINE;}
{INT}                   {return INTTYPE;}
{LONG}                  {return LONG;}
{REGISTER}              {return REGISTER;}
{RESTRICT}              {return RESTRICT;}
{RETURN}                {return RETURN;}
{SHORT}                 {return SHORT;}
{SIGNED}                {return SIGNED;}
{SIZEOF}                {return SIZEOF;}
{STATIC}                {return STATIC;}
{STRUCT}                {return STRUCT;}
{SWITCH}                {return SWITCH;}
{TYPEDEF}               {return TYPEDEF;}
{UNION}                 {return UNION;}
{UNSIGNED}              {return UNSIGNED;}
{VOID}                  {return VOIDTYPE;}
{VOLATILE}              {return VOLATILE;}
{WHILE}                 {return WHILE;}
{BOOL}                  {return _BOOL;}
{COMPLEX}               {return _COMPLEX;}
{IMAGINARY}             {return _IMAGINARY;}


{IDENTIFIER}                    { GlobalContext &globalContext = GlobalContext::getInstance();;yylval.symbol = globalContext.currentST->lookup(yytext); return IDENTIFIER; }
{INTEGER_CONSTANT}              { yylval.intVal = atoi(yytext); return INTEGER_CONSTANT; }
{FLOATING_CONSTANT}             { yylval.floatVal = strdup(yytext); return FLOATING_CONSTANT; }
{CHARACTER_CONSTANT}            { yylval.charVal = strdup(yytext); return CHARACTER_CONSTANT; }
{STRING_LITERAL}                { yylval.stringVal = strdup(yytext); return STRING_LITERAL; }

"["                             { return LEFT_SQUARE_BRACKET; }
"++"                            { return INCREMENT; }
"/"                             { return SLASH; }
"?"                             { return QUESTION_MARK; }
"="                             { return ASSIGNMENT; }
","                             { return COMMA; }
"]"                             { return RIGHT_SQUARE_BRACKET; }
"("                             { return LEFT_PARENTHESES; }
"{"                             { return LEFT_CURLY_BRACKET; }
"}"                             { return RIGHT_CURLY_BRACKET; }
"."                             { return DOT; }
"->"                            { return ARROW; }
"*"                             { return ASTERISK; }
"+"                             { return PLUS; }
"-"                             { return MINUS; }
"~"                             { return TILDE; }
"!"                             { return EXCLAMATION; }
"%"                             { return MODULO; }
"<<"                            { return LEFT_SHIFT; }
">>"                            { return RIGHT_SHIFT; }
"<"                             { return LESS_THAN; }
">"                             { return GREATER_THAN; }
"<="                            { return LESS_EQUAL_THAN; }
">="                            { return GREATER_EQUAL_THAN; }
":"                             { return COLON; }
";"                             { return SEMI_COLON; }
"..."                           { return ELLIPSIS; }
"*="                            { return ASTERISK_ASSIGNMENT; }
"/="                            { return SLASH_ASSIGNMENT; }
"%="                            { return MODULO_ASSIGNMENT; }
"+="                            { return PLUS_ASSIGNMENT; }
"-="                            { return MINUS_ASSIGNMENT; }
"<<="                           { return LEFT_SHIFT_ASSIGNMENT; }
"#"                             { return HASH; }
"--"                            { return DECREMENT; }
")"                             { return RIGHT_PARENTHESES; }
"&"                             { return BITWISE_AND; }
"=="                            { return EQUALS; }
"^"                             { return BITWISE_XOR; }
"|"                             { return BITWISE_OR; }
"&&"                            { return LOGICAL_AND; }
"||"                            { return LOGICAL_OR; }
">>="                           { return RIGHT_SHIFT_ASSIGNMENT; }
"!="                            { return NOT_EQUALS; }
"&="                            { return BITWISE_AND_ASSIGNMENT; }
"|="                            { return BITWISE_OR_ASSIGNMENT; }
"^="                            { return BITWISE_XOR_ASSIGNMENT; }

{WHITESPACE}                    { }
{NEWLINE}                       {}
.                               { printf("ERROR in Line %d : Invalid token %s\n", yylineno, yytext); return INVALID_TOKEN; }

%%