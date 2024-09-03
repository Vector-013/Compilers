#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <iostream>
#include "expr.tab.h"
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <execinfo.h>

void signal_handler(int signal) {
    void *array[10];
    size_t size;
    
    // Get the backtrace
    size = backtrace(array, 10);
    
    // Print the backtrace to stderr
    fprintf(stderr, "Error: signal %d:\n", signal);
    backtrace_symbols_fd(array, size, STDERR_FILENO);
    
    // Exit the program
    exit(1);
}

int yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    return 0;
}

typedef struct _node
{
    char *name;
    int value;
    struct _node *next;
} node;

typedef enum
{
    OP_TYPE,
    NUM_TYPE,
    ID_TYPE
} nodeType;

typedef struct _exprNode
{
    nodeType type;
    struct _exprNode *left;
    struct _exprNode *right;
    union
    {
        char op;
        int numValue;
        char *idName;
    } data;
} exprNode;

typedef node *symbolTable;
symbolTable symtbl;

node* insert(char *name)
{
    node *newNode = (node *)malloc(sizeof(node));
    newNode->name = strdup(name);
    newNode->next = symtbl;
    symtbl = newNode;
    return newNode;
}

node *lookup(char *name)
{
    node *temp = symtbl;
    while (temp != NULL)
    {
        if (strcmp(temp->name, name) == 0)
        {
            return temp;
        }
        temp = temp->next;
    }
    return NULL;
}

void set(node *name, int value)
{
    if(name == NULL) {
        yyerror("Variable not founde");
        return;
    }
    name->value = value;
}

exprNode *createLeafNodeConst(int value)
{
    exprNode *newNode = (exprNode *)malloc(sizeof(exprNode));
    newNode->type = NUM_TYPE;
    newNode->data.numValue = value;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

exprNode *createLeafNodeID(symbolTable symtbl)
{
    exprNode *newNode = (exprNode *)malloc(sizeof(exprNode));
    newNode->type = ID_TYPE;
    newNode->data.idName = symtbl->name;
    newNode->left = NULL;
    newNode->right = NULL;
    return newNode;
}

exprNode *createOpNode(char op, exprNode *left, exprNode *right)
{
    exprNode *newNode = new exprNode;
    newNode->type = OP_TYPE;
    newNode->data.op = op;
    newNode->left = left;
    newNode->right = right;

    return newNode;
}

void printExprTree(exprNode *root)
{
    if (root == NULL)
    {
        return;
    }
    if (root->type == NUM_TYPE)
    {
        printf("%d", root->data.numValue);
    }
    else if (root->type == ID_TYPE)
    {
        printf("%s", root->data.idName);
    }
    else
    {
        printf("(");
        printExprTree(root->left);
        printf("%c", root->data.op);
        printExprTree(root->right);
        printf(")");
    }
}

int binpower(int base, int e)
{
    if (e == 0)
        return 1;
    if (e % 2 == 1)
        return binpower(base, e - 1) * base;
    else
    {
        int b = binpower(base, e / 2);
        return b * b;
    }
}

int evaluate(exprNode *root)
{
    if (root == NULL)
    {
        // raise error by calling yyerror
        yyerror("[Error] Tree can not be empty");
        return 0;
    }
    if (root->type == NUM_TYPE)
    {
        return root->data.numValue;
    }
    else if (root->type == ID_TYPE)
    {
        return lookup(root->data.idName)->value;
    }
    else
    {
        int left = evaluate(root->left);
        int right = evaluate(root->right);
        switch (root->data.op)
        {
        case '+':
            return left + right;
        case '-':
            return left - right;
        case '*':
            return left * right;
        case '/':
            {
                if(right == 0) {
                    yyerror("Division by zero");
                    return 0;
                    }
                return left / right;}
        case '%':
            return left % right;
        case '^':
            return binpower(left, right);
        default:
            yyerror("Unknown operator");
            return 0;
        }
    }
}

void deleteTree(exprNode *root)
{
    if (root == NULL)
    {
        return;
    }
    deleteTree(root->left);
    deleteTree(root->right);
    free(root);
}

int main()
{
    symtbl = NULL;
    yyparse();
    return 0;
}
