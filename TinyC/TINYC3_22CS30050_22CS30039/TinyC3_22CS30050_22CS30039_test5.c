// Test 5: Demonstrates function calls, conditionals, and variable scope.
int square(int num)
{
    return num * num; // Returns the square of the input number
}

int isEven(int num)
{
    if (num % 2 > 0) // Checks if the number is even
        return 1;    // Return true
    else
        return 0; // Return false
}
//
int main()
{
    int a = 5, b = 10;
    int squaredA = square(a); // Call to square function
    int squaredB = square(b); // Call to square function

    if (isEven(squaredA))        // Check if squaredA is even
        squaredA = squaredA + 1; // Increment if even

    if (isEven(squaredB))        // Check if squaredB is even
        squaredB = squaredB + 1; // Increment if even

    return squaredA + squaredB; // Return the sum of squared values
}
