%{
#include "poly.tab.h"
void yyerror(const char *s);
%}

space    [ \t\n]
spaces    {space}+
zero   "0"
one   "1"
digit    [2-9]
x   "x"
expo   "^"
plus   "+"
minus   "-"
error .

%%

{spaces}    { }
{zero}    { yylval.ival=0; return(ZERO); }
{one}    { yylval.ival=1; return(ONE); }
{digit}    { yylval.ival=atoi(yytext); return(DIGIT); }
{x}    { yylval.cval='x' ;return(VAR); }
{expo}    {yylval.cval='^' ;return(EXPO); }
{plus}    { yylval.cval='+' ;return(PLUS); }
{minus}    {yylval.cval='-';return(MINUS); }
{error}     { printf("Error: %s\n", yytext); yyerror("[ERROR] INVALID TOKEN IN INPUT\n");}

%%

int yywrap(void){
    return 1;
}