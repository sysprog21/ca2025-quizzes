#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef uint8_t uf8;

static inline unsigned clz(uint32_t x)
{
    int n = 32, c = 16;
    do {
        uint32_t y = x >> c;
        if (y) {
            n -= c;
            x = y;
        }
        c >>= 1;
    } while (c);
    // printf(" n = %d , x = %u \n", n, x);
    return n - x;
}

bool test_clz_0x1()
{
    uint32_t x = 0x1;
    unsigned expected = 31;
    unsigned result = clz(x);
    if (result != expected) {
        printf("clz(0x%X) = %u, expected %u\n", (unsigned)x, result, expected);
        return false;
    }
    return true;
}

bool test_clz_0x80()
{
    uint32_t x = 0x80;
    unsigned expected = 24;
    unsigned result = clz(x);
    if (result != expected) {
        printf("clz(0x%X) = %u, expected %u\n", (unsigned)x, result, expected);
        return false;
    }
    return true;
}

bool test_clz_0x00000000()
{
    uint32_t x = 0x00000000;
    unsigned expected = 32;
    unsigned result = clz(x);
    if (result != expected) {
        printf("clz(0x%X) = %u, expected %u\n", (unsigned)x, result, expected);
        return false;
    }
    return true;
}


int main(void)
{
    bool all_passed = false;
    all_passed |= test_clz_0x1();


    if (all_passed) {
        printf("All Test passed.\n");
    };
    return 1;
}
