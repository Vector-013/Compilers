// Test3 : testing operators, bit-wise operatios, loops, pointers

int main()
{
    int a = 5;
    int b = 10;
    int sum = a + b;
    int product = a * b;
    int i;

    int *p = &a;
    int **pp = &p;

    for (i = 0; i < 5; i++)
    {
        sum += i;
    }

    while (a < 10) // DO WHILE
    {
        a++;
    }
    do
    {
        b++;
    } while (b < 15);

    // bit wise
    int x = 5;
    int y = 10;
    int z = x & y;
    int w = x | y;
    int u = x ^ y;
    int v = ~x;
    int t = x << 2;
    int s = x >> 2;
}