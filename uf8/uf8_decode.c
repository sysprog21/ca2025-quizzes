#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef uint8_t uf8;

/* Decode uf8 to uint32_t */
uint32_t uf8_decode(uf8 fl)
{
    uint32_t mantissa = fl & 0x0f;
    uint8_t exponent = fl >> 4;
    uint32_t offset = (0x7FFF >> (15 - exponent)) << 4;
    return (mantissa << exponent) + offset;
}

bool test_uf8_decode_0x53()
{
    uf8 f = 0x53;
    uint32_t expected = 592;
    uint32_t result = uf8_decode(f);
    if (result != expected) {
        printf("Test failed: 0x%02X -> %u (expected %u)\n", f, result, expected);
        return false;
    }
    return true;
}

bool test_uf8_decode_0x0F()
{
    uf8 f = 0x0F;
    uint32_t expected = 15;
    uint32_t result = uf8_decode(f);
    if (result != expected) {
        printf("Test failed: 0x%02X -> %u (expected %u)\n", f, result, expected);
        return false;
    }
    return true;
}

bool test_uf8_decode_0xff()
{
    uf8 f = 0xFF;
    uint32_t expected = 1015792;
    uint32_t result = uf8_decode(f);
    if (result != expected) {
        printf("Test failed: 0x%02X -> %u (expected %u)\n", f, result, expected);
        return false;
    }
    return true;
}


int main(void)
{
    bool all_passed = true;
    all_passed &= test_uf8_decode_0x53();
    all_passed &= test_uf8_decode_0x0F();
    all_passed &= test_uf8_decode_0xff();
    if (all_passed) {
        printf("All tests passed!\n");
        return 0;
    }

    return 1;
}
