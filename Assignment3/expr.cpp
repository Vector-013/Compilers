#include <signal.h>
#include <execinfo.h>
#include "globals.h"

int STMT_CNT = 0;
int ERROR_CNT = 0;

void signal_handler(int signal) // Can be used in debugging and detecting system errors like SegFault
{
    void *array[10];
    size_t size;

    size = backtrace(array, 10);

    fprintf(stderr, "Error: signal %d:\n", signal);
    backtrace_symbols_fd(array, size, STDERR_FILENO);

    exit(1);
}

symbolTable symtbl;

node *insert(char *name)
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
    if (name == NULL)
    {
        yyerror("[ERROR] Identifier not found in symbol table");
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
        yyerror("[ERROR] Tree cannot be empty");
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
            if (right == 0)
            {
                yyerror("[MATH ERROR] Division by zero");
                return 0;
            }
            return left / right;
        }
        case '%':
        {
            if (right == 0)
            {
                yyerror("[MATH ERROR] Modulo by zero");
                return 0;
            }
            return left % right;
        }
        case '^':
        {
            return binpower(left, right);
        }
        default:
            yyerror("[PARSING ERROR] Invalid operator");
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
    if (yyparse() == 0)
    {
        std::cout << "\n[PARSING COMPLETED SUCCESFULLY]\n";
        std::cout << "[INFO]: " << STMT_CNT << " statement(s) have been parsed\n";
        std::cout << "[INFO]: " << ERROR_CNT << " error(s) have been encountered\n";
    }
    else
    {
        std::cout << "\n[PARSING FAILED] : Syntax Error ( Non-Sytactical errors can be retrieved and the parsing may be continued)\n";
        std::cout << "Terminating the program\n";
        std::cout << "[INFO]: " << STMT_CNT << " statement(s) have been parsed\n";
        std::cout << "[INFO]: " << ERROR_CNT << " error(s) have been encountered\n";
    }
    return 0;
}
