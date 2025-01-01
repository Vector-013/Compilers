#include "globals.h"

int STMT_CNT = 0;

void yyerror(const char *s)
{
    std::cerr << s << std::endl;
    // need to terminate the parsing process
    exit(1);
}

exprNode *insert(char name)
{
    exprNode *newNode = new exprNode;
    newNode->name = name;
    newNode->child = NULL;
    newNode->sibling = NULL;

    return newNode;
}

void add_child(exprNode *parent, exprNode *child)
{
    child->sibling = parent->child;
    parent->child = child;
}

void set_attr(exprNode *node)
{
    if (node->name == 'S')
    {
        if (node->child->name == 'P')
        {
            node->child->inh.op = '+';
        }
        else if (node->child->name == '+')
        {
            node->child->sibling->inh.op = '+';
        }
        else
        {
            node->child->sibling->inh.op = '-';
        }
    }
    if (node->name == 'P')
    {
        if (node->child->name == 'T')
        {
            node->child->inh.op = node->inh.op;
        }
        if (node->child->sibling)
        {
            node->child->sibling->sibling->inh.op = node->child->sibling->symbol.op;
        }
    }
    if (node->name == 'N')
    {
        if (node->child->sibling)
        {
            node->child->sibling->inh.value = node->child->syn.value;
        }
    }
    if (node->name == 'M')
    {
        if (node->child->sibling)
        {
            node->child->sibling->inh.value = node->inh.value * 10 + node->child->syn.value;
        }
    }
    exprNode *child = node->child;
    while (child != NULL)
    {
        set_attr(child);
        child = child->sibling;
    }
    if (node->name == 'N')
    {
        if (node->child->sibling)
        {
            node->syn.value = node->child->sibling->syn.value;
        }
        else
        {
            node->syn.value = node->child->syn.value;
        }
    }
    else if (node->name == 'M')
    {
        if (!node->child->sibling)
        {
            node->syn.value = node->child->syn.value + node->inh.value * 10;
        }
        else
        {
            node->syn.value = node->child->sibling->syn.value;
        }
    }
}

void print_node(exprNode *node)
{
    if (node->name == 'N')
    {
        std::cout << "[val = " << node->syn.value << "]";
    }
    else if (node->name == 'M')
    {
        std::cout << "[inh = " << node->inh.value << ", val = " << node->syn.value << "]";
    }
    else if (node->name >= '0' && node->name <= '9')
    {
        std::cout << "[val =  " << node->syn.value << "]";
    }
    else if (node->name == 'T' || node->name == 'P')
    {
        std::cout << "[inh = " << node->inh.op << "]";
    }
    else
    {
        std::cout << "[]";
    }
}

void print_tree(exprNode *root, int depth)
{
    if (root == NULL)
    {
        return;
    }

    for (int i = 0; i < depth; i++)
    {
        std::cout << "    ";
    }

    std::cout << "==> " << root->name << " ";
    print_node(root);
    std::cout << std::endl;

    exprNode *child = root->child;
    while (child != NULL)
    {
        print_tree(child, depth + 1);
        child = child->sibling;
    }
}

long long power(long long x, long y)
{
    long long result = 1;
    for (int i = 0; i < y; i++)
    {
        result *= x;
    }
    return result;
}

long long evalpoly(exprNode *node, long long x)
{
    long long value = 0;

    if (node->name == 'S')
    {
        if (node->child->name == 'P')
        {
            return evalpoly(node->child, x);
        }
        else
        {
            return evalpoly(node->child->sibling, x);
        }
    }

    else if (node->name == 'P')
    {
        if (node->child->name == 'T' && node->child->sibling)
        {
            return evalpoly(node->child, x) + evalpoly(node->child->sibling->sibling, x);
        }
        else if (node->child->name == 'T')
        {
            return evalpoly(node->child, x);
        }
    }

    else if (node->name == 'N')
    {
        return node->syn.value;
    }
    else if (node->name == 'X')
    {
        if (node->child->sibling)
        {
            return power(x, node->child->sibling->sibling->syn.value);
        }
        else
        {
            return x;
        }
    }
    else if (node->name == 'T')
    {
        if (node->child->name == 'N')
        {
            if (node->child->sibling)
            {
                value = evalpoly(node->child->sibling, x) * node->child->syn.value;
            }
            else
            {
                value = node->child->syn.value;
            }
        }
        else if (node->child->name == 'X')
        {
            value = evalpoly(node->child, x);
        }
        else
        {
            value = 1;
        }
        if (node->inh.op == '+')
            return value;
        else
            return -1 * value;
    }
    return value;
}

void print_derivative(exprNode *node)
{
    if (node->name == 'S')
    {
        if (node->child->name == 'P')
        {
            print_derivative(node->child);
        }
        else
        {
            print_derivative(node->child->sibling);
        }
    }
    else if (node->name == 'P')
    {
        if (node->child->name == 'T' && node->child->sibling)
        {
            print_derivative(node->child);
            print_derivative(node->child->sibling->sibling);
        }
        else if (node->child->name == 'T')
        {
            print_derivative(node->child);
        }
    }
    else if (node->name == 'X')
    {
        if (node->child->sibling && node->child->sibling->sibling->syn.value > 2)
        {
            std::cout << "x^" << node->child->sibling->sibling->syn.value - 1;
        }
        else if (node->child->sibling && node->child->sibling->sibling->syn.value == 2)
        {
            std::cout << "x";
        }
    }
    else if (node->name == 'T')
    {
        if (node->child->name == 'N')
        {
            if (node->child->sibling)
            {
                if (node->child->sibling->child->sibling)
                {
                    if (node->inh.op == '-')
                    {
                        std::cout << " - ";
                    }
                    else
                    {
                        std::cout << " + ";
                    }
                    std::cout << node->child->sibling->child->sibling->sibling->syn.value * node->child->syn.value;
                    print_derivative(node->child->sibling);
                }
                else
                {
                    std::cout << node->child->syn.value;
                }
            }
        }
        else if (node->child->name == 'X')
        {
            if (node->inh.op == '-')
            {
                std::cout << " - ";
            }
            else
            {
                std::cout << " + ";
            }
            if (node->child->child->sibling && node->child->child->sibling->sibling->syn.value > 2)
            {
                std::cout << node->child->child->sibling->sibling->syn.value << "x^" << node->child->child->sibling->sibling->syn.value - 1;
            }
            else if (node->child->child->sibling && node->child->child->sibling->sibling->syn.value == 2)
            {
                std::cout << "2x";
            }
            else
            {
                std::cout << "1";
            }
        }
    }
}

int main()
{
    yyparse();
    return 0;
}