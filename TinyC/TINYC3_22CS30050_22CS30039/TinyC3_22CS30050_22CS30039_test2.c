// Test 2: Demonstrates nested functions and recursion, if else statements.
int factorial(int n)
{
    if (n <= 1) // Base case for recursion , IF ELSE
        return 1;
    else
        return n * factorial(n - 1); // Recursive call
}

int add(int a, int b)
{
    return a + b; // Adds two integers
}

int main()
{
    int result1 = factorial(5); // Calculate factorial of 5
    int result2 = factorial(6); // Calculate factorial of 6

    int sum = result1 + result2; // Sum of two factorials

    return add(sum, 10); // Add 10 to the sum and return
}
