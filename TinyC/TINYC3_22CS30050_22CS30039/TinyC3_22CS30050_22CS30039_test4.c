// Test 4: Demonstrates array usage, for loops, and basic arithmetic, if-else
int main()
{
    int nums[5]; // Declare an array of integers
    int sum = 0; // Variable to hold the sum
    int i = 0;   // Loop counter

    // Initialize the array with values
    for (i = 0; i < 5; i++)
    {
        nums[i] = (i + 1) * 2; // Fill array with even numbers
    }

    // Calculate the sum of the array elements
    for (i = 0; i < 5; i++)
    {
        sum = sum + nums[i]; // Accumulate sum
    }

    // Final value manipulation
    if (sum > 20)
    {
        sum = sum / 5; // Average if sum is greater than 20
    }
    else
    {
        sum = sum + 2; // Double the sum if not
    }

    return sum; // Return the final result
}
