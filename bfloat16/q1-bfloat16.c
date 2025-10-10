#include <stdbool.h>
#include <stdint.h>
#include <string.h>

typedef struct {
    uint16_t bits;
} bf16_t;

#define BF16_SIGN_MASK 0x8000U
#define BF16_EXP_MASK 0x7F80U
#define BF16_MANT_MASK 0x007FU
#define BF16_EXP_BIAS 127

#define BF16_NAN() ((bf16_t) {.bits = 0x7FC0})
#define BF16_ZERO() ((bf16_t) {.bits = 0x0000})

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

static inline bf16_t bf16_add(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    if (exp_a == 0xFF) {
        if (mant_a)
            return a;
        if (exp_b == 0xFF)
            return (mant_b || sign_a == sign_b) ? b : BF16_NAN();
        return a;
    }
    if (exp_b == 0xFF)
        return b;
    if (!exp_a && !mant_a)
        return b;
    if (!exp_b && !mant_b)
        return a;
    if (exp_a)
        mant_a |= 0x80;
    if (exp_b)
        mant_b |= 0x80;

    int16_t exp_diff = exp_a - exp_b;
    uint16_t result_sign;
    int16_t result_exp;
    uint32_t result_mant;

    if (exp_diff > 0) {
        result_exp = exp_a;
        if (exp_diff > 8)
            return a;
        mant_b >>= exp_diff;
    } else if (exp_diff < 0) {
        result_exp = exp_b;
        if (exp_diff < -8)
            return b;
        mant_a >>= -exp_diff;
    } else {
        result_exp = exp_a;
    }

    if (sign_a == sign_b) {
        result_sign = sign_a;
        result_mant = (uint32_t) mant_a + mant_b;

        if (result_mant & 0x100) {
            result_mant >>= 1;
            if (++result_exp >= 0xFF)
                return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
        }
    } else {
        if (mant_a >= mant_b) {
            result_sign = sign_a;
            result_mant = mant_a - mant_b;
        } else {
            result_sign = sign_b;
            result_mant = mant_b - mant_a;
        }

        if (!result_mant)
            return BF16_ZERO();
        while (!(result_mant & 0x80)) {
            result_mant <<= 1;
            if (--result_exp <= 0)
                return BF16_ZERO();
        }
    }

    return (bf16_t) {
        .bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                (result_mant & 0x7F),
    };
}

static inline bf16_t bf16_sub(bf16_t a, bf16_t b)
{
    b.bits ^= BF16_SIGN_MASK;
    return bf16_add(a, b);
}

static inline bf16_t bf16_mul(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    uint16_t result_sign = sign_a ^ sign_b;

    if (exp_a == 0xFF) {
        if (mant_a)
            return a;
        if (!exp_b && !mant_b)
            return BF16_NAN();
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if (exp_b == 0xFF) {
        if (mant_b)
            return b;
        if (!exp_a && !mant_a)
            return BF16_NAN();
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if ((!exp_a && !mant_a) || (!exp_b && !mant_b))
        return (bf16_t) {.bits = result_sign << 15};

    int16_t exp_adjust = 0;
    if (!exp_a) {
        while (!(mant_a & 0x80)) {
            mant_a <<= 1;
            exp_adjust--;
        }
        exp_a = 1;
    } else
        mant_a |= 0x80;
    if (!exp_b) {
        while (!(mant_b & 0x80)) {
            mant_b <<= 1;
            exp_adjust--;
        }
        exp_b = 1;
    } else
        mant_b |= 0x80;

    uint32_t result_mant = (uint32_t) mant_a * mant_b;

    int32_t result_exp = (int32_t) exp_a + exp_b - BF16_EXP_BIAS + exp_adjust;

    if (result_mant & 0x8000) {
        result_mant = (result_mant >> 8) & 0x7F;
        result_exp++;
    } else
        result_mant = (result_mant >> 7) & 0x7F;

    if (result_exp >= 0xFF)
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    if (result_exp <= 0) {
        if (result_exp < -6)
            return (bf16_t) {.bits = result_sign << 15};
        result_mant >>= (1 - result_exp);
        result_exp = 0;
    }

    return (bf16_t) {.bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                             (result_mant & 0x7F)};
}

static inline bf16_t bf16_div(bf16_t a, bf16_t b)
{
    uint16_t sign_a = (a.bits >> 15) & 1;
    uint16_t sign_b = (b.bits >> 15) & 1;
    int16_t exp_a = ((a.bits >> 7) & 0xFF);
    int16_t exp_b = ((b.bits >> 7) & 0xFF);
    uint16_t mant_a = a.bits & 0x7F;
    uint16_t mant_b = b.bits & 0x7F;

    uint16_t result_sign = sign_a ^ sign_b;

    if (exp_b == 0xFF) {
        if (mant_b)
            return b;
        /* Inf/Inf = NaN */
        if (exp_a == 0xFF && !mant_a)
            return BF16_NAN();
        return (bf16_t) {.bits = result_sign << 15};
    }
    if (!exp_b && !mant_b) {
        if (!exp_a && !mant_a)
            return BF16_NAN();
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if (exp_a == 0xFF) {
        if (mant_a)
            return a;
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    }
    if (!exp_a && !mant_a)
        return (bf16_t) {.bits = result_sign << 15};

    if (exp_a)
        mant_a |= 0x80;
    if (exp_b)
        mant_b |= 0x80;

    uint32_t dividend = (uint32_t) mant_a << 15;
    uint32_t divisor = mant_b;
    uint32_t quotient = 0;

    for (int i = 0; i < 16; i++) {
        quotient <<= 1;
        if (dividend >= (divisor << (15 - i))) {
            dividend -= (divisor << (15 - i));
            quotient |= 1;
        }
    }

    int32_t result_exp = (int32_t) exp_a - exp_b + BF16_EXP_BIAS;

    if (!exp_a)
        result_exp--;
    if (!exp_b)
        result_exp++;

    if (quotient & 0x8000)
        quotient >>= 8;
    else {
        while (!(quotient & 0x8000) && result_exp > 1) {
            quotient <<= 1;
            result_exp--;
        }
        quotient >>= 8;
    }
    quotient &= 0x7F;

    if (result_exp >= 0xFF)
        return (bf16_t) {.bits = (result_sign << 15) | 0x7F80};
    if (result_exp <= 0)
        return (bf16_t) {.bits = result_sign << 15};
    return (bf16_t) {
        .bits = (result_sign << 15) | ((result_exp & 0xFF) << 7) |
                (quotient & 0x7F),
    };
}

static inline bf16_t bf16_sqrt(bf16_t a)
{
    uint16_t sign = (a.bits >> 15) & 1;
    int16_t exp = ((a.bits >> 7) & 0xFF);
    uint16_t mant = a.bits & 0x7F;

    /* Handle special cases */
    if (exp == 0xFF) {
        if (mant)
            return a; /* NaN propagation */
        if (sign)
            return BF16_NAN(); /* sqrt(-Inf) = NaN */
        return a;              /* sqrt(+Inf) = +Inf */
    }

    /* sqrt(0) = 0 (handle both +0 and -0) */
    if (!exp && !mant)
        return BF16_ZERO();

    /* sqrt of negative number is NaN */
    if (sign)
        return BF16_NAN();

    /* Flush denormals to zero */
    if (!exp)
        return BF16_ZERO();

    /* Direct bit manipulation square root algorithm */
    /* For sqrt: new_exp = (old_exp - bias) / 2 + bias */
    int32_t e = exp - BF16_EXP_BIAS;
    int32_t new_exp;
    
    /* Get full mantissa with implicit 1 */
    uint32_t m = 0x80 | mant;  /* Range [128, 256) representing [1.0, 2.0) */
    
    /* Adjust for odd exponents: sqrt(2^odd * m) = 2^((odd-1)/2) * sqrt(2*m) */
    if (e & 1) {
        m <<= 1;  /* Double mantissa for odd exponent */
        new_exp = ((e - 1) >> 1) + BF16_EXP_BIAS;
    } else {
        new_exp = (e >> 1) + BF16_EXP_BIAS;
    }
    
    /* Now m is in range [128, 256) or [256, 512) if exponent was odd */
    /* Binary search for integer square root */
    /* We want result where result^2 = m * 128 (since 128 represents 1.0) */
    
    uint32_t low = 90;          /* Min sqrt (roughly sqrt(128)) */
    uint32_t high = 256;        /* Max sqrt (roughly sqrt(512)) */
    uint32_t result = 128;      /* Default */
    
    /* Binary search for square root of m */
    while (low <= high) {
        uint32_t mid = (low + high) >> 1;
        uint32_t sq = (mid * mid) / 128;  /* Square and scale */
        
        if (sq <= m) {
            result = mid;  /* This could be our answer */
            low = mid + 1;
        } else {
            high = mid - 1;
        }
    }
    
    /* result now contains sqrt(m) * sqrt(128) / sqrt(128) = sqrt(m) */
    /* But we need to adjust the scale */
    /* Since m is scaled where 128=1.0, result should also be scaled same way */
    
    /* Normalize to ensure result is in [128, 256) */
    if (result >= 256) {
        result >>= 1;
        new_exp++;
    } else if (result < 128) {
        while (result < 128 && new_exp > 1) {
            result <<= 1;
            new_exp--;
        }
    }
    
    /* Extract 7-bit mantissa (remove implicit 1) */
    uint16_t new_mant = result & 0x7F;
    
    /* Check for overflow/underflow */
    if (new_exp >= 0xFF)
        return (bf16_t) {.bits = 0x7F80};  /* +Inf */
    if (new_exp <= 0)
        return BF16_ZERO();
    
    return (bf16_t) {.bits = ((new_exp & 0xFF) << 7) | new_mant};
}

static inline bool bf16_eq(bf16_t a, bf16_t b)
{
    if (bf16_isnan(a) || bf16_isnan(b))
        return false;
    if (bf16_iszero(a) && bf16_iszero(b))
        return true;
    return a.bits == b.bits;
}

static inline bool bf16_lt(bf16_t a, bf16_t b)
{
    if (bf16_isnan(a) || bf16_isnan(b))
        return false;
    if (bf16_iszero(a) && bf16_iszero(b))
        return false;
    bool sign_a = (a.bits >> 15) & 1, sign_b = (b.bits >> 15) & 1;
    if (sign_a != sign_b)
        return sign_a > sign_b;
    return sign_a ? a.bits > b.bits : a.bits < b.bits;
}

static inline bool bf16_gt(bf16_t a, bf16_t b)
{
    return bf16_lt(b, a);
}

#include <stdio.h>
#include <time.h>

#define TEST_ASSERT(cond, msg)         \
    do {                               \
        if (!(cond)) {                 \
            printf("FAIL: %s\n", msg); \
            return 1;                  \
        }                              \
    } while (0)

static int test_basic_conversions(void)
{
    printf("Testing basic conversions...\n");

    float test_values[] = {0.0f,  1.0f,     -1.0f,     2.0f,  -2.0f, 0.5f,
                           -0.5f, 3.14159f, -3.14159f, 1e10f, -1e10f};

    for (size_t i = 0; i < sizeof(test_values) / sizeof(test_values[0]); i++) {
        float orig = test_values[i];
        bf16_t bf = f32_to_bf16(orig);
        float conv = bf16_to_f32(bf);

        if (orig != 0.0f) {
            TEST_ASSERT((orig < 0) == (conv < 0), "Sign mismatch");
        }

        if (orig != 0.0f && !bf16_isinf(f32_to_bf16(orig))) {
            float diff = (conv - orig);
            float rel_error = (diff < 0) ? -diff / orig : diff / orig;
            TEST_ASSERT(rel_error < 0.01f, "Relative error too large");
        }
    }

    printf("  Basic conversions: PASS\n");
    return 0;
}

static int test_special_values(void)
{
    printf("Testing special values...\n");

    bf16_t pos_inf = {.bits = 0x7F80};  /* +Infinity */
    TEST_ASSERT(bf16_isinf(pos_inf), "Positive infinity not detected");
    TEST_ASSERT(!bf16_isnan(pos_inf), "Infinity detected as NaN");

    bf16_t neg_inf = {.bits = 0xFF80};  /* -Infinity */
    TEST_ASSERT(bf16_isinf(neg_inf), "Negative infinity not detected");

    bf16_t nan_val = BF16_NAN();
    TEST_ASSERT(bf16_isnan(nan_val), "NaN not detected");
    TEST_ASSERT(!bf16_isinf(nan_val), "NaN detected as infinity");

    bf16_t zero = f32_to_bf16(0.0f);
    TEST_ASSERT(bf16_iszero(zero), "Zero not detected");

    bf16_t neg_zero = f32_to_bf16(-0.0f);
    TEST_ASSERT(bf16_iszero(neg_zero), "Negative zero not detected");

    printf("  Special values: PASS\n");
    return 0;
}

static int test_arithmetic(void)
{
    printf("Testing arithmetic operations...\n");

    bf16_t a = f32_to_bf16(1.0f);
    bf16_t b = f32_to_bf16(2.0f);
    bf16_t c = bf16_add(a, b);
    float result = bf16_to_f32(c);
    float diff = result - 3.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.01f, "Addition failed");

    c = bf16_sub(b, a);
    result = bf16_to_f32(c);
    diff = result - 1.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.01f, "Subtraction failed");

    a = f32_to_bf16(3.0f);
    b = f32_to_bf16(4.0f);
    c = bf16_mul(a, b);
    result = bf16_to_f32(c);
    diff = result - 12.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.1f, "Multiplication failed");

    a = f32_to_bf16(10.0f);
    b = f32_to_bf16(2.0f);
    c = bf16_div(a, b);
    result = bf16_to_f32(c);
    diff = result - 5.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.1f, "Division failed");

    /* Test square root */
    a = f32_to_bf16(4.0f);
    c = bf16_sqrt(a);
    result = bf16_to_f32(c);
    diff = result - 2.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.01f, "sqrt(4) failed");

    a = f32_to_bf16(9.0f);
    c = bf16_sqrt(a);
    result = bf16_to_f32(c);
    diff = result - 3.0f;
    TEST_ASSERT((diff < 0 ? -diff : diff) < 0.01f, "sqrt(9) failed");

    printf("  Arithmetic: PASS\n");
    return 0;
}

static int test_comparisons(void)
{
    printf("Testing comparison operations...\n");

    bf16_t a = f32_to_bf16(1.0f);
    bf16_t b = f32_to_bf16(2.0f);
    bf16_t c = f32_to_bf16(1.0f);

    TEST_ASSERT(bf16_eq(a, c), "Equality test failed");
    TEST_ASSERT(!bf16_eq(a, b), "Inequality test failed");

    TEST_ASSERT(bf16_lt(a, b), "Less than test failed");
    TEST_ASSERT(!bf16_lt(b, a), "Not less than test failed");
    TEST_ASSERT(!bf16_lt(a, c), "Equal not less than test failed");

    TEST_ASSERT(bf16_gt(b, a), "Greater than test failed");
    TEST_ASSERT(!bf16_gt(a, b), "Not greater than test failed");

    bf16_t nan_val = BF16_NAN();
    TEST_ASSERT(!bf16_eq(nan_val, nan_val), "NaN equality test failed");
    TEST_ASSERT(!bf16_lt(nan_val, a), "NaN less than test failed");
    TEST_ASSERT(!bf16_gt(nan_val, a), "NaN greater than test failed");

    printf("  Comparisons: PASS\n");
    return 0;
}

static int test_edge_cases(void)
{
    printf("Testing edge cases...\n");

    float tiny = 1e-45f;
    bf16_t bf_tiny = f32_to_bf16(tiny);
    float tiny_val = bf16_to_f32(bf_tiny);
    TEST_ASSERT(bf16_iszero(bf_tiny) || (tiny_val < 0 ? -tiny_val : tiny_val) < 1e-37f,
                "Tiny value handling");

    float huge = 1e38f;
    bf16_t bf_huge = f32_to_bf16(huge);
    bf16_t bf_huge2 = bf16_mul(bf_huge, f32_to_bf16(10.0f));
    TEST_ASSERT(bf16_isinf(bf_huge2), "Overflow should produce infinity");

    bf16_t small = f32_to_bf16(1e-38f);
    bf16_t smaller = bf16_div(small, f32_to_bf16(1e10f));
    float smaller_val = bf16_to_f32(smaller);
    TEST_ASSERT(bf16_iszero(smaller) || (smaller_val < 0 ? -smaller_val : smaller_val) < 1e-45f,
                "Underflow should produce zero or denormal");

    printf("  Edge cases: PASS\n");
    return 0;
}

static int test_rounding(void)
{
    printf("Testing rounding behavior...\n");

    float exact = 1.5f;
    bf16_t bf_exact = f32_to_bf16(exact);
    float back_exact = bf16_to_f32(bf_exact);
    TEST_ASSERT(back_exact == exact,
                "Exact representation should be preserved");

    float val = 1.0001f;
    bf16_t bf = f32_to_bf16(val);
    float back = bf16_to_f32(bf);
    float diff2 = back - val;
    TEST_ASSERT((diff2 < 0 ? -diff2 : diff2) < 0.001f, "Rounding error should be small");

    printf("  Rounding: PASS\n");
    return 0;
}

#ifndef BFLOAT16_NO_MAIN
int main(void)
{
    printf("\n=== bfloat16 Test Suite ===\n\n");

    int failed = 0;

    failed |= test_basic_conversions();
    failed |= test_special_values();
    failed |= test_arithmetic();
    failed |= test_comparisons();
    failed |= test_edge_cases();
    failed |= test_rounding();

    if (failed) {
        printf("\n=== TESTS FAILED ===\n");
        return 1;
    }

    printf("\n=== ALL TESTS PASSED ===\n");
    return 0;
}
#endif /* BFLOAT16_NO_MAIN */
