%{
#include "expr.tab.h"
%}

space	[ \t\n]
spaces	{space}+
digit	[0-9]
nonzero    [1-9]
digits	0|[+-]?{nonzero}{digit}*
frac	\.{digits}
expt	[Ee][+-]?{digits}
number	{digits}{frac}?{expt}?
idf [a-zA-Z_]+
id	{idf}[a-zA-Z_0-9]*

%%

{spaces}	{ }
{number}	{ yylval.ival=atoi(yytext); return(NUM); }
"("		{ return(LP); }
")"		{ return(RP); }
"**"		{ return(POW); }
"+"		{ return(ADD); }
"-"		{ return(SUB); }
"*"		{ return(MUL); }
"/"		{ return(DIV); }
"%"		{ return(MOD); }
"set"		{ return(SET); }
{id}		{ yylval.sval = strdup(yytext); return(ID); }


%%

int yywrap(void){
    return 1;
}

