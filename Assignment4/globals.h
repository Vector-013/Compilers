#ifndef EXPR_H
#define EXPR_H

extern int STMT_CNT;
extern int ERROR_CNT;
void yyerror(const char *s);

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <unistd.h>
#include "poly.tab.h"

typedef union
{
    int value;
    char op;
    char var;
} data;

typedef struct _exprNode
{
    struct _exprNode *child;
    struct _exprNode *sibling;
    char name;
    data inh;
    data syn;
    data symbol;

} exprNode;

exprNode *insert(char name);
void add_child(exprNode *parent, exprNode *child);
void set_attr(exprNode *node);
void print_tree(exprNode *root, int depth);
long long evalpoly(exprNode *root, long long x);
void print_derivative(exprNode *root);

#endif // EXPR_H