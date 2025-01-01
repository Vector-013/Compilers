// test for all types of declarations and assignments, some basic functions and return types

int g1, g2; // global variables
char g3 = 'a';

void foo(int a, int b); // Function declaration
void foo(int a, int b)  // Function overloading
{
    int i = a + b;
    return;
}
int power(int x, int y)
{
    int res = 1;
    int i = 0;
    for (i = 0; i < y; i++) // LOOP INSIDE FUNC
    {
        res *= x;
    }
    return res;
}

int main()
{
    float f1 = 2.3, f2;
    int n1, n2 = 10, *n3;
    char c1, c2[80];
    char *str1 = "TestString", *str2;

    n1 = n2 = f1 = f2;
    c2[22] = c1;
    str2 = str1;
    int x = power(2, 3);

    return 0;
}