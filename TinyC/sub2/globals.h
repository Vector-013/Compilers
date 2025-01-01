#ifndef EXPR_H
#define EXPR_H

#include <iostream>
#include <stdio.h>
#include <string.h>
#include <string>
#include "tinyc2_22CS30039_22CS30050.tab.h"
void yyerror(const char *s);

typedef struct _node
{
    std::string parse_rule;
    struct _node *head;
    struct _node *next;
} node;

node *insert(std::string parse_rule);
void add_child(node *parent, node *child);
void print_tree(node *root, int depth);

#endif // EXPR_H
