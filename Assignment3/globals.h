#ifndef EXPR_H
#define EXPR_H

extern int STMT_CNT;
extern int ERROR_CNT;
extern int yyerror(const char *s);

// Include necessary standard libraries

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
#include <thread>
#include <chrono>
#include <unistd.h>
#include "expr.tab.h"

// Definition for the linked list node
typedef struct _node
{
    char *name;
    int value;
    struct _node *next;
} node;

// Enumeration for different node types in the expression tree
typedef enum
{
    OP_TYPE,
    NUM_TYPE,
    ID_TYPE
} nodeType;

// Definition for the expression tree node
typedef struct _exprNode
{
    nodeType type;
    struct _exprNode *left;
    struct _exprNode *right;
    union
    {
        char op;      // Operator for OP_TYPE
        int numValue; // Numeric value for NUM_TYPE
        char *idName; // Identifier name for ID_TYPE
    } data;
} exprNode;

// Typedef for the symbol table
typedef node *symbolTable;

// Function declarations for symbol table operations
node *insert(char *name);
node *lookup(char *name);
void set(node *name, int value);

// Function declarations for expression tree operations
exprNode *createLeafNodeConst(int value);
exprNode *createLeafNodeID(symbolTable symtbl);
exprNode *createOpNode(char op, exprNode *left, exprNode *right);
void printExprTree(exprNode *root);
int evaluate(exprNode *root);
void deleteTree(exprNode *root);

#endif // EXPR_H
