#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <stdio.h>

typedef struct {
    uint16_t bits;
} bf16_t;

#define BF16_SIGN_MASK 0x8000U

#define BF16_NAN() ((bf16_t) {.bits = 0x7FC0})
#define BF16_ZERO() ((bf16_t) {.bits = 0x0000})


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
        // When b is too small to a to affect the result, return a
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

static inline bf16_t neg(bf16_t x) { x.bits ^= BF16_SIGN_MASK; return x; }
static inline int is_zero_mag(bf16_t x){ return (x.bits & 0x7FFFu) == 0; }
static inline int eq_allow_signed_zero(bf16_t got, bf16_t exp){
    return is_zero_mag(exp) ? is_zero_mag(got) : (got.bits == exp.bits);
}

bool test_basic_add_sub(void)
{


    static const struct V {
    bf16_t a, b, sum, diff;
    } tv[] = {
        { {.bits=0x0000}, {.bits=0x0000}, {.bits=0x0000}, {.bits=0x0000} },
        { {.bits=0x3F80}, {.bits=0x3F80}, {.bits=0x4000}, {.bits=0x0000} },
        { {.bits=0x3F80}, {.bits=0x3F00}, {.bits=0x3FC0}, {.bits=0x3F00} },
        { {.bits=0x4000}, {.bits=0xBF80}, {.bits=0x3F80}, {.bits=0x4040} },
        { {.bits=0xBFC0}, {.bits=0x3F00}, {.bits=0xBF80}, {.bits=0xC000} },
        { {.bits=0xBF80}, {.bits=0x3F80}, {.bits=0x0000}, {.bits=0xC000} },
        { {.bits=0x3F80}, {.bits=0xBF80}, {.bits=0x0000}, {.bits=0x4000} },
        { {.bits=0x4000}, {.bits=0x3B80}, {.bits=0x4000}, {.bits=0x4000} },
    };

    for (size_t i = 0; i < sizeof(tv)/sizeof(tv[0]); ++i) {
        bf16_t A = tv[i].a, B = tv[i].b;

        // add
        bf16_t sab = bf16_add(A, B);
        if (!eq_allow_signed_zero(sab, tv[i].sum)) {
            printf("Error A+B: 0x%04x + 0x%04x = 0x%04x (expected 0x%04x or signed-0)\n",
                    A.bits, B.bits, sab.bits, tv[i].sum.bits);
            return false;
        }
        bf16_t sba = bf16_add(B, A);
        if (!eq_allow_signed_zero(sba, tv[i].sum)) {
            printf("Error B+A: 0x%04x + 0x%04x = 0x%04x (expected 0x%04x or signed-0)\n",
                    B.bits, A.bits, sba.bits, tv[i].sum.bits);
            return false;
        }

        // sub
        bf16_t dab = bf16_sub(A, B);
        if (!eq_allow_signed_zero(dab, tv[i].diff)) {
            printf("Error A-B: 0x%04x - 0x%04x = 0x%04x (expected 0x%04x or signed-0)\n",
                    A.bits, B.bits, dab.bits, tv[i].diff.bits);
            return false;
        }
        bf16_t dba = bf16_sub(B, A);
        if (!eq_allow_signed_zero(dba, neg(dab))) {
            printf("Error B-A: 0x%04x - 0x%04x = 0x%04x (expected 0x%04x or signed-0)\n",
                    B.bits, A.bits, dba.bits, neg(dab).bits);
            return false;
        }

        // identities with zero (allow ±0 when A is zero)
        if (!eq_allow_signed_zero(bf16_add(A, BF16_ZERO()), A)) {
            printf("Error A+0: got 0x%04x expected 0x%04x or signed-0\n",
                    bf16_add(A, BF16_ZERO()).bits, A.bits);
            return false;
        }
        if (!eq_allow_signed_zero(bf16_add(BF16_ZERO(), A), A)) {
            printf("Error 0+A: got 0x%04x expected 0x%04x or signed-0\n",
                    bf16_add(BF16_ZERO(), A).bits, A.bits);
            return false;
        }
        if (!eq_allow_signed_zero(bf16_sub(A, BF16_ZERO()), A)) {
            printf("Error A-0: got 0x%04x expected 0x%04x or signed-0\n",
                    bf16_sub(A, BF16_ZERO()).bits, A.bits);
            return false;
        }
        if (!is_zero_mag(bf16_sub(A, A))) {
            printf("Error A-A: got 0x%04x expected ±0\n", bf16_sub(A, A).bits);
            return false;
        }
    }
    return true;
}

#define BF16_PINF() ((bf16_t) {.bits = 0x7F80} )
#define BF16_NINF() ((bf16_t) {.bits = 0xFF80} )

static inline int is_nan(bf16_t x){ return ((x.bits & 0x7F80u) == 0x7F80u) && (x.bits & 0x007Fu); }
static inline int is_pinf(bf16_t x){ return x.bits == 0x7F80u; }
static inline int is_ninf(bf16_t x){ return x.bits == 0xFF80u; }

/* existing test_basic_add_sub(...) stays as you wrote */

/* Inf/NaN tests */
bool test_inf_nan(void)
{
    bf16_t one   =  (bf16_t)  {.bits = 0x3F80};   // 1.0
    bf16_t two   =  (bf16_t)  {.bits = 0x4000};   // 2.0
    bf16_t pinf  = BF16_PINF();
    bf16_t ninf  = BF16_NINF();
    bf16_t qnan  = BF16_NAN();

    /* NaN propagation */
    if (!is_nan(bf16_add(qnan, one))) {
        printf("NaN+finite not NaN\n"); return false;
    }
    if (!is_nan(bf16_add(one, qnan))) {
        printf("finite+NaN not NaN\n"); return false;
    }
    if (!is_nan(bf16_add(qnan, qnan))) {
        printf("NaN+NaN not NaN\n"); return false;
    }

    if (!is_nan(bf16_sub(qnan, one))) {
        printf("NaN-finite not NaN\n"); return false;
    }
    if (!is_nan(bf16_sub(one, qnan))) {
        printf("finite-NaN not NaN\n"); return false;
    }
    if (!is_nan(bf16_sub(qnan, qnan))) {
        printf("NaN-NaN not NaN\n"); return false;
    }

    /* Inf with finite */
    if (!is_pinf(bf16_add(pinf, two))) {
        printf("+Inf+finite not +Inf\n"); return false;
    }
    if (!is_pinf(bf16_add(two, pinf))) {
        printf("finite+ +Inf not +Inf\n"); return false;
    }
    if (!is_ninf(bf16_add(ninf, two))) {
        printf("-Inf+finite not -Inf\n"); return false;
    }
    if (!is_ninf(bf16_add(two, ninf))) {
        printf("finite+ -Inf not -Inf\n"); return false;
    }

    if (!is_pinf(bf16_sub(two, ninf))) {
        printf("finite-(-Inf) not +Inf\n"); return false;
    }
    if (!is_ninf(bf16_sub(two, pinf))) {
        printf("finite-(+Inf) not -Inf\n"); return false;
    }

    /* Inf with Inf */
    if (!is_pinf(bf16_add(pinf, pinf))) {
        printf("+Inf+ +Inf not +Inf\n"); return false;
    }
    if (!is_ninf(bf16_add(ninf, ninf))) {
        printf("-Inf+ -Inf not -Inf\n"); return false;
    }
    if (!is_nan(bf16_add(pinf, ninf)))  {
        printf("+Inf+ -Inf not NaN\n"); return false;
    }
    if (!is_nan(bf16_add(ninf, pinf)))  {
        printf("-Inf+ +Inf not NaN\n"); return false;
    }

    if (!is_nan(bf16_sub(pinf, pinf)))  {
        printf("+Inf- +Inf not NaN\n"); return false;
    }
    if (!is_pinf(bf16_sub(pinf, ninf))) {
        printf("+Inf- -Inf not +Inf\n"); return false;
    }
    if (!is_ninf(bf16_sub(ninf, pinf))) {
        printf("-Inf- +Inf not -Inf\n"); return false;
    }

    return true;
}

/* update main */
int main(void)
{
    if (test_basic_add_sub() && test_inf_nan()) {
        printf("All tests passed!\n");
        return 0;
    }
    return 1;
}