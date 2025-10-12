#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

typedef struct {
    uint16_t bits;
} bf16_t;

#define BF16_EXP_MASK 0x7F80U
#define BF16_MANT_MASK 0x007FU

static inline bool bf16_isnan(bf16_t a)
{
    return ((a.bits & BF16_EXP_MASK) == BF16_EXP_MASK) &&
            (a.bits & BF16_MANT_MASK);
}

static inline bool bf16_isinf(bf16_t a)
{
    return ((a.bits & BF16_EXP_MASK) == BF16_EXP_MASK) &&
            !(a.bits & BF16_MANT_MASK);
}

static inline bool bf16_iszero(bf16_t a)
{
    return !(a.bits & 0x7FFF);
}

bool test_bf16_special_cases(){
    bf16_t nan1 = {.bits = 0x7FC1}; // NaN
    bf16_t nan2 = {.bits = 0x7FFF}; // NaN
    bf16_t inf = {.bits = 0x7F80};  // +Inf
    bf16_t ninf = {.bits = 0xFF80}; // -Inf
    bf16_t zero = {.bits = 0x0000}; // +0
    bf16_t nzero = {.bits = 0x8000}; // -0
    bf16_t num = {.bits = 0x3F80};  // 1.0

    if (!bf16_isnan(nan1)) return false;
    if (!bf16_isnan(nan2)) return false;
    if (!bf16_isinf(inf)) return false;
    if (!bf16_isinf(ninf)) return false;
    if (!bf16_iszero(zero)) return false;
    if (!bf16_iszero(nzero)) return false;
    if (bf16_isnan(num)) return false;
    if (bf16_isinf(num)) return false;
    if (bf16_iszero(num)) return false;

    return true;
}

int main(void)
{
    if (test_bf16_special_cases()) {
        printf("All special case tests passed.\n");
        return 0;
    }
    return 1;
}