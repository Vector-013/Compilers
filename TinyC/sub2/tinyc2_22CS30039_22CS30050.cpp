#include "globals.h"

void yyerror(const char *s)
{
    std::cerr << s << std::endl;
}

node *insert(std::string parse_rule)
{
    node *newNode = new node;
    newNode->parse_rule = parse_rule;
    newNode->next = NULL;
    newNode->head = NULL;

    return newNode;
}

void add_child(node *parent, node *child)
{
    child->next = parent->head;
    parent->head = child;
}

void print_tree(node *root, int depth)
{
    if (root == NULL)
    {
        return;
    }

    for (int i = 0; i < depth; i++)
    {
        std::cout << "   ";
    }
    std::cout << root->parse_rule << std::endl;

    node *child = root->head;
    while (child != NULL)
    {
        print_tree(child, depth + 1);
        child = child->next;
    }
}

int main()
{
    yyparse();
    return 0;
}