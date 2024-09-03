#include <iostream>
#include <string>
#include <vector>
#include <cstring>

#define KEYWORD 1
#define IDENTIFIER 2
#define CONST_INT 3
#define CONST_FLT 4
#define CONST_CHAR 5
#define STR_LIT 6
#define PUNCTUATOR 7
#define SL_COMM 8
#define ML_COMM 9

extern int yylex();
extern char *yytext;

class node
{
public:
    std::string name;
    int type;
    int cnt;
    node *next;
    node(std::string s, int t, int c) : name(s), type(t), cnt(c), next(NULL) {}
};
typedef node *symboltable;

symboltable addtbl(symboltable T, std::string id, int type)
{
    symboltable p;
    p = T;
    while (p)
    {
        if (!strcmp(p->name.c_str(), id.c_str()))
        {
            p->cnt = p->cnt + 1;
            return T;
        }
        p = p->next;
    }
    p = new node(id, type, 1);
    p->next = T;
    return p;
}

void printtbl(symboltable T)
{
    symboltable p;
    std::vector<std::string> kw_str, id_str, int_str, flt_str, char_str, str_str, punc_str;
    p = T;
    while (p)
    {
        switch (p->type)
        {
        case KEYWORD:
            kw_str.push_back(p->name);
            break;
        case IDENTIFIER:
            id_str.push_back(p->name);
            break;
        case CONST_INT:
            int_str.push_back(p->name);
            break;
        case CONST_FLT:
            flt_str.push_back(p->name);
            break;
        case CONST_CHAR:
            char_str.push_back(p->name);
            break;
        case STR_LIT:
            str_str.push_back(p->name);
            break;
        case PUNCTUATOR:
            punc_str.push_back(p->name);
            break;
        default:
            break;
        }
        p = p->next;
    }

    std::cout << "KEYWORDS\n";
    for (auto &i : kw_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "IDENTIFIERS\n";
    for (auto &i : id_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "INTEGERS\n";

    for (auto &i : int_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "FLOAT\n";
    for (auto &i : flt_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "CHARACTERS\n";
    for (auto &i : char_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "STRING\n";
    for (auto &i : str_str)
        std::cout << i << " ";
    std::cout << "\n\n";

    std::cout << "PUNCTUATORS\n";
    for (auto &i : punc_str)
        std::cout << i << " ";
    std::cout << "\n";

    return;
}

int main()
{
    int tkn;
    symboltable T = NULL;
    symboltable equations = NULL;
    symboltable environment = NULL;

    while ((tkn = yylex()))
    {
        switch (tkn)
        {
        case KEYWORD:
        {
            std::cout << "<KEYWORD, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), KEYWORD);
            break;
        }
        case IDENTIFIER:
        {
            std::cout << "<IDENTIFIER,  " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), IDENTIFIER);
            break;
        }
        case CONST_INT:
        {
            std::cout << "<INTEGER, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), CONST_INT);
            break;
        }
        case CONST_FLT:
        {
            std::cout << "<FLOAT, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), CONST_FLT);
            break;
        }
        case CONST_CHAR:
        {
            std::cout << "<CHARACTER, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), CONST_CHAR);
            break;
        }
        case STR_LIT:
        {
            std::cout << "<STRING, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), STR_LIT);
            break;
        }
        case PUNCTUATOR:
        {
            std::cout << "<PUNCTUATOR, " << yytext << " >\n";
            T = addtbl(T, std::string(yytext), PUNCTUATOR);
            break;
        }
        case SL_COMM:
        {
            std::cout << "<SINGLE LINE COMMENT, " << std::string(yytext).substr(0, std::string(yytext).find('\n')) << " >\n";
            break;
        }
        case ML_COMM:
        {
            std::cout << "<MULTI LINE COMMENT, " << yytext << " >\n";
            break;
        }
        default:
            break;
        }
    }
    std::string breaker(100, '=');
    std::cout << breaker << '\n'
              << "SYMBOL TABLE\n\n";
    printtbl(T);

    exit(0);
}