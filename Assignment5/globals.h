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

#define MAX_MEM 65536
#define NUM_REGISTERS 12

// Global variables
extern int symbolCount;
extern int memCount;
extern int regUsage[NUM_REGISTERS];
extern int tempVarCount;

// Definition for the linked list node
typedef struct _node
{
    char *name;
    int offset;
    struct _node *next;
} node;

typedef struct _type
{
    int status; // 0 = num, 1 = in reg, 2 = in mem
    int loc;
    int num;
    char *dataStr;
} type;

typedef type *data;

// Typedef for the symbol table
typedef node *symbolTable;

// Function prototypes
void addSymbol(char *name);
int lookup(char *name);
int allocateRegister();
void freeMemory(int mem);
void freeAllRegisters();
void emitAssignment(char *var, int value);
void emitCopy(char *var1, char *var2);
void emitExpr(char *var, int status, int loc, int num);
char *convertStr(int status, int loc, int num);
int allocateMemory();
void cleanup();

#endif // EXPR_H
