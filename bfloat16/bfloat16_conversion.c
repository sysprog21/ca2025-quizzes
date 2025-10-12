#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <math.h>

typedef struct {
    uint16_t bits;
} bf16_t;

static inline bf16_t f32_to_bf16(float val)
{
    uint32_t f32bits;
    memcpy(&f32bits, &val, sizeof(float));
    if (((f32bits >> 23) & 0xFF) == 0xFF)
        return (bf16_t) {.bits = (f32bits >> 16) & 0xFFFF};
    f32bits += ((f32bits >> 16) & 1) + 0x7FFF;
    return (bf16_t) {.bits = f32bits >> 16};
}

static inline float bf16_to_f32(bf16_t val)
{
    uint32_t f32bits = ((uint32_t) val.bits) << 16;
    float result;
    memcpy(&result, &f32bits, sizeof(float));
    return result;
}

bool test_basic_conversions(){
    // Start from bfloat16 bit patterns, round-trip bf16 -> f32 -> bf16
    static const uint16_t bf16_cases[] = {
        0x0000u, // +0
        0x8000u, // -0
        0x3F80u, // 1.0
        0xBF80u, // -1.0
        0x4000u, // 2.0
        0x3F00u, // 0.5
        0x4049u, // ~pi (bf16 approx)
        0xC049u, // ~-pi
        0x7F80u, // +Inf
        0xFF80u, // -Inf
        0x7FC1u, // qNaN
        0x0080u, // small subnormal
        0x007Fu, // smallest non-zero subnormal
        0x7BFFu, // max finite
    };

    for (size_t i = 0; i < sizeof(bf16_cases) / sizeof(bf16_cases[0]); i++) {
        bf16_t orig = { .bits = bf16_cases[i] };
        float f = bf16_to_f32(orig);
        bf16_t back = f32_to_bf16(f);
        if (back.bits != orig.bits) {
            printf("Round-trip mismatch: 0x%04x -> %g -> 0x%04x\n",(unsigned)orig.bits, f, (unsigned)back.bits);
            return false;
        }
    }
    return true;
};

int main(void)
{
    if (test_basic_conversions()) {
        printf("All tests passed!\n");
        return 0;
    }
    return 1;
}