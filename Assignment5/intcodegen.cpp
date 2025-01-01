l#include <execinfo.h>
#include "globals.h"

int STMT_CNT = 0;
int ERROR_CNT = 0;

int symbolCount = 0;
int memCount = 0;
int regUsage[NUM_REGISTERS] = {0};
int tempVarCount = 0;

symbolTable symtbl;

// Function to add a symbol to the symbol table
void addSymbol(char *name)
{
    node *newSymbol = new node;
    newSymbol->name = strdup(name);
    newSymbol->offset = memCount;
    memCount++;
    newSymbol->next = NULL;
    if (symtbl == NULL)
    {
        symtbl = newSymbol;
    }
    else
    {
        node *temp = symtbl;
        while (temp->next != NULL)
        {
            temp = temp->next;
        }
        temp->next = newSymbol;
    }
}

// Function to lookup a symbol in the symbol table
int lookup(char *name)
{
    node *temp = symtbl;
    while (temp != NULL)
    {
        if (strcmp(temp->name, name) == 0)
        {
            return temp->offset;
        }
        temp = temp->next;
    }
    // if symbol not found, insert
    addSymbol(name);
    temp = symtbl;
    while (temp != NULL)
    {
        if (strcmp(temp->name, name) == 0)
        {
            return temp->offset;
        }
        temp = temp->next;
    }
    return 0;
}

void freeMemory(int mem)
{
    memCount--;
}

void freeAllRegisters()
{
    for (int i = 0; i < NUM_REGISTERS; i++)
    {
        regUsage[i] = 0;
    }
}

// // Emit TAC for assignment (set var = value)
void emitAssignment(char *var, int value)
{
    int offset = lookup(var);
    if (offset == -1)
    {
        addSymbol(var);
        offset = lookup(var);
    }
    printf("\tMEM[%d] = %d;\n", offset, value);
    printf("\tmprn(MEM, %d);\n", offset);
}

// Emit TAC for copying one variable to another (set var1 = var2)
void emitCopy(char *var1, char *var2)
{
    int offset1 = lookup(var1);
    if (offset1 == -1)
    {
        addSymbol(var1);
        offset1 = lookup(var1);
    }
    int offset2 = lookup(var2);
    // we will use R[0] and R[1] as temporary registers for copying from memory
    printf("\tR[0] = MEM[%d];\n", offset2);
    printf("\tMEM[%d] = R[0];\n", offset1);
    printf("\tmprn(MEM, %d);\n", offset1);
}

void emitExpr(char *var, int status, int loc, int num)
{
    int offset = lookup(var);
    if (offset == -1)
    {
        addSymbol(var);
        offset = lookup(var);
    }
    char *str = convertStr(status, loc, num);
    if (status == 0)
    {
        printf("\tMEM[%d] = %s;\n", offset, str);
    }
    else if (status == 1)
    {
        printf("\tMEM[%d] = R[%d];\n", offset, loc);
        regUsage[loc] = 0;
    }
    else if (status == 2)
    {
        printf("\tR[0] = MEM[%d];\n", loc);
        printf("\tMEM[%d] = R[0];\n", offset);
    }
    printf("\tmprn(MEM, %d);\n", offset);
}

int allocateRegister()
{
    for (int i = 2; i < NUM_REGISTERS; i++)
    {
        if (regUsage[i] == 0)
        {
            regUsage[i] = 1;
            return i; // Return the register number if it is free
        }
    }
    return -1; // Return -1 if no register is free
}

int allocateMemory()
{
    int mem = memCount;
    memCount++;
    return mem;
}

char *convertStr(int status, int loc, int num)
{
    char *str = (char *)malloc(15);
    if (status == 0)
    {
        sprintf(str, "%d", num);
    }
    else if (status == 1)
    {
        sprintf(str, "R[%d]", loc);
    }
    else if (status == 2)
    {
        if (regUsage[0] == 0)
        {
            regUsage[0] = 1;
            printf("\tR[0] = MEM[%d];\n", loc);

            sprintf(str, "R[0]");
        }
        else
        {
            regUsage[1] = 1;
            printf("\tR[1] = MEM[%d];\n", loc);
            sprintf(str, "R[1]");
        }
    }
    return str;
}

void cleanup()
{
    node *temp = symtbl;
    while (temp != NULL)
    {
        node *next = temp->next;
        free(temp->name);
        free(temp);
        temp = next;
    }
}

int main()
{
    symtbl = NULL;

    std::cout << "#include <stdio.h>\n";
    std::cout << "#include <stdlib.h>\n";
    std::cout << "#include <string.h>\n\n";
    std::cout << "#include \"aux.c\"\n\n";
    std::cout << "int main()\n{\n";
    std::cout << "\tint MEM[" << MAX_MEM << "];\n";
    std::cout << "\tint R[" << NUM_REGISTERS << "];\n";

    yyparse();
    std::cout << "\treturn 0;\n}\n";
    cleanup();
    return 0;
}
