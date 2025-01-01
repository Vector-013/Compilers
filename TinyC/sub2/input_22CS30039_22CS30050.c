/*
 MULTI LINE COMMENT FOUND
 Line 2 OF COMMENT
 */
float b = 2.5;
float c = 3.5;
void func()
{
    int a = 5;
    a = a + 1;
}
extern int extern_int;
static int static_int;
volatile int volatile_int;
const int const_int = 5;
restrict int restrict_int;
inline float add(float a, float b)
{
    return a + b;
}
int main()
{
    long x, y = 1;
    x = 5;

    if (x > 0)
        if (y > 0)
            x = x / 1;
        else
            y = y % 1;

    // SINGLE LINE COMMENT FOUND
    int arr1[10];
    int arr2[10][10];
    int i1 = 1, i2 = 2, i3 = 3;
    unsigned int ui1 = 1;
    char char1 = 'a';
    register reg1;
    short short1 = 0;
    for (int i = 0; i < 10; i++)
    {
        arr1[i] = i;
        arr2[i][i] = i;
    }
    if (i1 == 1)
    {
        i2 = 3 * 5;
    }
    else
    {
        i3 = 4;
    }
    for (auto i = 0; i < 10; i++)
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

    float v = add(1.0, 2.0);
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
    float f1 = 1.0;
    float _Complex c1 = 1.0;
    double d1 = 1.666;
    _Bool b1 = 1;
    unsigned int ui2 = 1;
    goto label;
label:
    return 0;
}
