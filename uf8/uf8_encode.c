#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

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
    return n - x;
}

uf8 uf8_encode(uint32_t value)
{
    /* Use CLZ for fast exponent calculation */
    if (value < 16)
        return value;

    /* Find appropriate exponent using CLZ hint */
    int lz = clz(value);
    int msb = 31 - lz;

    /* Start from a good initial guess */
    uint8_t exponent = 0;
    uint32_t overflow = 0;

    if (msb >= 5) {
        /* Estimate exponent - the formula is empirical */
        exponent = msb - 4;
        if (exponent > 15)
            exponent = 15;

        /* Calculate overflow for estimated exponent */
        for (uint8_t e = 0; e < exponent; e++)
            overflow = (overflow << 1) + 16;

        /* Adjust if estimate was off */
        while (exponent > 0 && value < overflow) {
            overflow = (overflow - 16) >> 1;
            exponent--;
        }
    }

    /* Find exact exponent */
    while (exponent < 15) {
        uint32_t next_overflow = (overflow << 1) + 16;
        if (value < next_overflow)
            break;
        overflow = next_overflow;
        exponent++;
    }

    uint8_t mantissa = (value - overflow) >> exponent;
    return (exponent << 4) | mantissa;
}

bool test_uf8_encode_0xA(){
    uint32_t value = 0xA;
    uf8 expected = 0x0A;
    uf8 result = uf8_encode(value);
    if (result != expected) {
        printf("Test failed: expected 0x%02X, got 0x%02X\n", expected, result);
        return false;
    }
    return true;
}

bool test_uf8_encode_0x1A(){
    uint32_t value = 0x1A;
    uf8 expected = 0x15;
    uf8 result = uf8_encode(value);
    if (result != expected) {
        printf("Test failed: expected 0x%02X, got 0x%02X\n", expected, result);
        return false;
    }
    return true;
}

bool test_uf8_encode_0xfffff(){
    uint32_t value = 0xf7ff0;
    uf8 expected = 0xFF;
    uf8 result = uf8_encode(value);
    if (result != expected) {
        printf("Test failed: expected 0x%02X, got 0x%02X\n", expected, result);
        return false;
    }
    return true;
}

int main(void)
{
    bool all_tests_passed = true;
    all_tests_passed &= test_uf8_encode_0xA();
    all_tests_passed &= test_uf8_encode_0x1A();
    all_tests_passed &= test_uf8_encode_0xfffff();
    if (all_tests_passed) {
        printf("All tests passed.\n");
        return 0;
    }
    return 1;
}
