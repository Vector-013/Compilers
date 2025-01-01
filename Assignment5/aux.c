int pwr(int base, int e)
{
    if (e == 0)
        return 1;
    if (e % 2 == 1)
        return pwr(base, e - 1) * base;
    else
    {
        int b = pwr(base, e / 2);
        return b * b;
    }
}

void mprn(int *mem, int offset)
{
    printf("+++ MEM[%d] has been set to  %d\n", offset, mem[offset]);
}

void eprn(int *R, int offset)
{
    printf("+++ Stanalone statement evaluates to %d\n", R[offset]);
}