%{
    #include "y.tab.h"
    #include <stdio.h>
%}

numb        [+-]?[0-9]+
iden        [a-zA-Z_][a-zA-Z0-9_]*
spaces      [ \t\n]+

%%

{spaces}        { /* ignore */  }
"set"           { return SET;   }
"when"          { return WHEN;  }
"loop while"    { return WHILE; }
"("             { return OB;    }    
")"             { return CB;    }
{iden}          { yylval.str = strdup(yytext); return IDEN;  }
{numb}          { yylval.str = strdup(yytext); return NUMB;  }
"+"             { yylval.str = strdup(yytext); return ADD;   }
"-"             { yylval.str = strdup(yytext); return SUB;   }
"*"             { yylval.str = strdup(yytext); return MUL;   }
"/"             { yylval.str = strdup(yytext); return DIV;   }
"%"             { yylval.str = strdup(yytext); return MOD;   }
"="             { yylval.str = strdup(yytext); return EQ;    }
"/="            { yylval.str = strdup(yytext); return NEQ;   }
"<"             { yylval.str = strdup(yytext); return LT;    }
"<="            { yylval.str = strdup(yytext); return LE;    }
">"             { yylval.str = strdup(yytext); return GT;    }
">="            { yylval.str = strdup(yytext); return GE;    }
.               { /* ignore */  }

%%

int yywrap(void) 
{
    return 1;
}