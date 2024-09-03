%{
#define KEYWORD 1
#define IDENTIFIER 2
#define CONST_INT 3
#define CONST_FLT 4
#define CONST_CHAR 5
#define STR_LIT 6
#define PUNCTUATOR 7
#define SL_COMM 8
#define ML_COMM 9

%}
/*comments*/
comm_content [^*]|[*][^/]
comm_multi "/*"{comm_content}*"*/"
comm_single "//"[^\n]*\n

/* keywords */
keyword "auto"|"break"|"case"|"char"|"const"|"continue"|"default"|"do"|"double"|"else"|"enum"|"extern"|"float"|"for"|"goto"|"if"|"inline"|"int"|"long"|"register"|"return"|"short"|"signed"|"sizeof"|"static"|"struct"|"switch"|"typedef"|"union"|"unsigned"|"void"|"volatile"|"_Bool"|"_Complex"|"_Imaginary"

/* identifiers */nst"|"con
alpha [a-zA-Z_]
digit [0-9]
identifier {alpha}({alpha}|{digit})*
non_zero_digit [1-9]
const_int 0|{non_zero_digit}{digit}*
dig_seq {digit}+
exp [eE][+-]?{dig_seq}
const_dec {dig_seq}?\.{dig_seq}|{dig_seq}\.
const_flt {const_dec}{exp}?|{dig_seq}{exp}
const_enum {identifier}
escape_seq \\[abfnrtv'"\?\\]
c_char [^'\\\n]|{escape_seq}
c_char_seq {c_char}+
const_char \'{c_char_seq}\'
const {const_int}|{const_flt}|{const_char}|{const_enum}

s_char [^"\\\n]|{escape_seq}
s_char_seq {s_char}+
str_lit \"{s_char_seq}?\"

/* punctuators */
punctuator "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="|","|"#"
space	[ \t\n]
spaces	{space}+

%%

{spaces}	{ }
{keyword}	{ return(KEYWORD); }
{identifier}	{ return(IDENTIFIER); }
{const_int}	{ return(CONST_INT); }
{const_flt}	{ return(CONST_FLT); }
{const_char}	{ return(CONST_CHAR); }
{str_lit}	{ return(STR_LIT); }
{punctuator}	{ return(PUNCTUATOR); }
{comm_single}	{ return(SL_COMM); }
{comm_multi}	{ return(ML_COMM); }

%%

int yywrap(void) {
    return 1;
}