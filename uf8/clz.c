#include <stdint.h>
#include <stdio.h>

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


int main(void)
{
    uint32_t x = 0x10;
    printf("Leading Zero of %d = %d .\n", x, clz(0x10));
    return 1;
}
