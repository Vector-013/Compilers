#include <stdio.h>
#include <stdlib.h>

typedef struct node
{
    int data;
    char c[10];
    struct node *next;
} node;

static int static_int;
volatile int volatile_int;
inline int func();
void func2();
enum
{
    a = 1,
    b = 2,
    c = 3
};

int main()
{
    // SINGLE LINE COMMENT FOUND
    int arr1[10];
    int arr2[10][10];
    int i1 = 1, i2 = 2, i3 = 3;
    unsigned int ui1 = 1;
    char char1 = 'a';
    register reg1;
    short short1 = 0;
    node *n1 = (node *)malloc(sizeof(node));
    for (int i = 0; i < 10; i++)
    {
        arr1[i] = i;
        arr2[i][i] = i;
    }
    if (i1 == 1)
    {
        i2 = 3;
    }
    else
    {
        i3 = 4;
    }
    for (int i = 0; i < 10; i++)
    {
        if (i == 5)
        {
            continue;
        }
        else if (i == 7)
        {
            break;
        }
        else
        {
            i1--;
        }
    }
    /*
    MULTI LINE COMMENT FOUND
    Line 2 OF COMMENT
    */

    do
    {
        i1++;
    } while (i1 < 10 || i1 > 0);

    int size = sizeof(int);
    int *ptr = &i1;
    int **ptr2 = &ptr;
    if (i1 == 1 && i2 != 2)
    {
        i3 = 5;
    }
    else if (i1 <= 2 || i2 >= 3)
    {
        i3 = 6;
    }
    else
    {
        i3 = 7;
    }
    switch (i1)
    {
    case 1:
        i2 = 2;
        break;
    case 2:
        i2 = 3;
        break;
    default:
        i2 = 4;
        break;
    }
    n1->data = 1;
    n1->next = NULL;
    free(n1);

    i3 *= 1;
    i3 /= 2;
    i3 += 5;
    i3 -= 2;
    i3 %= 2;
    i3 &= 3;
    i3 |= 4;

    // SINGLE LINE COMMENT-2 FOUND
    i3 <<= 2;
    i3 >>= 2;
    i3 = (i1 > 2) ? 1 : 0;
    i3 = (i1 > 2) ? 1 : (i2 < 3) ? 2
                                 : 3;
    i2 = i1 & 0;
    i2 = i1 | 4;
    i2 = i1 ^ 5;
    i2 = ~i1;
    i2 = i1 && 1;
    i2 = i1 || 0;
    i2 = !i1;
    i2 = i1 == 1;
    char *c1 = "Dummy string mark-1";
    int *ptr3 = (int *)malloc(sizeof(int));
    float f1 = 1.0;
    float _Complex c1 = 1.0;
    double d1 = 1.666;
    _Bool b1 = 1;
    unsigned int ui2 = 1;
    goto label;
label:
    return 0;
}