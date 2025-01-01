%{
    #include "tinyc2_22CS30039_22CS30050.tab.h"
%}

comm_content [^*]|[*][^/]
comm_multi "/*"{comm_content}*"*/"
comm_single "//"[^\n]*\n


alpha [a-zA-Z_]
digit [0-9]
identifier {alpha}({alpha}|{digit})*
non_zero_digit [1-9]
const_int 0|{non_zero_digit}{digit}*
dig_seq {digit}+
exp [eE][+-]?{dig_seq}
const_dec {dig_seq}?\.{dig_seq}|{dig_seq}\.
const_flt {const_dec}{exp}?|{dig_seq}{exp}
escape_seq \\[abfnrtv'"\?\\]
c_char [^'\\\n]|{escape_seq}
c_char_seq {c_char}+
const_char \'{c_char_seq}\'

s_char [^"\\\n]|{escape_seq}
s_char_seq {s_char}+
str_lit \"{s_char_seq}?\"

space	[ \t\n]
spaces	{space}+

%%

{spaces}	{ }
"auto"  { return(AUTO); }
"break" { return(BREAK); }
"case"  { return(CASE); }
"char"  { return(CHAR); }
"const" { return(CONST); }
"continue" { return(CONTINUE); }
"default" { return(DEFAULT); }
"do"    { return(DO); }
"double" { return(DOUBLE); }
"else"  { return(ELSE); }
"extern" { return(EXTERN); }
"float" {return(FLOAT); }
"for"   { return(FOR); }
"goto"  { return(GOTO); }
"if"    { return(IF); }
"inline" { return(INLINE); }
"int"   { return(INT); }
"long"  { return(LONG); }
"register" { return(REGISTER); }
"restrict" { return(RESTRICT); }
"return" { return(RETURN); }
"short" { return(SHORT); }
"signed" { return(SIGNED); }
"sizeof" { return(SIZEOF); }
"static" { return(STATIC); }
"switch" { return(SWITCH); }
"unsigned" { return(UNSIGNED); }
"void"  { return(VOID); }
"volatile" { return(VOLATILE); }
"while" { return(WHILE); }
"_Bool" { return(BOOL); }
"_Complex" { return(COMPLEX); }
"_Imaginary" { return(IMAGINARY); }
"["     { return(LBRACKET); }
"]"     { return(RBRACKET); }
"("     { return(LPAREN); }
")"     { return(RPAREN); }
"{"     { return(LBRACE); }
"}"     { return(RBRACE); }
"."     { return(DOT); }
"->"    { return(ARROW); }
"++"    { return(INC); }
"--"    { return(DEC); }
"&"     { return(AMP); }
"*"     { return(AST); }
"+"     { return(PLUS); }
"-"     { return(MINUS); }
"~"     { return(TILDE); }
"!"     { return(NOT); }
"/"     { return(DIV); }
"%"     { return(MOD); }
"<<"    { return(LSHIFT); }
">>"    { return(RSHIFT); }
"<"     { return(LT); }
">"     { return(GT); }
"<="    { return(LTE); }
">="    { return(GTE); }
"=="    { return(EQ); }
"!="    { return(NE); }
"^"     { return(XOR); }
"|"     { return(OR); }
"&&"    { return(AND); }
"||"    { return(OROR); }
"?"     { return(QUEST); }
":"     { return(COLON); }
";"     { return(SEMICOLON); }
"..."   { return(ELLIPSIS); }
"="     { return(ASSIGN); }
"*="    { return(MUL_ASSIGN); }
"/="    { return(DIV_ASSIGN); }
"%="    { return(MOD_ASSIGN); }
"+="    { return(ADD_ASSIGN); }
"-="    { return(SUB_ASSIGN); }
"<<="   { return(LSHIFT_ASSIGN); }
">>="   { return(RSHIFT_ASSIGN); }
"&="    { return(AND_ASSIGN); }
"^="    { return(XOR_ASSIGN); }
"|="    { return(OR_ASSIGN); }
","     { return(COMMA); }
{identifier}	{yylval.sval = strdup(yytext); return(IDENTIFIER); }
{const_int}	{yylval.ival = atoi(yytext); return(CONST_INT); }
{const_flt}	{yylval.fval = atof(yytext); return(CONST_FLT); }
{const_char} { yylval.cval = yytext[1]; return(CONST_CHAR); }
{str_lit}	{yylval.sval = strdup(yytext); return(STR_LIT); }
{comm_single}	{ }
{comm_multi}	{ }

%%

int yywrap(void) {
    return 1;
}