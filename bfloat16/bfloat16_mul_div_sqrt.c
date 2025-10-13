#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

typedef struct {
    uint16_t bits;
} bf16_t;

#define BF16_SIGN_MASK 0x8000U
#define BF16_EXP_MASK 0x7F80U
#define BF16_MANT_MASK 0x007FU
#define BF16_EXP_BIAS 127

#define BF16_NAN() ((bf16_t) {.bits = 0x7FC0})
#define BF16_ZERO() ((bf16_t) {.bits = 0x0000})

static inline uint32_t mul16x16_u32(uint16_t x, uint16_t y) {
    uint32_t r = 0;
    while (y) {
        if (y & 1) r += (uint32_t)x;
        x <<= 1;
        y >>= 1;
    }
    return r;
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

    // uint32_t result_mant = (uint32_t) mant_a * mant_b;
    uint32_t result_mant = mul16x16_u32((uint16_t)mant_a, (uint16_t)mant_b);

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

    if (exp == 0xFF) {
        if (mant) return a;           /* NaN */
        if (sign) return BF16_NAN();  /* sqrt(-Inf) = NaN */
        return a;                     /* +Inf */
    }
    if (!exp && !mant) return BF16_ZERO();  /* sqrt(0) = 0 */
    if (sign) return BF16_NAN();            /* sqrt(negative) = NaN */
    if (!exp) return BF16_ZERO();           /* flush denormals */

    int32_t e = exp - BF16_EXP_BIAS;
    int32_t new_exp;
    uint32_t m = 0x80 | mant;

    if (e & 1) {
        m <<= 1;
        new_exp = ((e - 1) >> 1) + BF16_EXP_BIAS;
    } else {
        new_exp = (e >> 1) + BF16_EXP_BIAS;
    }

    uint32_t low = 90, high = 256, result = 128;
    while (low <= high) {
        uint32_t mid = (low + high) >> 1;
        uint32_t sq = mul16x16_u32((uint16_t)mid, (uint16_t)mid) >> 7;
        if (sq <= m) { result = mid; low = mid + 1; }
        else { high = mid - 1; }
    }

    if (result >= 256) {
        result >>= 1;
        new_exp++;
    } else if (result < 128) {
        while (result < 128 && new_exp > 1) {
            result <<= 1;
            new_exp--;
        }
    }

    uint16_t new_mant = result & 0x7F;

    if (new_exp >= 0xFF) return (bf16_t){ .bits = 0x7F80 }; /* +Inf */
    if (new_exp <= 0)    return BF16_ZERO();

    /* 正常回傳 */
    return (bf16_t){
        .bits = ((uint16_t)0 << 15) | (((uint16_t)new_exp & 0xFF) << 7) | new_mant
    };
}


bool test_mul_div_sqrt(void)
{
    bf16_t a = (bf16_t) {.bits = 0x4120}; /* 10.0 */
    bf16_t b = (bf16_t) {.bits = 0x4000}; /* 2.0 */

    bf16_t mul_res = bf16_mul(a, b); /* Expect ~20.0 */
    if (mul_res.bits < 0x41A0 || mul_res.bits > 0x41A1) {
        printf("Multiplication failed: got 0x%04x expected ~0x41A0\n", mul_res.bits);
        return false;
    }

    bf16_t div_res = bf16_div(a, b); /* Expect ~5.0 */
    if (div_res.bits < 0x40A0 || div_res.bits > 0x40A1) {
        printf("Division failed: got 0x%04x expected ~0x40A0\n", div_res.bits);
        return false;
    }

    bf16_t sqrt_input = (bf16_t) {.bits = 0x4080}; /* 4.0 */
    bf16_t sqrt_res = bf16_sqrt(sqrt_input); /* Expect ~2.0 */
    if (sqrt_res.bits < 0x4000 || sqrt_res.bits > 0x4000) {
        printf("Square root failed: got 0x%04x expected ~0x4000\n", sqrt_res.bits);
        return false;
    }

    return true;
}

int main() {
    if (test_mul_div_sqrt()) {
        printf("All tests passed\n");
        return 0;
    }
    return 1;
}
    